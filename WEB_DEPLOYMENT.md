# LifeLens Web Application Deployment Guide

## Quick Start

### Prerequisites
- Vercel account (https://vercel.com)
- OpenAI API key (https://platform.openai.com/api-keys)
- GitHub account with access to `numa-here/LifeLens` repository

### Step 1: Deploy Backend to Vercel

1. Go to https://vercel.com/dashboard
2. Click **Add New** → **Project**
3. Import `numa-here/LifeLens` from GitHub
4. **CRITICAL**: Set **Root Directory** to `backend`
5. Configure:
   - **Framework Preset**: Next.js
   - **Build Command**: `npm run build`
   - **Output Directory**: `.next`
6. Click **Deploy**

### Step 2: Set Environment Variables

After deployment, go to your project's **Settings** → **Environment Variables** and add:

```
OPENAI_API_KEY=your_actual_openai_api_key_here
```

The following are automatically set when you add Vercel Postgres (optional for MVP):
- `POSTGRES_URL`
- `POSTGRES_PRISMA_URL`
- `POSTGRES_URL_NON_POOLING`

### Step 3: (Optional) Set Up Database

For full functionality with scan history:

1. In Vercel Dashboard, go to **Storage** → **Create Database**
2. Choose **Postgres** (Vercel Postgres)
3. Enter database name: `lifelens-db`
4. Click **Create Database**
5. In the database console, run the migration from `backend/migrations/0001_init.sql`

### Step 4: Redeploy

After adding environment variables, redeploy:
- Go to **Deployments** tab
- Click the three dots next to the latest deployment
- Click **Redeploy**

## Build Verification

The application should build successfully with:
- Landing page at `/`
- Dashboard at `/dashboard`
- Scanner at `/scanner`
- API routes at `/api/*`

## Environment Variables Required

### Minimum (for basic scanning):
- `OPENAI_API_KEY` - Your OpenAI API key

### Optional (for scan history):
- `POSTGRES_URL` - Vercel Postgres connection string
- `POSTGRES_PRISMA_URL` - Prisma-compatible connection string
- `POSTGRES_URL_NON_POOLING` - Non-pooled connection string

## Features Implemented

### ✅ Landing Page
- Professional branding with LifeLens AI
- Feature highlights (Multilingual OCR, Handwriting Recognition, AI Analysis, Scan History)
- Call-to-action buttons
- Responsive design

### ✅ Scanner
- Image upload from device
- Image preview before processing
- File type and size validation
- OCR processing with OpenAI
- Extracted text display and editing
- Language detection
- Summary generation
- Task extraction
- Copy to clipboard functionality

### ✅ Dashboard
- Scan history display
- Search functionality
- Delete scans
- Stats cards (total scans, etc.)
- Empty states for new users
- Navigation to scanner

### ✅ API Endpoints
- `POST /api/analyze-document` - OCR and AI analysis
- `POST /api/daily-briefing` - Daily task briefing
- `POST /api/upload` - Image upload (returns base64)
- `GET /api/tasks` - Get user tasks
- `POST /api/tasks` - Create task
- `PUT /api/tasks/:id` - Update task
- `DELETE /api/tasks/:id` - Delete task
- `GET /api/scans` - Get scan history
- `DELETE /api/scans/:id` - Delete scan

## Known Limitations

1. **Authentication**: Currently uses a demo user ID (`demo-user`). Production requires proper authentication implementation.
2. **Database**: Scan history requires Vercel Postgres. Without it, the dashboard will show no history.
3. **File Storage**: Images are processed as base64 in-memory. For production, implement Vercel Blob storage.
4. **Handwriting Recognition**: Accuracy depends on OpenAI's vision model capabilities.

## Troubleshooting

### Build Fails
- Ensure Root Directory is set to `backend` in Vercel project settings
- Check that all dependencies are in `package.json`
- Verify TypeScript configuration in `tsconfig.json`

### API Returns 500 Error
- Check that `OPENAI_API_KEY` is set in environment variables
- Verify OpenAI account has credits
- Check Vercel deployment logs

### Database Connection Error
- Ensure Vercel Postgres is added to the project
- Verify `POSTGRES_URL` is set automatically
- Run the migration script in the database console

### Scanner Shows "Processing Failed"
- Check OpenAI API key is valid
- Verify image file is valid (JPEG, PNG, WebP)
- Check file size is under 10MB
- Review Vercel function logs

## Next Steps for Production

1. **Authentication**: Implement NextAuth.js or similar for secure user authentication
2. **Database**: Set up Vercel Postgres and run migrations
3. **File Storage**: Implement Vercel Blob for persistent image storage
4. **Rate Limiting**: Add rate limiting to API endpoints
5. **Error Handling**: Improve error messages and recovery
6. **Testing**: Add unit and integration tests
7. **Monitoring**: Set up error tracking and analytics

## Support

For issues or questions:
- Check Vercel deployment logs
- Review the GitHub repository: https://github.com/numa-here/LifeLens
- Open an issue on GitHub for bugs or feature requests
