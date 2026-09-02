# Screen Documentation

This document describes all screens implemented in ToolCab.

---

## Splash Screen

**Route:** `/splash`

**Purpose:** Displayed briefly while the app initializes

**Main controls:**
- Animated splash background
- App logo and name

**Navigation:** Automatically navigates to onboarding or home

**Data source:** None

**Platform limitations:** None

---

## Onboarding Screen

**Route:** `/onboarding`

**Purpose:** Introduce first-time users to the app

**Main controls:**
- Page indicators
- Next/Skip buttons
- Get Started button

**Navigation:** Advances through onboarding pages, then to home

**Data source:** Local onboarding state

**Platform limitations:** None

---

## Home Screen

**Route:** `/home`

**Purpose:** Main dashboard with access to all tools

**Main controls:**
- Tool grid (quick access to all features)
- Recent activity section
- Navigation to history and settings

**Navigation:** Navigates to all tool screens

**Data source:** Recent files repository, history repository

**Platform limitations:** None

---

## Text → Audio (TTS) Screen

**Route:** `/tools/tts`

**Purpose:** Convert text to speech

**Main controls:**
- Text input field
- Voice settings (pitch, rate, volume)
- Play/Pause/Stop buttons
- Language selection

**Navigation:** Back to home

**Data source:** flutter_tts service

**Permissions:** None

**Platform limitations:** Web uses browser TTS

---

## Audio → Text (STT) Screen

**Route:** `/tools/stt`

**Purpose:** Convert speech to text

**Main controls:**
- Microphone button (start/stop listening)
- Transcript display
- Copy/Save buttons
- Language selection

**Navigation:** Back to home

**Data source:** speech_to_text service

**Permissions:** Microphone required

**Platform limitations:** Limited browser support on Web

---

## Translator Screen

**Route:** `/tools/translator`

**Purpose:** Translate text between languages

**Main controls:**
- Source language selector
- Target language selector
- Source text input
- Translation output
- Swap languages button
- Copy/Share/Favorite buttons
- History tab
- Favorites tab

**Navigation:** Back to home

**Data source:** Translation service (ML Kit), translation repository

**Permissions:** None (network for model download)

**Platform limitations:** Requires model download on first use

---

## OCR Screen

**Route:** `/tools/ocr`

**Purpose:** Extract text from images

**Main controls:**
- Image selection button
- Image preview
- Extracted text display
- Copy/Share/Save buttons

**Navigation:** Back to home

**Data source:** OCR service (ML Kit)

**Permissions:** Storage/Photos for image selection

**Platform limitations:** Web requires image file upload

---

## QR Scanner Screen

**Route:** `/tools/qr-scanner`

**Purpose:** Scan QR codes from images

**Main controls:**
- Image selection button
- Scan result display
- Action buttons (open URL, copy, share)
- Torch toggle (placeholder)

**Navigation:** Back to home

**Data source:** QR scanner service (ML Kit)

**Permissions:** Storage/Photos for image selection

**Platform limitations:** Web requires image file upload (no camera)

---

## PDF Dashboard Screen

**Route:** `/tools/pdf`

**Purpose:** Hub for all PDF tools

**Main controls:**
- Text → PDF button
- PDF → Text button
- Merge PDFs button
- Split PDFs button
- Compress PDF button

**Navigation:** Navigates to specific PDF tool screens

**Data source:** None

**Platform limitations:** None

---

## Text → PDF Screen

**Route:** `/tools/pdf/text-to-pdf`

**Purpose:** Generate PDF from text

**Main controls:**
- Text input field
- PDF options (page size, margins)
- Generate button
- Preview
- Save button

**Navigation:** Back to PDF dashboard

**Data source:** PDF service

**Permissions:** Storage for saving files

**Platform limitations:** None

---

## PDF → Text Screen

**Route:** `/tools/pdf/pdf-to-text`

**Purpose:** Extract text from PDF

**Main controls:**
- File selection button
- PDF preview
- Extracted text display
- Copy/Save buttons
- History button

**Navigation:** Back to PDF dashboard, PDF history

**Data source:** PDF service

**Permissions:** Storage for file selection

**Platform limitations:** None

---

## Merge PDF Screen

**Route:** `/tools/pdf/merge`

**Purpose:** Combine multiple PDFs

**Main controls:**
- File selection (multiple)
- File reordering
- Merge button
- Save button

**Navigation:** Back to PDF dashboard

**Data source:** PDF service

**Permissions:** Storage for file operations

**Platform limitations:** None

---

## Split PDF Screen

**Route:** `/tools/pdf/split`

**Purpose:** Extract pages from PDF

**Main controls:**
- File selection
- Page selection
- Split button
- Save button

**Navigation:** Back to PDF dashboard

**Data source:** PDF service

**Permissions:** Storage for file operations

**Platform limitations:** None

---

## Compress PDF Screen

**Route:** `/tools/pdf/compress`

**Purpose:** Reduce PDF file size

**Main controls:**
- File selection
- Compression level
- Compress button
- Save button

**Navigation:** Back to PDF dashboard

**Data source:** PDF service

**Permissions:** Storage for file operations

**Platform limitations:** None

---

## Calendar Screen

**Route:** `/calendar`

**Purpose:** Create and manage events

**Main controls:**
- Month navigation
- Day selection
- Event creation form
- Event list
- Edit/Delete event

**Navigation:** Back to home

**Data source:** Calendar repository (Hive)

**Permissions:** None

**Platform limitations:** None

---

## History Screen

**Route:** `/history`

**Purpose:** View activity history

**Main controls:**
- History list
- Search/filter
- Clear history button
- Favorites toggle

**Navigation:** Back to home

**Data source:** History repository (Hive)

**Permissions:** None

**Platform limitations:** None

---

## Settings Screen

**Route:** `/settings`

**Purpose:** App configuration

**Main controls:**
- Dark mode toggle
- Notifications button
- Help button
- About button

**Navigation:** To notifications, help, about screens

**Data source:** Settings repository (Hive)

**Permissions:** None

**Platform limitations:** None

---

## Notifications Screen

**Route:** `/settings/notifications`

**Purpose:** Notification preferences

**Main controls:**
- Notification toggles

**Navigation:** Back to settings

**Data source:** Settings repository

**Permissions:** None

**Platform limitations:** None

---

## Help Screen

**Route:** `/settings/help`

**Purpose:** User assistance

**Main controls:**
- FAQ section
- Contact information

**Navigation:** Back to settings

**Data source:** Static content

**Platform limitations:** None

---

## About Screen

**Route:** `/settings/about`

**Purpose:** App information

**Main controls:**
- App version
- Developer info
- License information

**Navigation:** Back to settings

**Data source:** App constants

**Platform limitations:** None
