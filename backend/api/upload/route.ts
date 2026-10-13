import { NextRequest, NextResponse } from 'next/server';
import { put } from '@vercel/blob';

export async function POST(request: NextRequest) {
  try {
    const authHeader = request.headers.get('authorization');
    if (!authHeader) {
      return NextResponse.json({ error: 'Sign-in required.' }, { status: 401 });
    }

    // In production, verify the JWT token here
    const userId = authHeader.replace('Bearer ', '');

    const formData = await request.formData();
    const file = formData.get('file') as File;

    if (!file) {
      return NextResponse.json({ error: 'No file provided.' }, { status: 400 });
    }

    // Validate file type
    const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
    if (!allowedTypes.includes(file.type)) {
      return NextResponse.json({ error: 'Unsupported file type.' }, { status: 400 });
    }

    // Validate file size (max 10MB)
    if (file.size > 10 * 1024 * 1024) {
      return NextResponse.json({ error: 'File too large. Max 10MB.' }, { status: 413 });
    }

    // Generate unique filename
    const fileExtension = file.name.split('.').pop();
    const uniqueId = `${Date.now()}-${Math.random().toString(36).substring(7)}`;
    const filename = `${userId}/${uniqueId}.${fileExtension}`;

    // Upload to Vercel Blob
    const blob = await put(filename, file, {
      access: 'private',
    });

    return NextResponse.json({
      url: blob.url,
      pathname: blob.pathname,
      size: blob.size,
      uploadedAt: blob.uploadedAt,
    });
  } catch (error) {
    console.error('Upload error:', error);
    return NextResponse.json({ error: 'Failed to upload file.' }, { status: 500 });
  }
}

export const dynamic = 'force-dynamic';
