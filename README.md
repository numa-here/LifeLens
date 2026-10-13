# LifeLens

**LifeLens** is an AI-powered application designed to help users understand documents, identify important tasks and deadlines, and manage their responsibilities efficiently.

## Features

### 1. Google Login
Sign in with a Google account and securely access personal data.

### 2. Multilingual App
Choose the interface language, with English, Hindi and Telugu as the initial examples.

### 3. Scan or Upload Documents
Capture a photo or select an image; add pasted text and PDF support where feasible.

### 4. Handwriting Recognition
Extract handwritten and printed text, detect the text language and let users correct errors.

### 5. AI Document Analysis
Extract tasks, deadlines, required documents, priorities and supporting evidence.

### 6. Review and Confirm
Edit suggested tasks and verify uncertain dates before saving.

### 7. My Scans and History
Store scan images and extracted text, then reopen previous scans.

### 8. Task Dashboard
See upcoming deadlines, pending and completed tasks, and priority.

### 9. Daily AI Briefing
Summarize what's due soon and suggest the next three actions.

## Division of Work
- **Numa (Frontend Developer)**: Flutter mobile application, UI screens, Material 3 design, dynamic localization (English, Hindi, Telugu), client state management, and mock fallback services.
- **Omema (Backend & AI Developer)**: Supabase PostgreSQL database, Row Level Security, private storage for scan images, and Edge Functions (`analyze-document` and `daily-briefing`).

## Project Structure
```
lifelens-ai/
├── frontend/             # Flutter & Dart mobile application (Numa)
│   ├── lib/
│   │   ├── screens/      # App screens (Login, Home, Upload, Review, My Tasks, Briefing, History, Settings)
│   │   ├── widgets/      # Reusable UI components (TaskCard, UploadBox, PriorityBadge, LoadingIndicator)
│   │   ├── services/     # API & mock integration layer (Supabase, Auth, Document, Task, ScanHistory)
│   │   ├── providers/    # State management (LocaleProvider, TaskProvider)
│   │   ├── models/       # Data contracts (Task, ScanRecord, DocumentAnalysisResult)
│   │   └── l10n/         # Localization files (en, hi, te)
│   └── pubspec.yaml
└── supabase/             # Supabase backend & Edge functions (Omema)
```

## Running the Frontend
```bash
cd frontend
flutter pub get
flutter run
```

## Platform Support
LifeLens is built with Flutter and Dart, supporting:
- Android
- iOS
- Web
- Windows
- macOS
