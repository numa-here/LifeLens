import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const json = (data: unknown, status = 200) =>
  new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return json({ error: "Use POST." }, 405);
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) return json({ error: "Sign-in required." }, 401);

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const openaiKey = Deno.env.get("OPENAI_API_KEY");

    if (!openaiKey) {
      return json({ error: "AI service is not configured." }, 500);
    }

    const supabase = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const { data: userData, error: userError } =
      await supabase.auth.getUser();

    if (userError || !userData.user) {
      return json({ error: "Invalid session." }, 401);
    }

    const body = await req.json();
    const text = typeof body.text === "string" ? body.text.trim() : "";
    const imageDataUrl =
      typeof body.image_data_url === "string"
        ? body.image_data_url
        : "";

    if (!text && !imageDataUrl) {
      return json(
        { error: "Provide text or image_data_url." },
        400,
      );
    }

    // Starter input validation. Add stricter image-size and MIME checks
    // before using this with real users.
    if (text.length > 30000 || imageDataUrl.length > 8_000_000) {
      return json({ error: "Input is too large." }, 413);
    }

    if (
      imageDataUrl &&
      !/^data:image\/(jpeg|jpg|png|webp);base64,/i.test(imageDataUrl)
    ) {
      return json({ error: "Unsupported image format." }, 400);
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

    const content: Array<Record<string, unknown>> = [
      { type: "text", text: instructions },
    ];

    if (text) {
      content.push({
        type: "text",
        text: `Document text supplied by the user:\n${text}`,
      });
    }

    if (imageDataUrl) {
      content.push({
        type: "image_url",
        image_url: { url: imageDataUrl, detail: "high" },
      });
    }

    const aiResponse = await fetch(
      "https://api.openai.com/v1/chat/completions",
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${openaiKey}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          model: "gpt-4o-mini",
          messages: [
            { role: "user", content },
          ],
          response_format: { type: "json_object" },
          temperature: 0.1,
        }),
      },
    );

    if (!aiResponse.ok) {
      console.error("AI provider error:", await aiResponse.text());
      return json({ error: "Document analysis failed." }, 502);
    }

    const aiData = await aiResponse.json();
    const resultText = aiData.choices?.[0]?.message?.content;

    if (!resultText) {
      return json({ error: "AI returned an empty result." }, 502);
    }

    const result = JSON.parse(resultText);

    // Store the analysis history, but NOT its suggested tasks yet.
    const { data: scan, error: scanError } = await supabase
      .from("scan_history")
      .insert({
        user_id: userData.user.id,
        original_text: result.extracted_text ?? text ?? "",
        detected_language: result.detected_language ?? "unknown",
        summary: result.summary ?? "",
      })
      .select("id, created_at")
      .single();

    if (scanError) {
      console.error("Scan history save failed:", scanError.message);
      return json({ error: "Could not save scan history." }, 500);
    }

    return json({
      scan_id: scan.id,
      created_at: scan.created_at,
      analysis: result,
      requires_review: true,
    });
  } catch (error) {
    console.error("Analysis error:", error);
    return json({ error: "Unexpected analysis error." }, 500);
  }
});
