# LifeLens AI

Intelligent Document Analysis & Actionable Insights Mobile Assistant.

## Overview
LifeLens AI enables users to capture or paste notices, bills, handwritten prescriptions, and documents in multiple languages (English, Hindi, and Telugu). The app analyzes the content, recognizes handwriting, extracts tasks, deadlines, priorities, and source evidence, and delivers a daily AI briefing with the top 3 recommended actions.

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
