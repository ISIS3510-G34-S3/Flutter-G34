import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_connect/models/experience.dart';
import 'package:travel_connect/services/experience_service.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

/// Map screen showing experience locations with pins
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Experience? _selectedExperience;
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final ExperienceService _experienceService = ExperienceService();
  bool _isLoading = true;

  // Location services
  final Location _location = Location();
  LocationData? _currentLocation;

  // Default location (Bogotá, Colombia) - fallback if location not available
  final CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(4.6097, -74.0817),
    zoom: 3.0,
  );

  @override
  void initState() {
    super.initState();
    _fetchExperiencesAndCreateMarkers();
    _initializeLocation();
  }

  Future<void> _fetchExperiencesAndCreateMarkers() async {
    try {
      final experiences = await _experienceService.getExperiences();
      final newMarkers = _createMarkersFromExperiences(experiences);
      if (mounted) {
        setState(() {
          _markers.clear();
          _markers.addAll(newMarkers);
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Set<Marker> _createMarkersFromExperiences(List<Experience> experiences) {
    final Set<Marker> newMarkers = {};
    for (final experience in experiences) {
      newMarkers.add(
        Marker(
          markerId: MarkerId(experience.id),
          position: LatLng(
              experience.location["latitude"], experience.location["longitude"]),
          infoWindow: InfoWindow(
            title: experience.title,
            snippet: '${experience.avgRating}⭐',
          ),
          icon: experience.avgRating >= 4.8
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
              : BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueOrange),
          onTap: () => _selectExperience(experience),
        ),
      );
    }
    return newMarkers;
  }

  /// Initialize location services and get current location
  Future<void> _initializeLocation() async {
    try {
      // Check if location service is enabled
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      // Check location permissions
      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      // Get current location
      await _getCurrentLocation();
    } catch (e) {
      debugPrint('Error initializing location: $e');
    }
  }

  /// Get the user's current location
  Future<void> _getCurrentLocation() async {
    try {
      final LocationData locationData = await _location.getLocation();
      setState(() {
        _currentLocation = locationData;
      });

      // Move map to user's location if map controller is available
      if (_mapController != null && _currentLocation != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(
                _currentLocation!.latitude!,
                _currentLocation!.longitude!,
              ),
              zoom: 15.0,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error getting current location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to get your location. Please enable location services.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(
              Icons.location_on,
              color: AppColors.white,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Map View',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.white,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.forestGreen,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              // Get location again after map is ready
              _getCurrentLocation();
            },
            initialCameraPosition: _initialPosition,
            markers: _markers,
            mapType: MapType.normal,
            myLocationEnabled: true, // Shows the blue dot for user location
            myLocationButtonEnabled: false, // We have our custom button
            zoomControlsEnabled: false,
            compassEnabled: true,
            onTap: (_) {
              // Dismiss bottom sheet when tapping on map
              setState(() {
                _selectedExperience = null;
              });
            },
          ),

          // Loading indicator
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),

          // Custom zoom controls
          _buildZoomControls(),

          // Bottom sheet for selected experience
          if (_selectedExperience != null)
            _buildBottomSheet(_selectedExperience!),
        ],
      ),
    );
  }



  Widget _buildZoomControls() {
    return Positioned(
      right: 16,
      top: 100,
      child: Column(
        children: [
          // Zoom in button
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary.withValues(alpha: 0.2),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: IconButton(
              onPressed: _zoomIn,
              icon: const Icon(
                Icons.add,
                color: AppColors.textPrimary,
              ),
              tooltip: 'Zoom in',
            ),
          ),

          const SizedBox(height: 8),

          // Zoom out button
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary.withValues(alpha: 0.2),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: IconButton(
              onPressed: _zoomOut,
              icon: const Icon(
                Icons.remove,
                color: AppColors.textPrimary,
              ),
              tooltip: 'Zoom out',
            ),
          ),

          const SizedBox(height: 8),

          // My Location button
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary.withValues(alpha: 0.2),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: IconButton(
              onPressed: _moveToUserLocation,
              icon: const Icon(
                Icons.my_location,
                color: AppColors.forestGreen,
              ),
              tooltip: 'My Location',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(Experience experience) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withOpacity(0.2),
              offset: const Offset(0, -4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and rating
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          experience.title,
                          style: AppTypography.titleSmall,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: AppColors.oliveGold,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            experience.avgRating.toStringAsFixed(1),
                            style: AppTypography.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          experience.department,
                          style: AppTypography.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // View Details button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _viewExperienceDetails(experience.id),
                      child: const Text('View Details'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectExperience(Experience experience) {
    setState(() {
      _selectedExperience = experience;
    });
  }

  void _zoomIn() async {
    if (_mapController != null) {
      await _mapController!.animateCamera(CameraUpdate.zoomIn());
    }
  }

  void _zoomOut() async {
    if (_mapController != null) {
      await _mapController!.animateCamera(CameraUpdate.zoomOut());
    }
  }

  void _moveToUserLocation() async {
    if (_mapController != null) {
      try {
        // If we have current location, use it
        if (_currentLocation != null) {
          await _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(
                  _currentLocation!.latitude!,
                  _currentLocation!.longitude!,
                ),
                zoom: 15.0,
              ),
            ),
          );
        } else {
          // Try to get fresh location
          await _getCurrentLocation();
        }
      } catch (e) {
        // Handle location error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to get your location. Please enable location services.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  void _viewExperienceDetails(String experienceId) {
    context.push('/experience/$experienceId');
  }
}


