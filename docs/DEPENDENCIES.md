# Dependencies

This document lists all dependencies used in ToolCab.

---

## Core Dependencies

### get (^4.6.6)

**Purpose:** State management, routing, dependency injection

**Where used:** Throughout the application

**Platform considerations:** All platforms

---

### google_fonts (^6.2.1)

**Purpose:** Premium typography (Poppins, Inter fonts)

**Where used:** Theme configuration, text styling

**Platform considerations:** All platforms

---

### intl (^0.19.0)

**Purpose:** Internationalization and date/number formatting

**Where used:** Date formatting, number formatting

**Platform considerations:** All platforms

---

## Storage Dependencies

### hive_flutter (^1.1.0)

**Purpose:** Local database for persistent storage

**Where used:**
- Settings storage
- History storage
- Calendar events
- Onboarding state
- Cache storage

**Platform considerations:** All platforms

---

### path_provider (^2.1.3)

**Purpose:** Access to file system paths

**Where used:**
- Hive initialization
- File saving operations
- Temporary file storage

**Platform considerations:** All platforms

---

## Permissions & Sharing

### permission_handler (^11.3.1)

**Purpose:** Runtime permission management

**Where used:**
- Camera permission (QR Scanner)
- Microphone permission (STT)
- Storage permission (file operations)

**Platform considerations:** Android, iOS (not Web)

---

### share_plus (^12.0.2)

**Purpose:** System share functionality

**Where used:**
- Share translations
- Share OCR results
- Share scan results
- Share PDF files

**Platform considerations:** All platforms

---

## Speech Dependencies

### speech_to_text (^6.6.2)

**Purpose:** Speech recognition

**Where used:** Audio → Text feature

**Platform considerations:**
- Android: Full support
- iOS: Full support (not tested)
- Web: Limited browser support

---

### flutter_tts (^4.0.2)

**Purpose:** Text-to-speech synthesis

**Where used:** Text → Audio feature

**Platform considerations:**
- Android: Native TTS
- iOS: Native TTS (not tested)
- Web: Browser TTS

---

## ML/AI Dependencies

### google_ml_kit (^0.18.0)

**Purpose:** On-device machine learning

**Where used:**
- **Translator** — On-device translation with downloadable models
- **OCR** — Text recognition from images
- **QR Scanner** — Barcode scanning

**Platform considerations:**
- Android: Full support
- iOS: Full support (not tested)
- Web: Limited support (requires image upload)

---

## File Handling Dependencies

### image_picker (^1.1.2)

**Purpose:** Image selection from gallery or camera

**Where used:**
- OCR image selection
- QR Scanner image selection

**Platform considerations:** All platforms (Web requires file input)

---

### file_picker (^8.0.0)

**Purpose:** File selection from device storage

**Where used:**
- PDF file selection
- Document selection

**Platform considerations:** All platforms

---

## PDF Dependencies

### pdf (^3.11.1)

**Purpose:** PDF generation and manipulation

**Where used:**
- Text → PDF generation
- PDF merging
- PDF splitting
- PDF compression

**Platform considerations:** All platforms

---

### pdfx (^2.6.0)

**Purpose:** PDF viewing and text extraction

**Where used:**
- PDF preview
- PDF → Text extraction
- PDF page rendering

**Platform considerations:** All platforms

---

## Utility Dependencies

### url_launcher (^6.2.6)

**Purpose:** Open external URLs

**Where used:**
- Open URLs from QR scan results
- External links in help/about

**Platform considerations:** All platforms

---

## Dev Dependencies

### flutter_test (SDK)

**Purpose:** Unit and widget testing

**Where used:** Test files

---

### flutter_lints (^4.0.0)

**Purpose:** Static analysis rules

**Where used:** Development and CI

---

## Dependency Summary

| Category | Packages |
|----------|----------|
| Core | get, google_fonts, intl |
| Storage | hive_flutter, path_provider |
| Permissions | permission_handler, share_plus |
| Speech | speech_to_text, flutter_tts |
| ML/AI | google_ml_kit |
| File Handling | image_picker, file_picker |
| PDF | pdf, pdfx |
| Utilities | url_launcher |
| Dev | flutter_test, flutter_lints |
