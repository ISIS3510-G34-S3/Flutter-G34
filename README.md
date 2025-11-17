# TravelConnect - Flutter G34

A Flutter application for cultural experience sharing, developed by Group 34 for the Mobile Development course at Universidad de los Andes.

## 📱 About

TravelConnect is a mobile application that allows users to discover, share, and explore cultural experiences around the world. The app provides a platform for travelers to connect through shared cultural adventures and local experiences.

## 🚀 Features

- **User Authentication**: Login system for personalized experiences
- **Experience Discovery**: Browse and filter cultural experiences with advanced search
- **Interactive Map**: Explore experiences geographically with location-based navigation
- **Create Experiences**: Share your own cultural adventures with photo uploads
- **Detailed Experience Views**: Comprehensive information including pricing, categories, host profiles, and reviews
- **User Profiles**: Personalized user profiles and experience management
- **Profile Picture Upload**: Upload, update, and remove profile pictures with automatic optimization
- **Photo Galleries**: Swipeable image galleries for experiences
- **Modern UI**: Material Design 3 with custom theming and responsive layouts
- **Offline-First Architecture**: Full offline support with local SQLite database using Drift
- **Smart Data Sync**: Multi-layer caching strategy (Firebase Cache → Local DB → Firebase Server)
- **Battery Efficient**: Intelligent background sync without periodic polling
- **Connectivity Awareness**: Real-time network status monitoring with offline indicators
- **Pull-to-Refresh**: Swipe down to manually refresh experiences from server
- **Multi-Currency Support**: Choose your preferred currency with daily exchange rate updates
- **Smart Price Display**: Automatic conversion of all prices to selected currency
- **Local Media Storage**: All photos (profile and experience) saved to accessible "Travel Connect" folder

## 🏗️ Project Structure

```
lib/
├── app/                    # App configuration and routing
│   ├── app.dart           # Main app widget
│   └── router.dart        # GoRouter configuration
├── database/              # Local persistence layer
│   ├── app_database.dart  # Drift database schema & DAOs
│   └── database_converters.dart  # Model converters
├── features/              # Feature-based organization
│   ├── auth/              # Authentication features
│   ├── create/            # Experience creation
│   ├── experience/        # Experience details
│   ├── explore/           # Discovery and browsing
│   ├── map/               # Map functionality
│   └── profile/           # User profiles
├── models/                # Domain models
│   ├── experience.dart    # Experience model
│   └── host.dart          # User/Host model
├── services/              # Business logic & data services
│   ├── experience_service.dart  # Experience data with offline-first
│   ├── host_service.dart        # User/Host data with offline-first
│   ├── profile_picture_service.dart # Profile picture upload & storage
│   ├── image_processing_service.dart # Image compression with isolates
│   ├── currency_service.dart    # Currency preferences & exchange rates
│   └── connectivity_service.dart # Network monitoring
├── theme/                 # Design system
│   ├── colors.dart        # Color palette
│   ├── theme.dart         # Material theme
│   └── typography.dart    # Text styles
├── widgets/               # Reusable UI components
│   ├── experience_card.dart
│   ├── filters_bottom_sheet.dart
│   └── main_scaffold.dart
├── mock/                  # Mock data for development
└── main.dart             # App entry point
```

## 🎨 Design System

### Color Palette

- **Forest Green** (`#1C3A13`) - Primary brand color
- **Earth Brown** (`#574F2A`) - Secondary brand color
- **Lava** (`#EC4E20`) - Accent color
- **Peach** (`#FEC0AA`) - Highlight color
- **Olive Gold** (`#84732B`) - Warning/info color

### Typography

- Uses Google Fonts for consistent typography
- Material Design 3 text scales
- Semantic text styles for different content types

## 🛠️ Development Guidelines

### Code Organization

1. **Feature-First Structure**: Code is organized by features rather than technical layers
2. **Widget Composition**: Prefer composition over inheritance
3. **Const Constructors**: Use `const` constructors for performance optimization
4. **Immutable Widgets**: Keep widgets stateless when possible

### Coding Standards

