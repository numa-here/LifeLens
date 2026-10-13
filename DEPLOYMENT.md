# LifeLens Deployment Guide

## Backend Deployment (Omema's Part)

### Prerequisites
- Supabase account (https://supabase.com)
- OpenAI API key (https://platform.openai.com/api-keys)
- Supabase CLI installed (https://supabase.com/docs/guides/cli)
- Docker installed (required for local Supabase development)

### Step 1: Create Supabase Project
1. Go to https://supabase.com/dashboard
2. Click "New Project"
3. Choose organization (or create one)
4. Enter project name: `LifeLens`
5. Set database password (save it securely)
6. Choose region closest to your users
7. Click "Create new project"
8. Wait for project to be ready (2-3 minutes)

### Step 2: Configure Google OAuth
1. In Supabase Dashboard, go to **Authentication** → **Providers**
2. Click on **Google**
3. Click **Enable Google provider**
4. You'll need:
   - Google Cloud Console project
   - OAuth 2.0 Client ID
   - OAuth 2.0 Client Secret
5. Configure redirect URLs:
   - Add your app's callback URL (e.g., `io.supabase.lifelens://**`)
   - For Flutter, use the custom URL scheme you configure
6. Save the configuration

### Step 3: Create Private Storage Bucket
1. In Supabase Dashboard, go to **Storage**
2. Click **New bucket**
3. Name it: `documents`
4. **Important**: Set to **Private** (not public)
5. Click **Create bucket**

### Step 4: Run Database Migrations
1. In Supabase Dashboard, go to **SQL Editor**
2. Click **New query**
3. Copy and paste the contents of `supabase/migrations/001_create_tables.sql`
4. Click **Run** (or press Ctrl+Enter)
5. Create a new query and paste `supabase/migrations/002_storage_policies.sql`
6. Click **Run**
7. Verify both tables were created successfully

### Step 5: Install and Configure Supabase CLI
```bash
# Install Supabase CLI (if not already installed)
# Windows: Use winget or download from https://supabase.com/docs/guides/cli
winget install Supabase.CLI

# Login to Supabase
supabase login

# Link to your project
supabase link --project-ref YOUR_PROJECT_REF
```

You can find your project reference in Supabase Dashboard:
- Project Settings → General → Project Reference

### Step 6: Set Environment Variables
```bash
# Set your OpenAI API key as a secret
supabase secrets set OPENAI_API_KEY=your_actual_openai_key_here
```

**Important**: Never commit your API key to GitHub. The `secrets set` command stores it securely in Supabase.

### Step 7: Deploy Edge Functions
```bash
# Deploy the analyze-document function
supabase functions deploy analyze-document

# Deploy the daily-briefing function
supabase functions deploy daily-briefing
```

You should see output like:
```
Deployed functions:
  - analyze-document (https://xxx.supabase.co/functions/v1/analyze-document)
  - daily-briefing (https://xxx.supabase.co/functions/v1/daily-briefing)
```

### Step 8: Get Supabase Configuration for Flutter
In Supabase Dashboard, go to **Project Settings** → **API**:

Copy these values and add them to your Flutter app:
- **Project URL** (supabaseUrl)
- **anon/public** key (supabaseAnonKey)

Add them to your Flutter app's environment or configuration (not in the code).

### Step 9: Test the Backend APIs

#### Test analyze-document
Use Supabase Dashboard's **Edge Functions** → **analyze-document** → **Invoke**:

```json
{
  "text": "Submit the application form by 20 October 2026. Attach two photographs."
}
```

Expected response:
```json
{
  "scan_id": "uuid",
  "created_at": "2026-10-13T...",
  "analysis": {
    "detected_language": "English",
    "extracted_text": "Submit the application form by 20 October 2026. Attach two photographs.",
    "summary": "Application submission is required.",
    "tasks": [...],
    "warnings": []
  },
  "requires_review": true
}
```

#### Test daily-briefing
Use Supabase Dashboard's **Edge Functions** → **daily-briefing** → **Invoke**:

```json
{}
```

Expected response:
```json
{
  "date": "2026-10-13",
  "briefing": "You have no pending tasks...",
  "next_actions": []
}
```

### Step 10: Verify Security Policies
1. Create a test user in Supabase Dashboard → Authentication
2. Try to access another user's data - should be blocked by RLS
3. Verify storage policies by trying to upload to wrong user folder - should be blocked

## Frontend Deployment (Numa's Part)

### For Web Deployment (Vercel)
1. Build the Flutter web app:
```bash
cd frontend
flutter build web --release
```

2. Deploy to Vercel:
```bash
npm install -g vercel
cd build/web
vercel
```

3. Add Supabase environment variables in Vercel dashboard:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`

### For Mobile Deployment
1. Android: Build APK/AAB and upload to Google Play Console
2. iOS: Build IPA and upload to App Store Connect

## Troubleshooting

### Edge Function Fails to Deploy
- Check Supabase CLI is linked correctly: `supabase status`
- Verify project reference is correct
- Check Docker is running

### Function Returns 500 Error
- Check logs in Supabase Dashboard → Edge Functions → Logs
- Verify OPENAI_API_KEY is set: `supabase secrets list`
- Check model name (gpt-4o-mini) is available in your OpenAI account

### Storage Upload Fails
- Verify bucket name is exactly `documents`
- Check storage policies are applied
- Ensure upload path follows format: `<user-id>/<filename>`

### Google OAuth Fails
- Verify redirect URLs match your Flutter app's configuration
- Check Google Cloud Console has correct OAuth consent screen
- Ensure client ID and secret are correct in Supabase

## Security Checklist

- [ ] OPENAI_API_KEY is set via `supabase secrets set` (not in code)
- [ ] Storage bucket is set to Private
- [ ] Row-level security is enabled on both tables
- [ ] Google OAuth redirect URLs are configured
- [ ] No API keys are committed to GitHub
- [ ] Database policies are tested with multiple users
- [ ] Storage policies are tested with different user folders

## Post-Deployment Monitoring

1. Monitor Edge Function logs in Supabase Dashboard
2. Track API usage in OpenAI Dashboard
3. Monitor database size and storage usage in Supabase
4. Set up alerts for failed function invocations
5. Review scan history and task data quality

## Cost Estimation

- **Supabase Free Tier**: 500MB database, 1GB storage, 2GB bandwidth/month
- **OpenAI**: ~$0.001 per 1K tokens (gpt-4o-mini)
- **Edge Functions**: Included in Supabase free tier (with limits)

For a small number of users, the free tiers should be sufficient.
