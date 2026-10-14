import { NextRequest, NextResponse } from 'next/server';
import OpenAI from 'openai';
import { db } from '@/lib/db';
import { tasks } from '@/lib/schema';
import { eq, ne } from 'drizzle-orm';

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

export async function POST(request: NextRequest) {
  try {
    const authHeader = request.headers.get('authorization');
    if (!authHeader) {
      return NextResponse.json({ error: 'Sign-in required.' }, { status: 401 });
    }

    // In production, verify the JWT token here
    const userId = authHeader.replace('Bearer ', '');

    const userTasks = await db
      .select({
        id: tasks.id,
        title: tasks.title,
        description: tasks.description,
        dueDate: tasks.dueDate,
        priority: tasks.priority,
        status: tasks.status,
      })
      .from(tasks)
      .where(ne(tasks.status, 'completed'))
      .orderBy(tasks.dueDate);

    if (!userTasks || userTasks.length === 0) {
      return NextResponse.json({
        date: new Date().toISOString().slice(0, 10),
        briefing: 'You have no pending tasks. Add a task when something needs your attention.',
        next_actions: [],
      });
    }

    const today = new Date().toISOString().slice(0, 10);

    const response = await openai.chat.completions.create({
      model: 'gpt-4o-mini',
      messages: [
        {
          role: 'system',
          content: `
You are LifeLens AI's daily planning assistant.
Return JSON with:
{
  "briefing": "short daily briefing",
  "next_actions": [
    {
      "task_id": "existing task ID",
      "reason": "why to do it next"
    }
  ]
}
Select at most 3 next actions. Prefer overdue tasks, then the nearest
known deadlines and high-priority tasks. Do not invent deadlines or
claim a task is overdue without a known date. Use only supplied tasks.
Do not modify or mark tasks complete.
              `.trim(),
        },
        {
          role: 'user',
          content: JSON.stringify({ today, tasks: userTasks }),
        },
      ],
      response_format: { type: 'json_object' },
      temperature: 0.2,
    });

    const content = response.choices?.[0]?.message?.content;

    if (!content) {
      return NextResponse.json({ error: 'AI returned an empty briefing.' }, { status: 502 });
    }

    const briefing = JSON.parse(content);

    return NextResponse.json({
      date: today,
      briefing: briefing.briefing,
      next_actions: briefing.next_actions,
    });
  } catch (error) {
    console.error('Briefing error:', error);
    return NextResponse.json({ error: 'Unexpected briefing error.' }, { status: 500 });
  }
}

export const dynamic = 'force-dynamic';