1. **Naming Conventions**:

   - Use `camelCase` for variables and functions
   - Use `PascalCase` for classes and enums
   - Use `snake_case` for file names
   - Use descriptive names that clearly indicate purpose

2. **File Organization**:

   - One class per file (with exceptions for small helper classes)
   - Import statements organized: Flutter → Third-party → Local
   - Group imports with empty lines between groups

3. **Widget Guidelines**:

   - Use `const` constructors wherever possible
   - Prefer `StatelessWidget` over `StatefulWidget` when state is not needed
   - Extract reusable widgets into separate files
   - Use meaningful widget names that describe their purpose

4. **State Management**:
   - Currently using built-in Flutter state management
   - Keep state as low in the widget tree as possible
   - Use callbacks to communicate between parent and child widgets

### Performance Best Practices

1. **Color Opacity**: Use `Color.withValues()` instead of deprecated `withOpacity()`
2. **Const Usage**: Apply `const` to constructors and widgets that don't change
3. **Asset Optimization**: Use appropriate image formats and sizes
4. **Widget Rebuilds**: Minimize unnecessary widget rebuilds

### Navigation

- Uses **GoRouter** for declarative routing
- Supports nested navigation with shell routes
- Type-safe route parameters
- Centralized route configuration in `app/router.dart`

### Offline-First Architecture

The app implements a sophisticated multi-layer caching strategy for optimal performance and offline support:

#### Data Flow Strategy

1. **Firebase Cache** (In-Memory, Fastest)

   - First check for data in Firebase's local cache
   - Instant response for recently accessed data
   - Automatically managed by Firebase SDK

2. **Local SQLite Database** (Persistent, Offline)

   - Drift-based relational database for long-term storage
   - Stores `Experiences` and `Users` tables
   - Works completely offline
   - Automatically synced from Firebase cache/server

3. **Firebase Server** (Network, Authoritative)
   - Fetches latest data when online
   - Updates both cache and local database
   - Background refresh doesn't block UI

#### Key Design Principles

- **No Periodic Polling**: The app never polls Firebase every N minutes to save battery
- **Smart Sync**: Data flows from cache → local DB → server in a waterfall pattern
- **Background Updates**: Server refreshes happen in background without blocking UI
- **Dirty Flag**: Tracks local changes that need to be synced to Firebase
- **Isolate-Ready**: Database operations are async and can run on background isolates

#### Database Schema

**Experiences Table**

- Core fields: id, title, summary, hostId, location (lat/lng), department
- Ratings: avgRating, reviewsCount, hostVerified
- Details: duration, priceCOP, groupSizeMax
- Arrays (JSON): skillsToLearn, skillsToTeach, categories, languages, paymentOptions, images
- Metadata: createdAt, lastSyncedAt, isDirty, isActive

**Users Table**

- Core fields: id, name, email, photoURL
- Ratings: avgHostRating, isVerified
- Profile: about, languages (JSON), responseRate
- Stats: hostedExperiences, joinedExperiences
- Metadata: memberSince, lastSyncedAt, isDirty

#### Service Layer Architecture

- `ExperienceService`: Implements 3-layer fetching for experiences
- `HostService`: Implements 3-layer fetching for users/hosts
- `DatabaseConverters`: Transforms between Firestore, Drift, and Domain models
- `AppDatabase`: Provides CRUD operations and queries for both tables

### Routes Structure:

- `/login` - Authentication screen
- `/discover` - Main discovery screen (home) with search and filters
- `/map` - Map view of experiences (supports query params: `?lat=<latitude>&lng=<longitude>` for centering)
- `/create` - Create new experience with location picker and photo upload
- `/my-experiences` - View and manage user's created experiences
- `/profile/:id` - User profile (dynamic routing)
- `/experience/:id` - Experience details with full information
- `/experience/:id/edit` - Edit existing experience

### Key Navigation Flows:

1. **Experience Creation**: After successfully creating an experience, users are redirected to `/my-experiences`
2. **Map Integration**: Detail pages can link to map view with specific coordinates using query parameters
3. **Keyboard Handling**: Search interfaces automatically dismiss keyboard on tap-outside or clear actions

