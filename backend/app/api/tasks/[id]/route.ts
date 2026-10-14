import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/db';
import { tasks } from '@/lib/schema';
import { eq, and } from 'drizzle-orm';

// PUT update a task
export async function PUT(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const authHeader = request.headers.get('authorization');
    if (!authHeader) {
      return NextResponse.json({ error: 'Sign-in required.' }, { status: 401 });
    }

    const userId = authHeader.replace('Bearer ', '');
    const taskId = params.id;

    const body = await request.json();
    const { title, description, dueDate, priority, status } = body;

    const [updatedTask] = await db
      .update(tasks)
      .set({
        title,
        description,
        dueDate,
        priority,
        status,
      })
      .where(and(eq(tasks.id, taskId), eq(tasks.userId, userId)))
      .returning();

    if (!updatedTask) {
      return NextResponse.json({ error: 'Task not found.' }, { status: 404 });
    }

    return NextResponse.json({ task: updatedTask });
  } catch (error) {
    console.error('Update task error:', error);
    return NextResponse.json({ error: 'Failed to update task.' }, { status: 500 });
  }
}

// DELETE a task
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
    const taskId = params.id;

    const [deletedTask] = await db
      .delete(tasks)
      .where(and(eq(tasks.id, taskId), eq(tasks.userId, userId)))
      .returning();

    if (!deletedTask) {
      return NextResponse.json({ error: 'Task not found.' }, { status: 404 });
    }

    return NextResponse.json({ success: true });
  } catch (error) {
    console.error('Delete task error:', error);
    return NextResponse.json({ error: 'Failed to delete task.' }, { status: 500 });
  }
}

export const dynamic = 'force-dynamic';
