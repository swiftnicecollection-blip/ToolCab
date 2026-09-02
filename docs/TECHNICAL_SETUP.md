# Technical Setup

This document provides detailed technical setup instructions for ToolCab.

## Prerequisites

### Required

- **Flutter SDK** `>=3.3.0`
- **Dart SDK** `>=3.3.0`
- **Git**

### Platform-Specific

#### Web
- Chrome browser (latest version recommended)

#### Android
- Android Studio or Android SDK
- Android device or emulator (API 21+)

#### iOS (not tested)
- macOS with Xcode 14+
- iOS device or simulator

## Flutter Version

ToolCab requires Flutter `>=3.3.0`. Check your version:

```bash
flutter --version
```

If you need to install or update Flutter, visit [flutter.dev](https://flutter.dev/docs/get-started/install).

## Environment Setup

### 1. Clone the Repository

```bash
git clone https://github.com/yourorg/toolcab.git
cd toolcab
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Verify Setup

```bash
flutter doctor
```

Resolve any issues reported by `flutter doctor` before proceeding.

## Dependencies

### Core Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `get` | ^4.6.6 | State management, routing, DI |
| `google_fonts` | ^6.2.1 | Typography |
| `intl` | ^0.19.0 | Internationalization |

### Storage

| Package | Version | Purpose |
|---------|---------|---------|
| `hive_flutter` | ^1.1.0 | Local database |
| `path_provider` | ^2.1.3 | File system paths |

### Permissions & Sharing

| Package | Version | Purpose |
|---------|---------|---------|
| `permission_handler` | ^11.3.1 | Runtime permissions |
| `share_plus` | ^12.0.2 | System share |

### Speech

| Package | Version | Purpose |
|---------|---------|---------|
| `speech_to_text` | ^6.6.2 | Speech recognition |
| `flutter_tts` | ^4.0.2 | Text-to-speech |

### ML/AI

| Package | Version | Purpose |
|---------|---------|---------|
| `google_ml_kit` | ^0.18.0 | OCR, translation, QR scanning |

### File Handling

| Package | Version | Purpose |
|---------|---------|---------|
| `image_picker` | ^1.1.2 | Image selection |
| `file_picker` | ^8.0.0 | File selection |

### PDF

| Package | Version | Purpose |
|---------|---------|---------|
| `pdf` | ^3.11.1 | PDF generation |
| `pdfx` | ^2.6.0 | PDF viewing/parsing |

### Utilities

| Package | Version | Purpose |
|---------|---------|---------|
| `url_launcher` | ^6.2.6 | External links |

## Running the Application

### Web (Chrome)

```bash
flutter run -d chrome
```

### Android

Connect a device or start an emulator, then:

```bash
flutter run
```

### iOS (not tested)

```bash
flutter run -d ios
```

## Building for Release

### Web

```bash
flutter build web --release
```

Output: `build/web/`

### Android

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

## Testing

### Run All Tests

```bash
flutter test
```

### Run Specific Test

```bash
flutter test test/core/utils/validators_test.dart
```

### Static Analysis

```bash
flutter analyze
```

### Code Formatting

```bash
dart format .
```

## Troubleshooting

### Common Issues

#### Flutter Version Mismatch

**Error:** `Requires Flutter SDK version >=3.3.0`

**Solution:** Update Flutter:
```bash
flutter upgrade
```

#### Dependency Resolution Failed

**Error:** `version solving failed`

**Solution:**
```bash
flutter pub cache repair
flutter pub get
```

#### Build Failed on Web

**Error:** Compilation errors

**Solution:**
```bash
flutter clean
flutter pub get
flutter build web
```

#### Hive Initialization Failed

**Error:** Storage-related errors

**Solution:** Ensure `path_provider` is properly configured for your platform.

### Platform-Specific Issues

#### Android

- Ensure Android SDK is installed and configured
- Accept Android licenses: `flutter doctor --android-licenses`
- Enable USB debugging for device testing

#### Web
- Use Chrome for best compatibility
- Some features have limited browser support

## Development Commands

| Command | Purpose |
|---------|---------|
| `flutter pub get` | Install dependencies |
| `flutter run` | Run the app |
| `flutter test` | Run tests |
| `flutter analyze` | Static analysis |
| `dart format .` | Format code |
| `flutter clean` | Clean build artifacts |
| `flutter pub outdated` | Check for outdated packages |

## Environment Variables

ToolCab does not require any environment variables or API keys for basic functionality.

## CI/CD Considerations

For continuous integration:

```bash
# Install dependencies
flutter pub get

# Run analysis
flutter analyze

# Run tests
flutter test

# Build for target platform
flutter build web --release
# or
flutter build apk --release
```
