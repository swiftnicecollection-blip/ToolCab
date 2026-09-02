# Features

This document describes each feature implemented in ToolCab.

## Text → Audio (TTS)

**Purpose:** Convert written text into spoken audio

**User Flow:**
1. Navigate to Text → Audio from home
2. Enter or paste text
3. Adjust voice settings (pitch, rate, volume)
4. Tap play to hear the audio

**Input:** Text input (manual entry or from clipboard)

**Processing:** Uses `flutter_tts` for speech synthesis

**Output:** Audio playback through device speakers

**Storage:** Optional history of text-to-speech conversions

**Permissions:** None required

**Offline:** Works offline after initial setup

**Platform limitations:** Web uses browser TTS capabilities

---

## Audio → Text (STT)

**Purpose:** Convert spoken words into written text

**User Flow:**
1. Navigate to Audio → Text from home
2. Grant microphone permission
3. Tap microphone and speak
4. View transcribed text
5. Copy or save the result

**Input:** Audio from device microphone

**Processing:** Uses `speech_to_text` for speech recognition

**Output:** Transcribed text displayed on screen

**Storage:** Optional history of transcriptions

**Permissions:** Microphone access required

**Offline:** Requires platform speech recognition service

**Platform limitations:** Limited browser support on Web

---

## Language Translator

**Purpose:** Translate text between different languages

**User Flow:**
1. Navigate to Translator from home
2. Select source and target languages
3. Enter text to translate
4. View translation
5. Save to favorites or copy result

**Input:** Text input, source language, target language

**Processing:** Uses Google ML Kit on-device translation

**Output:** Translated text

**Storage:** Translation history and favorites stored locally

**Permissions:** None required (network needed for initial model download)

**Offline:** Works offline after language models are downloaded

**Platform limitations:** Requires model download on first use

**Supported Languages:**
- English, Urdu, Hindi, Arabic, French, German, Spanish
- Italian, Portuguese, Turkish, Russian, Chinese, Japanese
- Korean, Bengali, Persian, and more

---

## Image → Text (OCR)

**Purpose:** Extract text from images

**User Flow:**
1. Navigate to OCR from home
2. Select an image (gallery or file picker)
3. View extracted text
4. Copy, save, or share the text

**Input:** Image file (JPG, PNG, etc.)

**Processing:** Uses Google ML Kit text recognition

**Output:** Extracted text from the image

**Storage:** Optional history of OCR operations

**Permissions:** Storage/photos access for image selection

**Offline:** Works offline (on-device ML)

**Platform limitations:** Web requires image file upload

---

## QR Code Scanner

**Purpose:** Decode QR codes from images

**User Flow:**
1. Navigate to QR Scanner from home
2. Select an image containing a QR code
3. View decoded content
4. Take action based on content (open URL, copy text, etc.)

**Input:** Image file containing QR code

**Processing:** Uses Google ML Kit barcode scanning

**Output:** Decoded QR content (URL, text, etc.)

**Storage:** Optional scan history

**Permissions:** Storage/photos access for image selection

**Offline:** Works offline (on-device ML)

**Platform limitations:** Web requires image file upload (no camera)

---

## Calendar

**Purpose:** Create and manage events

**User Flow:**
1. Navigate to Calendar from home
2. View monthly calendar grid
3. Tap a date to add an event
4. Enter event details (title, description, time)
5. View, edit, or delete events

**Input:** Event details (title, description, date, time)

**Processing:** Local event management

**Output:** Calendar view with events

**Storage:** Events stored locally in Hive

**Permissions:** None required

**Offline:** Fully offline

**Platform limitations:** None

---

## Text → PDF

**Purpose:** Generate PDF documents from text

**User Flow:**
1. Navigate to Text → PDF from PDF tools
2. Enter or paste text content
3. Configure PDF options (page size, margins)
4. Generate PDF
5. Preview and save

**Input:** Text content

**Processing:** Uses `pdf` package for document generation

**Output:** PDF file

**Storage:** Generated PDF saved to device

**Permissions:** Storage access for saving files

**Offline:** Fully offline

**Platform limitations:** None

---

## PDF → Text

**Purpose:** Extract text content from PDF files

**User Flow:**
1. Navigate to PDF → Text from PDF tools
2. Select a PDF file
3. View extracted text
4. Copy or save the text

**Input:** PDF file

**Processing:** Uses `pdfx` for text extraction

**Output:** Extracted text content

**Storage:** Optional history of extractions

**Permissions:** Storage access for file selection

**Offline:** Fully offline

**Platform limitations:** None

---

## Merge PDFs

**Purpose:** Combine multiple PDF files into one

**User Flow:**
1. Navigate to Merge PDF from PDF tools
2. Select multiple PDF files
3. Arrange order if needed
4. Merge into single PDF
5. Save the result

**Input:** Multiple PDF files

**Processing:** Uses `pdf` package for document merging

**Output:** Single merged PDF file

**Storage:** Merged PDF saved to device

**Permissions:** Storage access for file operations

**Offline:** Fully offline

**Platform limitations:** None

---

## Split PDFs

**Purpose:** Extract specific pages from a PDF

**User Flow:**
1. Navigate to Split PDF from PDF tools
2. Select a PDF file
3. Choose pages to extract
4. Create new PDF with selected pages
5. Save the result

**Input:** PDF file, page selection

**Processing:** Uses `pdf` package for page extraction

**Output:** New PDF with selected pages

**Storage:** Split PDF saved to device

**Permissions:** Storage access for file operations

**Offline:** Fully offline

**Platform limitations:** None

---

## Compress PDF

**Purpose:** Reduce PDF file size

**User Flow:**
1. Navigate to Compress PDF from PDF tools
2. Select a PDF file
3. Choose compression level
4. Compress the file
5. Save the compressed PDF

**Input:** PDF file

**Processing:** Uses `pdf` package for compression

**Output:** Compressed PDF file

**Storage:** Compressed PDF saved to device

**Permissions:** Storage access for file operations

**Offline:** Fully offline

**Platform limitations:** None

---

## History

**Purpose:** Track recent activity across all tools

**User Flow:**
1. Navigate to History from home
2. View list of recent activities
3. Filter by tool type
4. Clear history if desired

**Input:** Automatic tracking of tool usage

**Processing:** Centralized history repository

**Output:** Chronological list of activities

**Storage:** History stored locally in Hive

**Permissions:** None required

**Offline:** Fully offline

**Platform limitations:** None

---

## Favorites

**Purpose:** Save preferred translations for quick access

**User Flow:**
1. Translate text
2. Tap favorite button to save
3. Access favorites from translator
4. Search and reuse saved translations

**Input:** Translation entries

**Processing:** Local favorites management

**Output:** List of saved translations

**Storage:** Favorites stored locally in Hive

**Permissions:** None required

**Offline:** Fully offline

**Platform limitations:** None

---

## Settings

**Purpose:** Customize application behavior

**User Flow:**
1. Navigate to Settings from home
2. Toggle dark/light mode
3. Configure notification preferences
4. View app information

**Input:** User preferences

**Processing:** Local settings management

**Output:** Updated app behavior

**Storage:** Settings stored locally in Hive

**Permissions:** None required

**Offline:** Fully offline

**Platform limitations:** None
