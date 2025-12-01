import 'package:flutter/material.dart';
import 'package:travel_connect/models/experience.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'currency_price.dart';
import 'package:travel_connect/services/booking_service.dart';

/// Experience card widget for displaying experience information in lists
class ExperienceCard extends StatelessWidget {
  const ExperienceCard({
    super.key,
    required this.experience,
    required this.onTap,
  });

  final Experience experience;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Experience image
              _buildImageSection(),

              // Content section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and rating
                    _buildTitleSection(),

                    const SizedBox(height: 8),

                    // Location
                    _buildLocationSection(),

                    const SizedBox(height: 12),

                    // Price and Bookings
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CurrencyPrice(
                          priceInCOP: experience.priceCOP,
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.forestGreen,
                          ),
                          compact: true,
                        ),
                        _BookingCountBadge(experienceId: experience.id),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: experience.images.isNotEmpty
          ? ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: experience.images.first,
                fit: BoxFit.cover,
                height: 180,
                width: double.infinity,
                memCacheWidth: 600,
                memCacheHeight: 400,
                maxWidthDiskCache: 600,
                maxHeightDiskCache: 400,
                placeholder: (context, url) => Container(
                  color: AppColors.peach.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.peach.withOpacity(0.3),
                  child: const Center(
                    child: Icon(Icons.error),
                  ),
                ),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                color: AppColors.peach.withOpacity(0.3),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_camera_outlined,
                      size: 32,
                      color: AppColors.oliveGold.withOpacity(0.7),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No Image Available',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.oliveGold.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Expanded(
              child: Text(
                experience.title,
                style: AppTypography.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(width: 16),

            // Rating
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: AppColors.oliveGold,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  experience.avgRating.toStringAsFixed(1),
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Row(
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
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Optimized booking count badge that fetches data once instead of streaming
class _BookingCountBadge extends StatefulWidget {
  const _BookingCountBadge({required this.experienceId});

  final String experienceId;

  @override
  State<_BookingCountBadge> createState() => _BookingCountBadgeState();
}

class _BookingCountBadgeState extends State<_BookingCountBadge> {
  int? _bookingCount;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookingCount();
  }

  Future<void> _loadBookingCount() async {
    try {
      // Get the first value from the stream and don't subscribe
      final count = await BookingService()
          .getBookingsCountStream(widget.experienceId)
          .first;
      if (mounted) {
        setState(() {
          _bookingCount = count;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _bookingCount == null || _bookingCount! <= 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.forestGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.forestGreen.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.trending_up,
            color: AppColors.forestGreen,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            '$_bookingCount reservation(s) last week',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.forestGreen,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
