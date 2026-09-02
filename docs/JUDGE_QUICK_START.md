# Judge Quick Start

This document helps judges quickly understand and evaluate ToolCab.

---

## What is ToolCab?

ToolCab is a unified productivity toolkit that brings everyday document, OCR, speech, translation, scanning, calendar, and file-management utilities into one cross-platform application.

**Built with:** Flutter, GetX, Google ML Kit, Hive

---

## Why It Matters?

Users typically need multiple apps for common productivity tasks. ToolCab consolidates these workflows into a single, privacy-focused application with local processing.

---

## How to Run It

### Quick Start (Web)

```bash
# Clone the repository
git clone https://github.com/yourorg/toolcab.git
cd toolcab

# Install dependencies
flutter pub get

# Run on Chrome
flutter run -d chrome
```

### Build for Android

```bash
flutter build apk --release
```

APK location: `build/app/outputs/flutter-apk/app-release.apk`

---

## What to Test First

1. **Home Dashboard** — Navigate to all tools from the home screen
2. **OCR** — Upload an image and extract text
3. **PDF Tools** — Merge, split, or compress PDF files
4. **Translator** — Translate text between languages
5. **QR Scanner** — Scan a QR code from an image
6. **Calendar** — Create and manage events
7. **History** — View activity history
8. **Dark Mode** — Toggle theme in settings

---

## Recommended Demo Flow

| Step | Feature | What to Show |
|------|---------|--------------|
| 1 | Launch | Splash screen and onboarding |
| 2 | Home | Tool grid and navigation |
| 3 | OCR | Image upload and text extraction |
| 4 | PDF | Text-to-PDF generation |
| 5 | PDF Tools | Merge/split/compress operations |
| 6 | Translator | Language selection and translation |
| 7 | QR Scanner | QR code detection from image |
| 8 | Calendar | Event creation |
| 9 | History | Activity tracking |
| 10 | Settings | Dark mode toggle |

---

## Known Platform Limitations

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

**Note:** iOS has not been tested — requires macOS and Xcode.

---

## GitHub Structure

```
ToolCab/
├── lib/                    # Source code
│   ├── app/                # App configuration
│   ├── core/               # Shared functionality
│   ├── features/           # Feature modules
│   └── shared/             # Reusable widgets
├── test/                   # Unit tests
├── docs/                   # Documentation
├── assets/                 # Images and icons
├── README.md               # Project overview
├── CONTRIBUTING.md         # Contribution guidelines
├── CODE_OF_CONDUCT.md      # Code of conduct
├── SECURITY.md             # Security policy
├── CHANGELOG.md            # Version history
└── pubspec.yaml            # Dependencies
```

---

## Key Features

| Feature | Technology |
|---------|------------|
| Text → Audio | flutter_tts |
| Audio → Text | speech_to_text |
| Translator | Google ML Kit |
| OCR | Google ML Kit |
| QR Scanner | Google ML Kit |
| PDF Tools | pdf, pdfx |
| Calendar | Hive |
| History | Hive |
| State Management | GetX |
| Local Storage | Hive |

---

## Technical Highlights

- **0 errors** in `flutter analyze`
- **10 tests passing** in `flutter test`
- **Feature-based architecture** with clean separation
- **Local-first processing** for privacy
- **Material 3 design** with dark/light themes
- **Responsive UI** for phones, tablets, and web

---

## Contact

For questions or issues, please open an issue on the project repository.