## 🔧 Setup Instructions

### Prerequisites

- Flutter SDK (>=3.0.0 <4.0.0)
- Dart SDK
- Android Studio / Xcode for platform-specific development
- VS Code with Flutter extension (recommended)

### Installation

1. **Clone the repository**:

   ```bash
   git clone https://github.com/ISIS3510-G34-S3/Flutter-G34.git
   cd Flutter-G34
   ```

2. **Install dependencies**:

   ```bash
   flutter pub get
   ```

3. **Generate Drift database code**:

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Verify setup**:

   ```bash
   flutter doctor
   ```

5. **Run the app**:
   ```bash
   flutter run
   ```

### Development Setup

1. **Code Analysis**:

   ```bash
   flutter analyze
   ```

2. **Run Tests**:

   ```bash
   flutter test
   ```

3. **Format Code**:

   ```bash
   dart format .
   ```

4. **Regenerate Drift Code** (after schema changes):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

## 📦 Dependencies

### Production Dependencies

- **flutter**: Flutter SDK
- **cupertino_icons**: iOS-style icons
- **go_router**: Declarative routing
- **google_fonts**: Custom typography
- **flutter_svg**: SVG asset support
- **intl**: Internationalization support
- **google_maps_flutter**: Interactive maps
- **geolocator**: Location services
- **location**: Device location tracking
- **firebase_core**: Firebase initialization
- **firebase_auth**: User authentication
- **cloud_firestore**: Cloud database
- **firebase_storage**: File storage
- **google_sign_in**: Google OAuth
- **http**: HTTP client
- **image_picker**: Camera/gallery access
- **drift**: Local SQLite database ORM
- **sqlite3_flutter_libs**: SQLite native libraries
- **path_provider**: App directories access
- **path**: File path utilities
- **cached_network_image**: Network image caching
- **connectivity_plus**: Network connectivity monitoring

### Development Dependencies

- **flutter_test**: Testing framework
- **flutter_lints**: Linting rules
- **drift_dev**: Drift code generator
- **build_runner**: Code generation runner

## 🧪 Testing

- Unit tests for business logic
- Widget tests for UI components
- Integration tests for user flows
- Run tests with: `flutter test`

## 📱 Platform Support

- **Android**: API level 21+ (Android 5.0+)
- **iOS**: iOS 12.0+
- **Web**: Modern browsers (Chrome, Firefox, Safari, Edge)
- **Windows**: Windows 10+

## 🚀 Deployment

### Android

