# SHIPATHON Submission

## Project

**ToolCab** — All-in-One AI Productivity Toolkit

---

## One-Line Pitch

A polished cross-platform productivity toolkit that combines document processing, OCR, speech, translation, QR scanning, calendar management, and everyday file workflows in one app.

---

## Problem

Users often need multiple applications for common productivity tasks:

- Extract text from images or documents
- Create, merge, split, or compress PDF files
- Convert speech to text for notes and dictation
- Translate text between languages
- Scan QR codes for information
- Manage calendar events and reminders

Switching between multiple apps reduces productivity and creates friction in everyday workflows.

---

## Solution

ToolCab combines all these productivity workflows into a single, unified application:

- **One app** for all common productivity tasks
- **Consistent interface** — learn once, use everywhere
- **Local processing** — documents stay on your device
- **Cross-platform** — works on Web and Android
- **No accounts** — start using immediately

---

## Key Features

| Feature | Technology |
|---------|------------|
| Text → Audio | flutter_tts |
| Audio → Text | speech_to_text |
| Language Translator | Google ML Kit (on-device) |
| Image → Text (OCR) | Google ML Kit |
| QR Code Scanner | Google ML Kit |
| Calendar | Local storage (Hive) |
| PDF Tools (Merge/Split/Compress) | pdf, pdfx |
| Text → PDF | pdf |
| PDF → Text | pdfx |

---

## Technology

| Technology | Purpose |
|------------|---------|
| Flutter | Cross-platform UI framework |
| Dart | Programming language |
| GetX | State management, routing, DI |
| Material 3 | Design system |
| Google ML Kit | On-device ML (OCR, translation, QR) |
| Hive | Local storage |
| speech_to_text | Speech recognition |
| flutter_tts | Text-to-speech |
| pdf / pdfx | PDF processing |

---

## Why It Matters

- **Students** — OCR for notes, PDF tools for assignments, translator for research
- **Professionals** — Document management, speech-to-text for meetings
- **Small Businesses** — Invoice management, document processing
- **General Users** — Everyday productivity tasks in one place

---

## Demo Flow

| Time | Action |
|------|--------|
| 00:00–00:10 | Launch ToolCab |
| 00:10–00:25 | Show Home screen |
| 00:25–00:45 | OCR demonstration |
| 00:45–01:00 | Text → PDF |
| 01:00–01:15 | PDF management |
| 01:15–01:30 | Translator |
| 01:30–01:45 | QR Scanner |
| 01:45–02:00 | Calendar |
| 02:00–02:15 | History/Favorites |
| 02:15–02:30 | Dark mode + final overview |

---

## Limitations

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

## Future Roadmap

- Cloud synchronization across devices
- Additional translation languages
- Smart document organization
- Support for more file formats
- Enhanced accessibility features
- Collaboration features

---

## License

ToolCab © 2026. All rights reserved.
