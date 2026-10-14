import { NextRequest, NextResponse } from 'next/server';
import OpenAI from 'openai';
import { db } from '../../../lib/db';
import { scanHistory } from '../../../lib/schema';

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
    // For now, we'll extract user_id from the header (replace with proper JWT verification)
    const userId = authHeader.replace('Bearer ', '');

    const body = await request.json();
    const text = typeof body.text === 'string' ? body.text.trim() : '';
    const imageDataUrl = typeof body.image_data_url === 'string' ? body.image_data_url : '';

    if (!text && !imageDataUrl) {
      return NextResponse.json(
        { error: 'Provide text or image_data_url.' },
        { status: 400 }
      );
    }

    if (text.length > 30000 || imageDataUrl.length > 8_000_000) {
      return NextResponse.json({ error: 'Input is too large.' }, { status: 413 });
    }

    if (imageDataUrl && !/^data:image\/(jpeg|jpg|png|webp);base64,/i.test(imageDataUrl)) {
      return NextResponse.json({ error: 'Unsupported image format.' }, { status: 400 });
    }

    const instructions = `
You are LifeLens AI, a document-to-action assistant.

Read the supplied text or image. For images, transcribe the visible
text as accurately as possible, including supported handwriting.
Detect the language of the document, not just the user's app language.

Return ONLY valid JSON with this shape:
{
  "detected_language": "language name or unknown",
  "extracted_text": "recognized text",
  "summary": "short factual summary",
  "tasks": [
    {
      "title": "clear action",
      "description": "details if needed",
      "due_date": "YYYY-MM-DD or null",
      "priority": "low, medium, or high",
      "source_evidence": "short exact supporting text",
      "uncertainty": "explain uncertainty or empty string"
    }
  ],
  "warnings": ["unreadable or ambiguous details"]
}

Rules:
- Never invent names, amounts, dates, deadlines, or requirements.
- Use null for a date that cannot be determined reliably.
- Resolve relative dates only when the document gives enough context.
- Include evidence from the document for each task.
- Flag unclear handwriting instead of guessing.
- Extract actionable tasks only; do not turn every sentence into a task.
- Return an empty tasks array if there are no clear actions.
- The user must review the results before tasks are saved as confirmed.
`;

    const content: Array<{ type: string; text?: string; image_url?: { url: string; detail: string } }> = [
      { type: 'text', text: instructions },
    ];

    if (text) {
      content.push({
        type: 'text',
        text: `Document text supplied by the user:\n${text}`,
      });
    }

    if (imageDataUrl) {
      content.push({
        type: 'image_url',
        image_url: { url: imageDataUrl, detail: 'high' },
      });
    }

    const aiResponse = await openai.chat.completions.create({
      model: 'gpt-4o-mini',
      messages: [
        { role: 'user', content: content as any },
      ],
      response_format: { type: 'json_object' },
      temperature: 0.1,
    });

    const resultText = aiResponse.choices?.[0]?.message?.content;

    if (!resultText) {
      return NextResponse.json({ error: 'AI returned an empty result.' }, { status: 502 });
    }

    const result = JSON.parse(resultText);

    // Store the analysis history, but NOT its suggested tasks yet.
    const [scan] = await db
      .insert(scanHistory)
      .values({
        userId,
        originalText: result.extracted_text ?? text ?? '',
        detectedLanguage: result.detected_language ?? 'unknown',
        summary: result.summary ?? '',
      })
      .returning();

    return NextResponse.json({
      scan_id: scan.id,
      created_at: scan.createdAt,
      analysis: result,
      requires_review: true,
    });
  } catch (error) {
    console.error('Analysis error:', error);
    return NextResponse.json({ error: 'Unexpected analysis error.' }, { status: 500 });
  }
}

export const dynamic = 'force-dynamic';