```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

## 📋 Development Workflow

1. **Branch Creation**: Create feature branches from `main`
2. **Code Changes**: Follow coding standards and guidelines
3. **Testing**: Ensure all tests pass
4. **Code Review**: Submit pull requests for review
5. **Deployment**: Merge to main after approval

## 🔍 Troubleshooting

### Common Issues

1. **Build Errors**: Run `flutter clean && flutter pub get`
2. **Hot Reload Issues**: Restart the app with `R` in terminal
3. **Dependency Conflicts**: Check `pubspec.yaml` for version conflicts
4. **Platform Issues**: Run `flutter doctor` to check platform setup

### System UI Issues

- Status bar colors require hot restart (not just hot reload)
- System UI overlay settings are configured in `app.dart` and `theme.dart`

## 🤝 Contributing

1. Follow the established project structure
2. Adhere to coding standards and guidelines
3. Write tests for new features
4. Update documentation as needed
5. Submit pull requests with clear descriptions

## 📄 License

This project is developed for educational purposes as part of the Mobile Development course at Universidad de los Andes.

## 👥 Team

**Group 34 - ISIS3510**

- Mobile Development Course
- Universidad de los Andes

---

For more information about Flutter development, visit the [Flutter documentation](https://docs.flutter.dev/).

## ⚡ Quick facts

- Repository name: `Flutter-G34`
- Package (pub) name: `travel_connect`
- Current app version: `1.0.0+1`
- Dart SDK constraint: `>=3.0.0 <4.0.0`
- Current branch: `sarenasr` (development branch used in this workspace)

## 🎯 Recent Enhancements

### Enterprise-Grade Connectivity (Nov 2025)

- **Airplane Mode Detection**: HTTP reachability testing works even with WiFi in airplane mode
- **Smart Retry Logic**: Exponential backoff (1s, 2s) with 5-second timeouts per request
- **Dual-Layer Verification**: Device state check + quick HTTP ping to Google, then parallel checks to Cloudflare/Amazon
- **Optimistic Start**: Assumes online initially for better UX, verifies in background
- **Offline-First Integration**: Respects existing 3-layer caching (Firebase cache → Local DB → Firebase server)
- **Smart Protection**: ConnectivityAware mixin checks before online operations (booking, messaging, CRUD) while allowing cached data access
- **Consistent UI Across App**: All screens use the same subtle olive-gold banner style from Discover screen - "No internet connection - using offline data"
- **Soft Offline Blocker**: When blocking is needed, shows friendly "Connection needed" message with subtle olive-gold colors (no harsh red)
- **Friendly Feedback**: Rounded floating snackbars with soft colors for action-specific warnings

### Experience Detail Screen

- **Comprehensive Information Display**: Added price formatting (e.g., "120K COP"), duration, max group size, and categories
- **Host Profile Integration**: Displays host name, avatar, verification badge, and links to full profile
- **Photo Gallery**: Multi-image swipeable gallery with page indicators
- **Location Integration**: "View on Map" button that centers map on experience coordinates
- **Reviews Summary**: Shows average rating and review count with navigation to reviews

### Create Experience Flow

- **Default Selections**: Pre-selects Spanish language and cash payment for faster creation
- **Location Picker Enhancement**: Visual confirmation with pin icon and coordinate display
- **Navigation Fix**: Automatically redirects to "My Experiences" after successful creation
- **Photo Upload**: Firebase Storage integration for experience images

### Map Integration

- **Deep Linking**: Accepts `lat` and `lng` query parameters to center on specific coordinates
- **Auto-selection**: Automatically selects nearby experience when centering on coordinates
- **Enhanced UX**: Smooth camera animations and location-based filtering

### UI/UX Improvements

- **Keyboard Handling**: Fixed overflow issues in Discover screen with keyboard-aware layouts
- **Consistent Typography**: Improved text color consistency across My Experiences screen
- **Responsive Design**: Better handling of various screen sizes and orientations

## 🔐 Firebase configuration (project-specific)

This project uses Firebase for core services (Auth, Firestore, Storage). The repository already includes generated Firebase configuration helpers:

- `lib/firebase_options.dart` — generated Firebase options used at app startup (imported by `lib/main.dart`).
- `android/app/google-services.json` — Android configuration file (the workspace contains a `google-services.json` under the `android/app/` directory).
- `firebase.json` — FlutterFire helper that maps platforms to project/app IDs.

Firebase identifiers found in this workspace (do not share secrets):

- Firebase projectId: `travelappbd-8e204`
- Android appId: `1:994400477277:android:d19bd770bd131911a06db4`
- Web appId: `1:994400477277:web:f8a4170404a96586a06db4`

If you need to set up Firebase locally for development or CI, install and run the Firebase CLI and follow the FlutterFire documentation to regenerate `firebase_options.dart` and download platform config files:

1. Install FlutterFire CLI and Firebase CLI (if needed) and log in.
2. Run `flutterfire configure` from the project root and follow prompts.
3. Place the downloaded `google-services.json` in `android/app/` and the `GoogleService-Info.plist` in `ios/Runner` if you target iOS.

Note: `lib/main.dart` initializes Firebase using `DefaultFirebaseOptions.currentPlatform`; keep `firebase_options.dart` checked into the repo for consistent environment settings.

## 🧰 Environment & toolchain

- Required: Flutter SDK (tested with Flutter 3.x+), Dart matching the SDK constraint in `pubspec.yaml`.
- Android: Android SDK + emulator or device; `local.properties` should point to the Android SDK path for local development.
- Desktop/web: the project includes web and Windows folders — ensure you have the platform toolchains if you plan to build for those targets.

## 📦 Exact dependency versions (from `pubspec.yaml`)

The app depends on the following notable packages (versions pinned in `pubspec.yaml`):

- go_router: ^13.2.0
- google_fonts: ^6.1.0
- flutter_svg: ^2.0.9
- intl: ^0.19.0
- google_maps_flutter: ^2.13.1
- geolocator: ^14.0.2
- location: ^8.0.1
- firebase_core: ^3.0.0
- firebase_auth: ^5.0.0
- cloud_firestore: ^5.0.0
- google_sign_in: ^6.2.1
- http: ^1.2.1
- image_picker: ^1.0.7
- firebase_storage: ^12.0.0
- drift: ^2.20.3
- sqlite3_flutter_libs: ^0.5.24
- path_provider: ^2.1.4
- path: ^1.9.0
- cached_network_image: ^3.4.1
- connectivity_plus: ^6.0.5

Run `flutter pub get` to install them.

## ▶️ Helpful commands (Windows PowerShell examples)

```powershell
# Get dependencies
flutter pub get

