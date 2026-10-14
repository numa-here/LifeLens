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
- **Omema (Backend & AI Developer)**: Next.js API routes, Vercel Postgres database, Vercel Blob storage, and AI integration with OpenAI.

## Project Structure
```
LifeLens/
├── frontend/             # Flutter & Dart mobile application (Numa)
│   ├── lib/
│   │   ├── screens/      # App screens (Login, Home, Upload, Review, My Tasks, Briefing, History, Settings)
│   │   ├── widgets/      # Reusable UI components (TaskCard, UploadBox, PriorityBadge, LoadingIndicator)
│   │   ├── services/     # API & mock integration layer
│   │   ├── providers/    # State management (LocaleProvider, TaskProvider)
│   │   ├── models/       # Data contracts (Task, ScanRecord, DocumentAnalysisResult)
│   │   └── l10n/         # Localization files (en, hi, te)
│   └── pubspec.yaml
├── backend/              # Next.js backend & API routes (Omema)
│   ├── app/
│   │   ├── api/
│   │   │   ├── analyze-document/
│   │   │   ├── daily-briefing/
│   │   │   ├── upload/
│   │   │   ├── tasks/
│   │   │   └── scans/
│   │   ├── layout.tsx
│   │   └── page.tsx
│   ├── lib/
│   │   ├── db.ts
│   │   ├── schema.ts
│   │   └── storage.ts
│   ├── migrations/
│   │   └── 0001_init.sql
│   ├── package.json
│   └── tsconfig.json
├── .gitignore
├── README.md
└── DEPLOYMENT.md
```

## Running the Frontend
```bash
cd frontend
flutter pub get
flutter run
```

## Running the Backend (Local Development)
```bash
cd backend
npm install
npm run dev
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
- Vercel account (https://vercel.com)
- OpenAI API key (https://platform.openai.com/api-keys)
- Node.js 18+ installed

### Database Setup
The backend uses Vercel Postgres. Follow the deployment guide to set up:
1. Create Vercel Postgres database
2. Run the SQL migration from `backend/migrations/0001_init.sql`
3. Set up Vercel Blob storage for document images

### API Endpoints
- `POST /api/analyze-document` - Analyze documents (text or image)
- `POST /api/daily-briefing` - Generate daily AI briefing
- `POST /api/upload` - Upload document images
- `GET /api/tasks` - Get user's tasks
- `POST /api/tasks` - Create a new task
- `PUT /api/tasks/:id` - Update a task
- `DELETE /api/tasks/:id` - Delete a task
- `GET /api/scans` - Get scan history

### Environment Variables
Set these in Vercel environment variables:
- `OPENAI_API_KEY` - Your OpenAI API key
- `POSTGRES_URL` - Automatically set by Vercel Postgres
- `BLOB_READ_WRITE_TOKEN` - Automatically set by Vercel Blob

## Deployment

### Deploy Backend to Vercel
```bash
cd backend
vercel login
vercel
```

### Deploy Frontend to Vercel
```bash
cd frontend
vercel login
vercel
```

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed deployment instructions.

## Security Notes
- Never commit API keys to GitHub
- Use Vercel environment variables for sensitive data
- Vercel Blob storage supports private access
- Database has row-level security policies
- AI API keys are stored server-side only
