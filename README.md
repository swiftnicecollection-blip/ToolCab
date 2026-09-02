# ToolCab

**All-in-One AI Productivity Toolkit**

ToolCab is a unified productivity application that brings everyday document, OCR, speech, translation, scanning, calendar, and file-management utilities into one fast, polished cross-platform application.

Built with **Flutter** and **GetX**, featuring a Material 3 design system with light and dark theme support.

---

## Overview

ToolCab solves the problem of needing multiple applications for common productivity tasks. Instead of switching between different apps for OCR, PDF management, speech-to-text, translation, and QR scanning, users can access all these tools from a single, unified interface.

### Why ToolCab?

- **Simplicity** — One app for multiple productivity needs
- **Speed** — Quick access to frequently used tools
- **Privacy** — Local processing where possible
- **Cross-platform** — Works on Web and Android
- **Unified UX** — Consistent design language across all tools

---

## Problem

Users often need multiple applications for:

- Document OCR and text extraction
- PDF creation, merging, splitting, and compression
- Speech-to-text dictation
- Text-to-speech playback
- Language translation
- QR code scanning
- Calendar and event management
- File sharing and export

Switching between multiple apps reduces productivity and creates friction in everyday workflows.

---

## Solution

ToolCab combines these workflows into one application with:

- **Local-first processing** — Many features work offline or with on-device ML
- **Intuitive navigation** — Clean home screen with quick access to all tools
- **Consistent experience** — Uniform design patterns across all features
- **Responsive design** — Works on phones, tablets, and web browsers

---

## Features

| Feature | Description | Processing | Status |
|---------|-------------|------------|--------|
| Text → Audio | Convert text to speech playback | Local (TTS) | Implemented |
| Audio → Text | Speech-to-text recognition | Platform service | Implemented |
| Language Translator | Translate text between languages | ML Kit (on-device after model download) | Implemented |
| Image → Text (OCR) | Extract text from images | ML Kit | Implemented |
| Calendar | Event creation and management | Local (Hive) | Implemented |
| QR Code Scanner | Scan QR codes from images | ML Kit | Implemented |
| Text → PDF | Generate PDF documents from text | Local | Implemented |
| PDF → Text | Extract text from PDF files | Local | Implemented |
| Merge PDFs | Combine multiple PDFs into one | Local | Implemented |
| Split PDFs | Extract pages from PDF files | Local | Implemented |
| Compress PDF | Reduce PDF file size | Local | Implemented |
| History | Track recent activity | Local (Hive) | Implemented |
| Favorites | Save preferred translations | Local (Hive) | Implemented |
| Share/Export | Share content via system share | Platform | Implemented |
| Dark/Light Mode | Theme customization | Local | Implemented |

---

## Technology Stack

| Technology | Purpose |
|------------|---------|
| Flutter | Cross-platform UI framework |
| Dart | Programming language |
| GetX | State management, routing, dependency injection |
| Material 3 | Design system |
| Google ML Kit | On-device translation, OCR, QR scanning |
| Hive | Local storage (settings, history, calendar) |
| speech_to_text | Speech recognition |
| flutter_tts | Text-to-speech playback |
| pdf | PDF generation and manipulation |
| pdfx | PDF viewing and parsing |
| share_plus | System share functionality |
| permission_handler | Runtime permissions |
| google_fonts | Typography |
| intl | Internationalization and formatting |
| url_launcher | External link handling |
| image_picker | Image selection from gallery |
| file_picker | File selection from device |

---

## Architecture

ToolCab follows a feature-based architecture with clear separation of concerns:

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
│   │   ├── compress_pdf/   # PDF compression
│   │   ├── merge_pdf/      # PDF merging
│   │   ├── ocr/            # OCR text extraction
│   │   ├── pdf/            # PDF tools dashboard
│   │   ├── pdf_to_text/    # PDF text extraction
│   │   ├── qr_scanner/     # QR code scanning
│   │   ├── split_pdf/      # PDF splitting
│   │   ├── stt/            # Speech-to-text
│   │   ├── translator/     # Language translation
│   │   └── tts/            # Text-to-speech
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

### Layer Responsibilities

