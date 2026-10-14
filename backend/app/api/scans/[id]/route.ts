import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/db';
import { scanHistory } from '@/lib/schema';
import { eq } from 'drizzle-orm';

// DELETE a scan
export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const authHeader = request.headers.get('authorization');
    if (!authHeader) {
      return NextResponse.json({ error: 'Sign-in required.' }, { status: 401 });
    }

    const userId = authHeader.replace('Bearer ', '');
    const scanId = params.id;

    const [deletedScan] = await db
      .delete(scanHistory)
      .where(eq(scanHistory.id, scanId))
      .returning();

    if (!deletedScan) {
      return NextResponse.json({ error: 'Scan not found.' }, { status: 404 });
    }

    return NextResponse.json({ success: true });
  } catch (error) {
    console.error('Delete scan error:', error);
    return NextResponse.json({ error: 'Failed to delete scan.' }, { status: 500 });
  }
}

export const dynamic = 'force-dynamic';
