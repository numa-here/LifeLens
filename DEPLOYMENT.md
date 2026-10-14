# LifeLens Deployment Guide (Vercel)

## Overview
LifeLens requires two separate Vercel deployments:
1. **Backend** - Next.js API server (deployed from `backend/` directory)
2. **Frontend** - Flutter web app (deployed from `frontend/` directory)

## Backend Deployment (Omema's Part)

### Step 1: Prepare the Backend
```bash
cd backend
npm install
```

### Step 2: Set Up Vercel Postgres
1. Go to https://vercel.com/dashboard
2. Click **Storage** → **Create Database**
3. Choose **Postgres** (Vercel Postgres)
4. Enter database name: `lifelens-db`
5. Select region closest to your users
6. Click **Create Database**
7. Wait for database to be ready

### Step 3: Set Up Vercel Blob Storage
1. In Vercel Dashboard, go to **Storage** → **Create Database**
2. Choose **Blob** (Vercel Blob Storage)
3. Enter store name: `lifelens-blob`
4. Click **Create Store**
5. Wait for store to be ready

### Step 4: Run Database Migrations
1. In Vercel Dashboard, go to your Postgres database
2. Click **Console** or **Query**
3. Copy and paste the contents of `backend/migrations/0001_init.sql`
4. Click **Run**
5. Verify both tables were created successfully

### Step 5: Deploy Backend to Vercel
```bash
cd backend
npm install -g vercel
vercel login
vercel
```

Follow the prompts:
- Set project name: `lifelens-backend`
- Link to existing Vercel project (if applicable)
- Select region

### Step 6: Configure Environment Variables
In Vercel Dashboard → **Settings** → **Environment Variables**, add:

```
OPENAI_API_KEY=your_actual_openai_key_here
```

The following are automatically set by Vercel when you add Postgres and Blob:
- `POSTGRES_URL`
- `POSTGRES_PRISMA_URL`
- `POSTGRES_URL_NON_POOLING`
- `BLOB_READ_WRITE_TOKEN`

### Step 7: Redeploy with Environment Variables
```bash
cd backend
vercel --prod
```

### Step 8: Get Backend API URL
After deployment, Vercel will provide a URL like:
- `https://lifelens-backend.vercel.app`

Your API endpoints will be:
- `https://lifelens-backend.vercel.app/api/analyze-document`
- `https://lifelens-backend.vercel.app/api/daily-briefing`
- etc.

## Frontend Deployment (Numa's Part)

### Step 1: Build Flutter Web App
```bash
cd frontend
flutter build web --release
```

### Step 2: Deploy to Vercel
```bash
npm install -g vercel
vercel login
vercel
```

Follow the prompts:
- Set project name: `lifelens-frontend`
- Select framework: None
- Set output directory: `build/web`

### Step 3: Configure Environment Variables
In Vercel Dashboard → **Settings** → **Environment Variables**, add:

```
BACKEND_URL=https://lifelens-backend.vercel.app
```

### Step 4: Redeploy
```bash
cd frontend
vercel --prod
```

## API Documentation

### POST /api/analyze-document
Analyzes a document (text or image) and extracts tasks.

**Headers:**
```
Authorization: Bearer <user_id>
Content-Type: application/json
```

**Request Body (text):**
```json
{
  "text": "Submit the application form by 20 October 2026. Attach two photographs."
}
```

**Request Body (image):**
```json
{
  "image_data_url": "data:image/jpeg;base64,..."
}
```

**Response:**
```json
{
  "scan_id": "uuid",
  "created_at": "2026-10-13T...",
  "analysis": {
    "detected_language": "English",
    "extracted_text": "...",
    "summary": "...",
    "tasks": [...],
    "warnings": []
  },
  "requires_review": true
}
```

### POST /api/daily-briefing
Generates a daily briefing based on pending tasks.

**Headers:**
```
Authorization: Bearer <user_id>
Content-Type: application/json
```

