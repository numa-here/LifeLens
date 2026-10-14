import { NextRequest, NextResponse } from 'next/server';
import { db } from '../../../lib/db';
import { tasks } from '../../../lib/schema';
import { eq, and, ne } from 'drizzle-orm';

// GET all tasks for a user
export async function GET(request: NextRequest) {
  try {
    const authHeader = request.headers.get('authorization');
    if (!authHeader) {
      return NextResponse.json({ error: 'Sign-in required.' }, { status: 401 });
    }

    const userId = authHeader.replace('Bearer ', '');

    const { searchParams } = new URL(request.url);
    const status = searchParams.get('status');

    let query = db.select().from(tasks).where(eq(tasks.userId, userId));

    if (status) {
      query = query.where(and(eq(tasks.userId, userId), eq(tasks.status, status)));
    }

    const userTasks = await query.orderBy(tasks.dueDate);

    return NextResponse.json({ tasks: userTasks });
  } catch (error) {
    console.error('Get tasks error:', error);
    return NextResponse.json({ error: 'Failed to fetch tasks.' }, { status: 500 });
  }
}

// POST create a new task
export async function POST(request: NextRequest) {
  try {
    const authHeader = request.headers.get('authorization');
    if (!authHeader) {
      return NextResponse.json({ error: 'Sign-in required.' }, { status: 401 });
    }

    const userId = authHeader.replace('Bearer ', '');

    const body = await request.json();
    const { scanId, title, description, dueDate, priority, sourceEvidence } = body;

    if (!title) {
      return NextResponse.json({ error: 'Title is required.' }, { status: 400 });
    }

    const [newTask] = await db
      .insert(tasks)
      .values({
        userId,
        scanId,
        title,
        description,
        dueDate,
        priority: priority || 'medium',
        sourceEvidence,
        status: 'pending',
      })
      .returning();

    return NextResponse.json({ task: newTask }, { status: 201 });
  } catch (error) {
    console.error('Create task error:', error);
    return NextResponse.json({ error: 'Failed to create task.' }, { status: 500 });
  }
}

export const dynamic = 'force-dynamic';
