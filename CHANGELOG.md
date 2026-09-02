# Changelog

All notable changes to ToolCab will be documented in this file.

## Unreleased

### Core Features

- **Text → Audio (TTS)** — Convert text to speech playback
- **Audio → Text (STT)** — Speech-to-text recognition
- **Language Translator** — On-device translation using Google ML Kit
- **Image → Text (OCR)** — Extract text from images using Google ML Kit
- **QR Code Scanner** — Scan QR codes from images using Google ML Kit
- **Calendar** — Event creation and local management
- **History** — Track recent activity across all tools

### PDF Tools

- **Text → PDF** — Generate PDF documents from text input
- **PDF → Text** — Extract text content from PDF files
- **Merge PDFs** — Combine multiple PDF files into one
- **Split PDFs** — Extract specific pages from PDF files
- **Compress PDF** — Reduce PDF file size

### User Interface

- Material 3 design system with dynamic theming
- Light and dark theme support
- Responsive layout for phones, tablets, and web
- Onboarding flow for first-time users
- Home dashboard with quick tool access

### Architecture

- Feature-based modular architecture
- GetX state management and routing
- Hive local storage for settings, history, and calendar
- Reusable widget library
- Controller-based state management

### Performance

- Lazy initialization of controllers and services
- Efficient list rendering
- Automatic resource disposal
- Optimized for cross-platform performance

### Stability

- Deprecated API migrations
- Error handling for permissions, files, and network
- Input validation
- Platform-specific feature handling

---

## Previous Development

ToolCab was developed through iterative development:

1. **Foundation** — Project setup, design system, architecture
2. **UI/UX Polish** — Responsive design, animations, theming
3. **Performance + Stability** — Optimization, error handling
4. **QA Testing** — Bug fixes, validation
5. **Critical Functional Completion** — Real implementations for all tools
