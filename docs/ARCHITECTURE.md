# Architecture

This document describes the technical architecture of ToolCab.

## Overview

ToolCab follows a **feature-based architecture** with clear separation of concerns. Each feature module is self-contained with its own controllers, services, repositories, and views.

## Project Structure

```
lib/
├── app/                    # Application configuration
│   ├── app.dart            # Root MaterialApp widget
│   ├── bindings/           # Global dependency bindings
│   └── routes/             # Route definitions
├── core/                   # Shared core functionality
│   ├── config/             # App configuration
│   ├── constants/          # Constants and enums
│   ├── services/           # Core services (storage, theme, navigation)
│   ├── theme/              # Design system (colors, typography, spacing)
│   └── utils/              # Utility functions
├── features/               # Feature modules
│   ├── tools/              # Productivity tools
│   ├── calendar/           # Calendar and events
│   ├── history/            # Activity history
│   ├── home/               # Home dashboard
│   ├── onboarding/         # First-launch onboarding
│   ├── settings/           # App settings
│   └── splash/             # Splash screen
├── shared/                 # Reusable UI components
│   └── widgets/            # Buttons, cards, inputs, feedback
└── main.dart               # Application entry point
```

## Layer Responsibilities

### Presentation Layer

**Components:** Views, Widgets

**Responsibility:** UI rendering and user interaction

**Key Files:**
- `lib/features/*/view/*.dart` — Screen implementations
- `lib/features/*/widgets/*.dart` — Feature-specific widgets
- `lib/shared/widgets/**/*.dart` — Reusable UI components

### State Management Layer

**Components:** Controllers

**Responsibility:** Business logic orchestration and reactive state

**Key Files:**
- `lib/features/*/controller/*.dart` — Feature controllers

**Pattern:**
- Controllers extend `GetxController`
- Use reactive observables (`Rx<T>`) for state
- Lifecycle managed by GetX bindings

### Domain Layer

**Components:** Models, Repositories

**Responsibility:** Data structures and data access patterns

**Key Files:**
- `lib/features/*/data/models/*.dart` — Data models
- `lib/features/*/data/repositories/*.dart` — Data access contracts

### Data Layer

**Components:** Services, Storage

**Responsibility:** External APIs, local persistence, platform services

**Key Files:**
- `lib/features/*/service/*.dart` — Feature services
- `lib/core/services/*.dart` — Core services

## State Management

ToolCab uses **GetX** for state management:

```dart
// Controller example
class HomeController extends GetxController {
  final RxBool isLoading = RxBool(false);
  final RxList<RecentFileItem> recentFiles = RxList<RecentFileItem>();

  void loadRecentFiles() {
    isLoading.value = true;
    // Load files...
    isLoading.value = false;
  }
}
```

## Navigation

Navigation uses **GetX routing** with declarative route definitions:

```dart
// Route definition
GetPage<dynamic>(
  name: AppRoutes.home,
  page: () => const HomeView(),
  binding: HomeBinding(),
  transition: Transition.fadeIn,
)
```

## Dependency Injection

GetX bindings manage dependency injection:

```dart
// Binding example
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RecentFilesRepository>(RecentFilesRepository.new);
    Get.lazyPut<HomeController>(HomeController.new);
  }
}
```

## Local Storage

**Hive** is used for local persistence:

- Settings and preferences
- Activity history
- Calendar events
- Onboarding state
- Cached data

```dart
// Storage initialization
await StorageService.instance.init();
```

## Feature Pipelines

### PDF Processing Pipeline

1. User selects PDF file(s) via `file_picker`
2. Service processes PDF using `pdf` package
3. Result saved to device storage
4. History entry created

### OCR Pipeline

1. User selects image via `image_picker`
2. ML Kit processes image for text extraction
3. Extracted text displayed to user
4. Option to copy, save, or share

### Translation Pipeline

1. User enters text and selects languages
2. ML Kit checks for downloaded models
3. Models downloaded if needed (requires network)
4. Translation performed on-device
5. Result displayed with favorites option

### Speech Pipeline

1. User grants microphone permission
2. `speech_to_text` captures audio
3. Platform speech recognition processes audio
4. Transcribed text displayed

### QR Scanner Pipeline

1. User selects image via `image_picker`
2. ML Kit barcode scanning detects QR codes
3. Decoded content displayed
4. Actions available based on content type (URL, text, etc.)

### Calendar Pipeline

1. User creates event with date, title, description
2. Event stored locally in Hive
3. Calendar view displays events by month
4. Events can be edited or deleted

### History Pipeline

1. Tool usage creates history entry
2. Entry stored in centralized `HistoryRepository`
3. History view displays entries with filtering
4. Entries can be cleared by user

## Error Handling

The application implements comprehensive error handling:

- **Permission errors** — User guidance to enable permissions
- **File errors** — Invalid/corrupt file detection
- **Network errors** — Graceful degradation for network-dependent features
- **Platform errors** — Feature availability checks

## Platform Considerations

| Feature | Web | Android | iOS |
|---------|-----|---------|-----|
| PDF Tools | Full | Full | Not tested |
| TTS | Browser TTS | Native | Not tested |
| STT | Limited | Full | Not tested |
| OCR | Image upload | Image upload | Not tested |
| Translator | With model download | With model download | Not tested |
| QR Scanner | Image upload | Image upload | Not tested |
| Calendar | Full | Full | Not tested |
| History | Full | Full | Not tested |
