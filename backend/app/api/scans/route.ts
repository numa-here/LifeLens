import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/db';
import { scanHistory } from '@/lib/schema';
import { eq } from 'drizzle-orm';

// GET all scans for a user
export async function GET(request: NextRequest) {
  try {
    const authHeader = request.headers.get('authorization');
    if (!authHeader) {
      return NextResponse.json({ error: 'Sign-in required.' }, { status: 401 });
    }

    const userId = authHeader.replace('Bearer ', '');

    const userScans = await db
      .select()
      .from(scanHistory)
      .where(eq(scanHistory.userId, userId))
      .orderBy(scanHistory.createdAt);

    return NextResponse.json({ scans: userScans });
  } catch (error) {
    console.error('Get scans error:', error);
    return NextResponse.json({ error: 'Failed to fetch scans.' }, { status: 500 });
  }
}

export const dynamic = 'force-dynamic';
