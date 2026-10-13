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
LifeLens/
├── lib/                   # Flutter & Dart mobile application (Numa)
│   ├── screens/          # App screens (Login, Home, Upload, Review, My Tasks, Briefing, History, Settings)
│   ├── widgets/          # Reusable UI components (TaskCard, UploadBox, PriorityBadge, LoadingIndicator)
│   ├── services/         # API & mock integration layer (Supabase, Auth, Document, Task, ScanHistory)
│   ├── providers/        # State management (LocaleProvider, TaskProvider)
│   ├── models/           # Data contracts (Task, ScanRecord, DocumentAnalysisResult)
│   └── l10n/             # Localization files (en, hi, te)
├── supabase/             # Supabase backend & Edge functions (Omema)
│   ├── config.toml
│   ├── migrations/
│   │   ├── 001_create_tables.sql
│   │   └── 002_storage_policies.sql
│   └── functions/
│       ├── analyze-document/
│       │   └── index.ts
│       └── daily-briefing/
│           └── index.ts
├── .gitignore
└── README.md
```

## Running the Frontend
```bash
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

## Backend Setup

### Prerequisites
- Supabase project with:
  - Google OAuth configured
  - Private storage bucket named `documents`
  - OpenAI API key set as environment variable

### Database Setup
Run the SQL migrations in Supabase SQL Editor:
1. `001_create_tables.sql` - Creates scan_history and tasks tables with RLS
2. `002_storage_policies.sql` - Configures storage security policies

### Edge Functions
Deploy the functions using Supabase CLI:
```bash
supabase functions deploy analyze-document
supabase functions deploy daily-briefing
```

### Environment Variables
Set these secrets in Supabase Edge Functions:
- `OPENAI_API_KEY` - Your OpenAI API key
- `SUPABASE_URL` - Your Supabase project URL
- `SUPABASE_ANON_KEY` - Your Supabase anon/public key

## Security Notes
- Never commit API keys to GitHub
- Use private storage buckets for sensitive documents
- Row-level security ensures users can only access their own data
- AI API keys are stored server-side only
