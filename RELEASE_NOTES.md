# Release Notes

# ToolCab — Hackathon Release

**Version:** 1.0.0+1

**Release Date:** August 2026

---

## Overview

ToolCab is a unified productivity toolkit that brings everyday document, OCR, speech, translation, scanning, calendar, and file-management utilities into one fast, polished cross-platform application.

---

## Core Features

### Document Tools
- **Text → Audio** — Convert text to speech playback
- **Audio → Text** — Speech-to-text recognition
- **Language Translator** — On-device translation using Google ML Kit
- **Image → Text (OCR)** — Extract text from images
- **QR Code Scanner** — Decode QR codes from images

### PDF Tools
- **Text → PDF** — Generate PDF documents from text
- **PDF → Text** — Extract text from PDF files
- **Merge PDFs** — Combine multiple PDFs into one
- **Split PDFs** — Extract specific pages from PDFs
- **Compress PDF** — Reduce PDF file size

### Utilities
- **Calendar** — Create and manage events
- **History** — Track recent activity
- **Favorites** — Save preferred translations
- **Share/Export** — Share content via system share

---

## UI/UX

- Material 3 design system
- Light and dark theme support
- Responsive layout for phones, tablets, and web
- Onboarding flow for first-time users
- Consistent navigation patterns

---

## Performance

- Lazy initialization of controllers and services
- Efficient list rendering
- Automatic resource disposal
- Optimized for cross-platform performance

---

## Testing

| Test | Result |
|------|--------|
| flutter analyze | 0 errors |
| flutter test | 10/10 passed |
| Web build | Success |
| Chrome run | Success |

---

## Platform Support

| Platform | Status |
|----------|--------|
| Web (Chrome) | ✅ Supported |
| Android | ✅ Supported (SDK required for build) |
| iOS | ⚠️ Not tested (requires macOS/Xcode) |

---

## Known Limitations

- **Web:** Speech-to-text has limited browser support
- **Web:** OCR and QR scanner require image upload (no camera)
- **Web:** Translation requires initial model download
- **iOS:** Not tested — requires macOS and Xcode
- **Android:** APK build requires Android SDK (not available in current environment)

---

## How to Install

### Web

```bash
flutter run -d chrome
```

### Android

```bash
flutter build apk --release
```

APK location: `build/app/outputs/flutter-apk/app-release.apk`

### Prerequisites

- Flutter SDK >=3.3.0
- Dart SDK >=3.3.0

---

## GitHub Information

Repository: [ToolCab](https://github.com/yourorg/toolcab)

---

## License

ToolCab © 2026. All rights reserved.
