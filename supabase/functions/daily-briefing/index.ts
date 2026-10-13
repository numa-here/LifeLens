import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return json({ error: "Use POST." }, 405);
  }

  try {
    const authorization = req.headers.get("Authorization");
    if (!authorization) {
      return json({ error: "Sign-in required." }, 401);
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authorization } } },
    );

    const { data: userData, error: authError } =
      await supabase.auth.getUser();

    if (authError || !userData.user) {
      return json({ error: "Invalid session." }, 401);
    }

    const { data: tasks, error: taskError } = await supabase
      .from("tasks")
      .select("id, title, description, due_date, priority, status")
      .neq("status", "completed")
      .order("due_date", { ascending: true, nullsFirst: false })
      .limit(100);

    if (taskError) {
      console.error("Task query failed:", taskError.message);
      return json({ error: "Could not load your tasks." }, 500);
    }

    if (!tasks?.length) {
      return json({
        date: new Date().toISOString().slice(0, 10),
        briefing: "You have no pending tasks. Add a task when something needs your attention.",
        next_actions: [],
      });
    }

    const apiKey = Deno.env.get("OPENAI_API_KEY");
    if (!apiKey) {
      return json({ error: "AI service is not configured." }, 500);
    }

    const today = new Date().toISOString().slice(0, 10);

    const response = await fetch(
      "https://api.openai.com/v1/chat/completions",
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${apiKey}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          model: "gpt-4o-mini",
          messages: [
            {
              role: "system",
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
              role: "user",
              content: JSON.stringify({ today, tasks }),
            },
          ],
          response_format: { type: "json_object" },
          temperature: 0.2,
        }),
      },
    );

    if (!response.ok) {
      console.error("AI provider error:", await response.text());
      return json({ error: "Could not generate briefing." }, 502);
    }

    const payload = await response.json();
    const content = payload.choices?.[0]?.message?.content;

    if (!content) {
      return json({ error: "AI returned an empty briefing." }, 502);
    }

    const briefing = JSON.parse(content);

    return json({
      date: today,
      briefing: briefing.briefing,
      next_actions: briefing.next_actions,
    });
  } catch (error) {
    console.error("Briefing error:", error);
    return json({ error: "Unexpected briefing error." }, 500);
  }
});