**Request Body:**
```json
{}
```

**Response:**
```json
{
  "date": "2026-10-13",
  "briefing": "...",
  "next_actions": [...]
}
```

### POST /api/upload
Uploads a document image to Vercel Blob storage.

**Headers:**
```
Authorization: Bearer <user_id>
```

**Request Body:**
```
FormData with 'file' field containing the image
```

**Response:**
```json
{
  "url": "https://...",
  "pathname": "user-id/filename.jpg",
  "size": 12345,
  "uploadedAt": "2026-10-13T..."
}
```

### GET /api/tasks
Retrieves all tasks for the authenticated user.

**Headers:**
```
Authorization: Bearer <user_id>
```

**Query Parameters:**
- `status` (optional): Filter by status (pending, in_progress, completed)

**Response:**
```json
{
  "tasks": [...]
}
```

### POST /api/tasks
Creates a new task.

**Headers:**
```
Authorization: Bearer <user_id>
Content-Type: application/json
```

**Request Body:**
```json
{
  "scan_id": "uuid",
  "title": "Task title",
  "description": "Description",
  "due_date": "2026-10-20",
  "priority": "high",
  "source_evidence": "Supporting text"
}
```

### PUT /api/tasks/:id
Updates an existing task.

**Headers:**
```
Authorization: Bearer <user_id>
Content-Type: application/json
```

**Request Body:**
```json
{
  "title": "Updated title",
  "status": "completed"
}
```

### DELETE /api/tasks/:id
Deletes a task.

**Headers:**
```
Authorization: Bearer <user_id>
```

### GET /api/scans
Retrieves all scan history for the authenticated user.

**Headers:**
```
Authorization: Bearer <user_id>
```

**Response:**
```json
{
  "scans": [...]
}
```

## Google OAuth Setup

For Google OAuth, you have two options:

### Option 1: Use NextAuth.js (Recommended)
1. Install NextAuth in the backend:
```bash
cd backend
npm install next-auth @auth/core
```

2. Configure NextAuth with Google provider (additional setup required)

### Option 2: Use Firebase Auth
1. Set up Firebase project
2. Configure Google Sign-In
3. Use Firebase SDK in Flutter app

## Security Notes

- Never commit API keys to GitHub
- Use Vercel environment variables for sensitive data
- The backend uses simple user_id authentication (replace with proper JWT validation in production)
- Vercel Blob storage supports private access
- Database has row-level security policies

## Troubleshooting

### Backend Deployment Fails
- Check Node.js version (must be 18+)
- Verify all dependencies are installed
- Check Vercel deployment logs
- Ensure you're deploying from the `backend/` directory

### Database Connection Error
- Verify POSTGRES_URL is set in Vercel environment variables
- Check Vercel Postgres is active
- Ensure migration was run successfully

### Blob Upload Fails
- Verify BLOB_READ_WRITE_TOKEN is set
- Check Vercel Blob store is active
- Ensure file size is under 10MB

### OpenAI API Error
- Verify OPENAI_API_KEY is set correctly
- Check OpenAI account has credits
- Verify model name (gpt-4o-mini) is available

### Frontend Shows 404
- Ensure frontend is deployed separately from backend
- Check the build output directory is `build/web`
- Verify rewrites are configured in vercel.json

## Cost Estimation

- **Vercel Postgres**: Free tier includes 512MB database, 60 hours compute/month
- **Vercel Blob**: Free tier includes 500GB storage, 1TB bandwidth/month
- **Vercel Hosting**: Free tier includes 100GB bandwidth/month
- **OpenAI**: ~$0.001 per 1K tokens (gpt-4o-mini)

For a small number of users, the free tiers should be sufficient.

## Monitoring

1. Monitor Vercel deployment logs
2. Track Vercel Postgres usage in dashboard
3. Monitor Vercel Blob storage usage
4. Track OpenAI API usage in OpenAI Dashboard
5. Set up Vercel alerts for errors and failures
