# LifeLens AI

**LifeLens AI** is an intelligent document scanning and organization application that transforms handwritten and printed documents into actionable insights using AI-powered OCR and document analysis.

## Features

### 🎯 Core Capabilities
- **Document Scanning**: Upload images of documents for instant text extraction
- **Handwriting Recognition**: Advanced AI to read handwritten notes and documents
- **Multilingual OCR**: Support for English, Hindi, Urdu, Arabic, and more languages
- **AI Analysis**: Extract key information, summarize content, and identify actionable tasks
- **Scan History**: Save and organize all your scans with powerful search and filtering
- **Dashboard**: Manage your documents with an intuitive interface

### 📱 Platform Support
- **Web Application**: Complete responsive web app (Next.js)
- **Flutter Mobile**: Cross-platform mobile app (Android, iOS, Web, Windows, macOS)

## Project Structure

```
LifeLens/
├── backend/              # Next.js Web Application & API
│   ├── app/
│   │   ├── page.tsx              # Landing page
│   │   ├── dashboard/page.tsx    # Dashboard with scan history
│   │   ├── scanner/page.tsx      # Document scanner interface
│   │   ├── api/                  # API routes
│   │   │   ├── analyze-document/ # OCR & AI analysis
│   │   │   ├── daily-briefing/   # Task briefing
│   │   │   ├── upload/           # Image upload
│   │   │   ├── tasks/            # Task management
│   │   │   └── scans/            # Scan history
│   │   ├── layout.tsx            # Root layout
│   │   └── globals.css           # Global styles
│   ├── lib/
│   │   ├── db.ts                 # Database connection
│   │   ├── schema.ts             # Database schema
│   │   └── storage.ts            # Storage utilities
│   ├── migrations/
│   │   └── 0001_init.sql         # Database migration
│   ├── package.json
│   └── tsconfig.json
├── frontend/             # Flutter Mobile Application
│   ├── lib/
│   │   ├── screens/              # App screens
│   │   ├── widgets/              # UI components
│   │   ├── services/              # API integration
│   │   ├── providers/             # State management
│   │   ├── models/               # Data models
│   │   └── l10n/                 # Localization
│   └── pubspec.yaml
├── WEB_DEPLOYMENT.md             # Web deployment guide
├── DEPLOYMENT.md                 # General deployment guide
└── README.md
```

## Quick Start - Web Application

### Prerequisites
- Vercel account (https://vercel.com)
- OpenAI API key (https://platform.openai.com/api-keys)

### Deploy to Vercel

1. **Import Project**
   - Go to https://vercel.com/dashboard
   - Click **Add New** → **Project**
   - Import `numa-here/LifeLens` from GitHub
   - **Important**: Set **Root Directory** to `backend`
   - Click **Deploy**

2. **Configure Environment Variables**
   - Go to **Settings** → **Environment Variables**
   - Add: `OPENAI_API_KEY=your_api_key_here`
   - Redeploy the project

3. **(Optional) Set Up Database**
   - Add Vercel Postgres for scan history
   - Run the migration from `backend/migrations/0001_init.sql`

See [WEB_DEPLOYMENT.md](WEB_DEPLOYMENT.md) for detailed instructions.

## Local Development

### Backend (Web App)
```bash
cd backend
npm install
npm run dev
```
Visit http://localhost:3000

### Frontend (Flutter)
```bash
cd frontend
flutter pub get
flutter run
```

## API Endpoints

- `POST /api/analyze-document` - OCR and AI document analysis
- `POST /api/daily-briefing` - Generate daily task briefing
- `POST /api/upload` - Upload document images
- `GET /api/tasks` - Get user's tasks
- `POST /api/tasks` - Create a new task
- `PUT /api/tasks/:id` - Update a task
- `DELETE /api/tasks/:id` - Delete a task
- `GET /api/scans` - Get scan history
- `DELETE /api/scans/:id` - Delete a scan

## Environment Variables

### Required for Web App
- `OPENAI_API_KEY` - Your OpenAI API key

### Optional (for full functionality)
- `POSTGRES_URL` - Vercel Postgres connection (for scan history)
- `POSTGRES_PRISMA_URL` - Prisma-compatible connection
- `POSTGRES_URL_NON_POOLING` - Non-pooled connection
- `BLOB_READ_WRITE_TOKEN` - Vercel Blob storage (for file storage)

## Technology Stack

### Web Application
- **Framework**: Next.js 14 (App Router)
- **Styling**: Tailwind CSS
- **Database**: Vercel Postgres (optional)
- **ORM**: Drizzle ORM
- **AI**: OpenAI GPT-4o-mini (vision model)
- **Deployment**: Vercel

### Mobile Application
- **Framework**: Flutter
- **State Management**: Provider
- **Platform**: Android, iOS, Web, Windows, macOS

## Security Notes

- Never commit API keys to GitHub
- Use environment variables for sensitive data
- The web app uses demo authentication (production requires proper auth)
- Database has row-level security policies
- AI API keys are stored server-side only

## Division of Work

- **Numa (Frontend Developer)**: Flutter mobile application, UI screens, Material 3 design, dynamic localization (English, Hindi, Telugu), client state management
- **Omema (Backend & AI Developer)**: Next.js web application, API routes, database schema, AI integration with OpenAI

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.

## Support

For issues or questions:
- Check the deployment guides: [WEB_DEPLOYMENT.md](WEB_DEPLOYMENT.md)
- Review the GitHub repository: https://github.com/numa-here/LifeLens
- Open an issue on GitHub for bugs or feature requests
