# Platform Support Matrix

| Feature | Android | iOS | Web |
|---------|---------|-----|-----|
| Text → Audio (TTS) | ✅ Supported | ⚠️ Not tested | ✅ Browser TTS |
| Audio → Text (STT) | ✅ Supported | ⚠️ Not tested | ⚠️ Limited browser support |
| Language Translator | ✅ With model download | ⚠️ Not tested | ✅ With model download |
| Image → Text (OCR) | ✅ Supported | ⚠️ Not tested | ✅ Image upload |
| QR Code Scanner | ✅ Supported | ⚠️ Not tested | ✅ Image upload |
| Calendar | ✅ Supported | ⚠️ Not tested | ✅ Supported |
| Text → PDF | ✅ Supported | ⚠️ Not tested | ✅ Supported |
| PDF → Text | ✅ Supported | ⚠️ Not tested | ✅ Supported |
| Merge PDFs | ✅ Supported | ⚠️ Not tested | ✅ Supported |
| Split PDFs | ✅ Supported | ⚠️ Not tested | ✅ Supported |
| Compress PDF | ✅ Supported | ⚠️ Not tested | ✅ Supported |
| History | ✅ Supported | ⚠️ Not tested | ✅ Supported |
| Favorites | ✅ Supported | ⚠️ Not tested | ✅ Supported |
| Settings | ✅ Supported | ⚠️ Not tested | ✅ Supported |
| Dark/Light Mode | ✅ Supported | ⚠️ Not tested | ✅ Supported |
| Share/Export | ✅ Supported | ⚠️ Not tested | ✅ Supported |

---

## Status Legend

| Status | Meaning |
|--------|---------|
| ✅ Supported | Feature works on this platform |
| ⚠️ Not tested | Feature may work but has not been verified |
| ⚠️ Limited | Feature works with limitations |
| ❌ Not supported | Feature does not work on this platform |

---

## Platform Notes

### Web (Chrome)

**Working:**
- All PDF tools
- Calendar and history
- Theme switching
- Responsive layout
- Image upload for OCR and QR scanning

**Limitations:**
- Speech-to-text: Limited browser support
- OCR/QR: Requires image file upload (no camera)
- Translation: Requires initial model download

### Android

**Working:**
- All features supported
- Camera access for QR scanning
- Microphone access for speech-to-text
- File system access for documents

**Build Status:**
- Android SDK not available in current environment
- Build should work with proper Android SDK setup

### iOS

**Status:**
- iOS runtime/build verification requires macOS and Xcode
- Not tested in current environment
- Should work based on Flutter cross-platform capabilities

---

## Permissions by Platform

| Permission | Android | iOS | Web |
|------------|---------|-----|-----|
| Camera | Required for QR scanner | Required for QR scanner | Not available |
| Microphone | Required for STT | Required for STT | Limited support |
| Storage | Required for file access | Required for file access | Not required |

---

## Minimum Requirements

| Platform | Minimum Version |
|----------|-----------------|
| Android | API 21 (Android 5.0) |
| iOS | iOS 11.0 (not tested) |
| Web | Chrome, Firefox, Safari, Edge (latest versions) |
