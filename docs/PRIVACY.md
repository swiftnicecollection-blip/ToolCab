# Privacy Policy

This document describes how ToolCab handles user data and privacy.

## Data Storage

ToolCab stores data **locally on your device** using Hive local storage. No data is transmitted to external servers.

### Data Collected

The following data is stored locally:

- **Settings** — Theme preference, notification settings
- **History** — Record of tool usage (translations, OCR scans, PDF operations)
- **Calendar Events** — Events you create within the app
- **Favorites** — Translations you save for quick access
- **Onboarding State** — Whether you've completed the onboarding flow

### Data NOT Collected

ToolCab does **not** collect:

- Personal information (name, email, phone)
- Location data
- Device identifiers
- Usage analytics
- Crash reports
- Any data from your documents, images, or files

## File Handling

### Documents and Images

- Files you process (PDFs, images) remain on your device
- No files are uploaded to external servers
- Processed results are stored locally if you choose to save them

### OCR and Scanning

- Images selected for OCR are processed on-device using ML Kit
- No image data leaves your device
- Extracted text is stored locally only if you save it

### Translations

- Translation text is processed on-device after initial model download
- Language models are downloaded from Google servers for offline use
- No translation content is transmitted to external servers

## Permissions

ToolCab requests the following permissions:

| Permission | Purpose | Required |
|------------|---------|----------|
| Camera | QR code scanning | Optional |
| Microphone | Speech-to-text | Optional |
| Storage | File and image access | Optional |

Permissions are only used for their stated purpose. You can deny permissions and still use features that don't require them.

## Network Usage

### Network Required

- Initial app setup (package downloads)
- Translation model downloads (one-time per language)

### Network NOT Required

- All PDF operations
- OCR and QR scanning (after initial setup)
- Calendar and history
- Text-to-speech
- Most app features work fully offline

## Third-Party Services

ToolCab uses the following platform services:

- **Google ML Kit** — On-device machine learning (OCR, translation, QR scanning)
  - Runs entirely on-device after model download
  - No data sent to Google servers during processing

- **Platform Speech Recognition** — Speech-to-text uses device's built-in recognition
  - Processing handled by the operating system

## Data Security

- No authentication system (no passwords stored)
- No user accounts
- All data remains on your device
- No data backup to cloud services

## Data Deletion

You can delete your data by:

- Clearing history from the History screen
- Deleting calendar events individually
- Clearing app data through device settings
- Uninstalling the application

## Children's Privacy

ToolCab does not knowingly collect personal information from children. The app contains no age-restricted content.

## Changes to This Policy

This privacy policy may be updated as the project evolves. Check back for the latest version.

## Contact

For privacy questions or concerns, please open an issue on the project repository.
