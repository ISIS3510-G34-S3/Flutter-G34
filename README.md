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
- **Photo Galleries**: Swipeable image galleries for experiences
- **Modern UI**: Material Design 3 with custom theming and responsive layouts

## 🏗️ Project Structure

```
lib/
├── app/                    # App configuration and routing
│   ├── app.dart           # Main app widget
│   └── router.dart        # GoRouter configuration
├── features/              # Feature-based organization
│   ├── auth/              # Authentication features
│   ├── create/            # Experience creation
│   ├── experience/        # Experience details
│   ├── explore/           # Discovery and browsing
│   ├── map/               # Map functionality
│   └── profile/           # User profiles
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

3. **Verify setup**:

   ```bash
   flutter doctor
   ```

4. **Run the app**:
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

## 📦 Dependencies

### Production Dependencies

- **flutter**: Flutter SDK
- **cupertino_icons**: iOS-style icons
- **go_router**: Declarative routing
- **google_fonts**: Custom typography
- **flutter_svg**: SVG asset support
- **intl**: Internationalization support

### Development Dependencies

- **flutter_test**: Testing framework
- **flutter_lints**: Linting rules

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

Run `flutter pub get` to install them.

## ▶️ Helpful commands (Windows PowerShell examples)

```powershell
# Get dependencies
flutter pub get

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
```

## 📁 Important files & locations

- `lib/main.dart` — App entry point and Firebase initialization
- `lib/app/app.dart` — Top-level app widget
- `lib/app/router.dart` — Route definitions (uses GoRouter)
- `lib/firebase_options.dart` — Generated Firebase config
- `android/app/google-services.json` — Android Firebase config

## ✅ Project notes / gotchas

- The project expects `firebase_options.dart` to be present. If you regenerate Firebase configuration for a new Firebase project, update that file and keep corresponding platform files (`google-services.json`, `GoogleService-Info.plist`) in place.
- Map features rely on `google_maps_flutter` and platform-specific API keys (ensure Android `AndroidManifest.xml` and iOS plist have proper API keys when enabling Maps).

## Contributors / Contact

This project was developed by Group 34 for the Mobile Development course at Universidad de los Andes. For questions about this repository, open an issue or contact the repository owner.