| Layer | Components | Responsibility |
|-------|------------|----------------|
| **Presentation** | Views, Widgets | UI rendering, user interaction |
| **State Management** | Controllers | Business logic orchestration, reactive state |
| **Domain** | Models, Repositories | Data structures, data access patterns |
| **Data** | Services, Storage | External APIs, local persistence |

---

## Installation

### Prerequisites

- Flutter SDK `>=3.3.0`
- Dart SDK `>=3.3.0`
- Chrome browser (for web) or Android device/emulator

### Setup

```bash
# 1. Clone the repository
git clone https://github.com/yourorg/toolcab.git
cd toolcab

# 2. Install dependencies
flutter pub get

# 3. Run the application
flutter run
```

---

## Platform Support

### Web (Chrome)

```bash
flutter run -d chrome
```

**Working features on Web:**
- All PDF tools (merge, split, compress, text-to-PDF, PDF-to-text)
- Text-to-speech (uses browser TTS)
- Calendar and event management
- History and favorites
- Settings and theme switching
- Responsive layout

**Platform limitations on Web:**
- Speech-to-text: Limited browser support
- OCR: Requires image file upload
- QR scanner: Requires image file upload (no camera)
- Translation: Requires model download

### Android

```bash
flutter run
```

Build release APK:
```bash
flutter build apk --release
```

**Required permissions:**
- Camera — For QR scanning
- Microphone — For speech-to-text
- Storage — For file access and saving

### iOS

iOS runtime/build verification requires macOS and Xcode. The project has not been tested on iOS.

---

## Permissions

| Permission | Purpose | Required For |
|------------|---------|--------------|
| Camera | QR code scanning | QR Scanner |
| Microphone | Speech input | Speech-to-Text |
| Storage/Photos | File and image access | OCR, PDF tools, QR Scanner |

---

## Offline & Privacy

**Local processing:**
- PDF operations (merge, split, compress, generate) work fully offline
- Calendar and history data stored locally via Hive
- Theme and settings preferences stored locally

**Network-dependent features:**
- Translation requires initial model download (works offline after)
- OCR and QR scanning use on-device ML (no network required after initial setup)

**Privacy:**
- No user accounts or authentication
- No data uploaded to external servers
- User files remain on device
- No analytics or tracking

---

## Testing

### Automated Tests

```bash
# Run static analysis
flutter analyze

# Run unit tests
flutter test
```

**Current status:**
- `flutter analyze`: 0 errors
- `flutter test`: 10 tests passing

### Manual Testing

- Chrome: Verified working
- Android: Build verified (device testing recommended)

---

## Performance

- **Lazy initialization** — Controllers and services load on demand
- **Efficient list rendering** — Optimized for large file lists
- **Controller lifecycle management** — Automatic disposal of resources
- **Responsive design** — Adapts to different screen sizes

---

## Error Handling

The application handles:
- Permission denials with user guidance
- Invalid or corrupt file selection
- Network failures for model downloads
- Storage access issues
- Unsupported platform features
- User cancellation of operations

---

## Security

- No passwords or authentication tokens stored
- No API credentials committed to repository
- No unnecessary upload of user documents
- No hardcoded secrets
- Local-only data storage

---

## Development

### Code Style

```bash
# Format code
dart format .

# Run static analysis
flutter analyze

# Run tests
flutter test
```

### Branch Naming

- `feature/` — New features
- `fix/` — Bug fixes
- `docs/` — Documentation updates
- `refactor/` — Code refactoring

---

## Hackathon

ToolCab was developed as a submission for **SHIPATHON** — a worldwide hackathon.

See [docs/HACKATHON.md](docs/HACKATHON.md) for more details.

---

## Screenshots

Screenshots can be added to the `screenshots/` directory.

Recommended captures:
- Home dashboard
- OCR tool
- PDF tools dashboard
- Translator
- Calendar
- QR Scanner
- History
- Settings

---

## Demo

Suggested demo flow:

1. Launch ToolCab
2. View onboarding flow
3. Navigate home dashboard
4. Open OCR and extract text from an image
5. Convert text to PDF
6. Open PDF tools (merge/split/compress)
7. Use Translator
8. Scan a QR code from an image
9. Create a calendar event
10. View History
11. Toggle Dark Mode

---

## License

ToolCab © 2026. All rights reserved.