# Generate Drift database code (required after schema changes)
dart run build_runner build --delete-conflicting-outputs

# Run on connected device or default platform
flutter run

# Run with a specific device id (list devices first)
flutter devices; flutter run -d <deviceId>

# Build release APK
flutter build apk --release

# Build web release
flutter build web --release

# Clean build artifacts
flutter clean; flutter pub get

# Static analysis and formatting
flutter analyze
dart format .
flutter test

# Watch mode for continuous code generation during development
dart run build_runner watch --delete-conflicting-outputs
```

## 📁 Important files & locations

- `lib/main.dart` — App entry point and Firebase initialization
- `lib/app/app.dart` — Top-level app widget
- `lib/app/router.dart` — Route definitions (uses GoRouter)
- `lib/database/app_database.dart` — Local SQLite database schema (Drift)
- `lib/database/database_converters.dart` — Model conversion utilities
- `lib/services/experience_service.dart` — Experience data service with offline-first
- `lib/services/host_service.dart` — User/Host data service with offline-first
- `lib/services/profile_picture_service.dart` — Profile picture upload and management
- `lib/services/image_processing_service.dart` — Image compression using isolates
- `lib/firebase_options.dart` — Generated Firebase config
- `android/app/google-services.json` — Android Firebase config
- `build.yaml` — Drift code generation configuration

### Local Media Storage Locations

**Android**: `/storage/emulated/0/Pictures/Travel Connect/`

- Profile pictures: `profile_{userId}_{timestamp}.jpg`
- Experience photos: `photo_{timestamp}.jpg`

**iOS**: `<AppDocuments>/Travel Connect/`

- Same naming convention as Android

**Other Platforms**: `<AppDocuments>/Travel Connect/`

All uploaded images are automatically:

- Compressed using multi-threaded isolates
- Resized to optimal dimensions (profile: 1024x1024, experiences: 1920px width)
- Saved locally for offline access
- Uploaded to Firebase Storage
- Referenced in Firestore and local SQLite database

## ✅ Project notes / gotchas

- The project expects `firebase_options.dart` to be present. If you regenerate Firebase configuration for a new Firebase project, update that file and keep corresponding platform files (`google-services.json`, `GoogleService-Info.plist`) in place.
- Map features rely on `google_maps_flutter` and platform-specific API keys (ensure Android `AndroidManifest.xml` and iOS plist have proper API keys when enabling Maps).
- **Drift Code Generation**: After modifying database schema in `app_database.dart`, you must run `dart run build_runner build --delete-conflicting-outputs` to regenerate the `app_database.g.dart` file.
- The local SQLite database file is stored at `<AppDocumentsDirectory>/travel_connect.sqlite`.
- Database operations are async and safe for background execution on isolates.

## Contributors / Contact

This project was developed by Group 34 for the Mobile Development course at Universidad de los Andes. For questions about this repository, open an issue or contact the repository owner.
