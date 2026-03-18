// supabase/functions/verify-aadhaar/index.ts
//
// DEPLOY COMMAND (run from your project root):
//   supabase functions deploy verify-aadhaar --no-verify-jwt
//
// SET SECRET (run once):
//   supabase secrets set ANTHROPIC_API_KEY=sk-ant-api03-YOUR_REAL_KEY_HERE
//
// The function receives: { imageBase64, mimeType, registeredName }
// It returns:            { verified, checks, extractedName, extractedAadhaarNumber, failureReason }

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS_HEADERS });
  }

  try {
    // ── Parse request body ───────────────────────────────────────────────────
    const { imageBase64, mimeType, registeredName } = await req.json();

    if (!imageBase64 || !mimeType || !registeredName) {
      return new Response(
        JSON.stringify({ error: "Missing required fields: imageBase64, mimeType, registeredName" }),
        { status: 400, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } }
      );
    }

    // ── Get Anthropic API key from Supabase secrets ──────────────────────────
    const anthropicKey = Deno.env.get("ANTHROPIC_API_KEY");
    if (!anthropicKey) {
      return new Response(
        JSON.stringify({ error: "ANTHROPIC_API_KEY secret not set. Run: supabase secrets set ANTHROPIC_API_KEY=sk-ant-..." }),
        { status: 500, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } }
      );
    }

    // ── Build OCR verification prompt ────────────────────────────────────────
    const prompt = `You are an AI OCR and KYC verification system for an Indian aquaculture platform.

A user uploaded a photo of their Aadhaar card. It may be rotated, inside a plastic sleeve, partially visible, or in varying lighting. Mentally correct orientation and extract all readable text.

REGISTERED NAME TO MATCH: "${registeredName}"

Perform exactly THREE checks:

CHECK 1 — GOVERNMENT OF INDIA IDENTIFIER
Look for ANY of the following (even partial text counts):
• "Government of India" or partial: "ent of India", "t of India", "Govt of India"
• "भारत सरकार" (Bharat Sarkar) — Hindi for Government of India
• Ashoka Pillar / Lion Capital emblem (top-left of card)
• "सत्यमेव जयते" (Satyamev Jayate)
• Tricolor stripe design (saffron + green bands at top)
• Aadhaar yellow sun/fingerprint logo (top-right corner)
• QR code anywhere on the card
• "आधार", "Aadhaar", or "UIDAI" text
• "मेरा आधार, मेरी पहचान" (Mera Aadhaar, Meri Pehchaan)
If ANY ONE indicator is found → emblem_present: true

CHECK 2 — NAME MATCH
Extract ALL text from the card. Find the person's name (near their photo, not an address).
Compare with: "${registeredName}"
Rules:
• Case-insensitive match
• Ignore spaces, dots, punctuation
• Allow 1-2 OCR character errors
• Substring match is acceptable
• If name appears twice (English + regional script), either match counts
• If name area is blurred/obscured → name_match: true (benefit of doubt)
• Only false if a CLEARLY DIFFERENT readable name is found

CHECK 3 — AADHAAR NUMBER FORMAT
Find any 12-digit number pattern on the card:
• Format: XXXX XXXX XXXX (groups of 4 with spaces)
• May be continuous digits due to rotation: e.g. "372832388159"
• Located at bottom-center typically
• Must be exactly 12 digits total
• Any valid 12-digit pattern → aadhaar_format_valid: true

RESPOND ONLY WITH VALID JSON — no markdown, no explanation, no preamble:
{
  "verified": true_or_false,
  "checks": {
    "emblem_present": true_or_false,
    "name_match": true_or_false,
    "aadhaar_format_valid": true_or_false
  },
  "extracted_name": "name as read from card, or null",
  "extracted_aadhaar_number": "12 digits extracted (no spaces), or null",
  "failure_reason": "brief plain English reason if verified is false, otherwise null"
}

verified = true ONLY when ALL THREE checks pass.
Be maximally lenient on image quality — reject only clear fraud.`;

    // ── Call Anthropic API ───────────────────────────────────────────────────
    const anthropicResponse = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "x-api-key": anthropicKey,
        "anthropic-version": "2023-06-01",
        "content-type": "application/json",
      },
      body: JSON.stringify({
        model: "claude-opus-4-5",
        max_tokens: 500,
        messages: [
          {
            role: "user",
            content: [
              {
                type: "image",
                source: {
                  type: "base64",
                  media_type: mimeType,
                  data: imageBase64,
                },
              },
              { type: "text", text: prompt },
            ],
          },
        ],
      }),
    });

    // ── Handle Anthropic errors ──────────────────────────────────────────────
    if (anthropicResponse.status === 401) {
      return new Response(
        JSON.stringify({ error: "Invalid Anthropic API key. Set it with: supabase secrets set ANTHROPIC_API_KEY=sk-ant-..." }),
        { status: 500, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } }
      );
    }
    if (anthropicResponse.status === 429) {
      return new Response(
        JSON.stringify({ error: "Anthropic rate limit hit. Please wait and try again." }),
        { status: 429, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } }
      );
    }
    if (!anthropicResponse.ok) {
      return new Response(
        JSON.stringify({ error: `Anthropic API error: ${anthropicResponse.status}` }),
        { status: 500, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } }
      );
    }

    // ── Parse Anthropic response ─────────────────────────────────────────────
    const anthropicBody = await anthropicResponse.json();
    const rawText: string = anthropicBody.content
      .filter((c: { type: string }) => c.type === "text")
      .map((c: { text: string }) => c.text)
      .join("");

    // Strip any accidental markdown fences
    const cleanJson = rawText
      .replace(/```json/g, "")
      .replace(/```/g, "")
      .trim();

    let result: {
      verified: boolean;
      checks: {
        emblem_present: boolean;
        name_match: boolean;
        aadhaar_format_valid: boolean;
      };
      extracted_name: string | null;
      extracted_aadhaar_number: string | null;
      failure_reason: string | null;
    };

    try {
      result = JSON.parse(cleanJson);
    } catch {
      return new Response(
        JSON.stringify({ error: "Failed to parse AI response as JSON", raw: rawText }),
        { status: 500, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } }
      );
    }

    // ── Return result to Flutter app ─────────────────────────────────────────
    return new Response(
      JSON.stringify({
        verified:                result.verified ?? false,
        checks:                  result.checks ?? {},
        extractedName:           result.extracted_name ?? null,
        extractedAadhaarNumber:  result.extracted_aadhaar_number ?? null,
        failureReason:           result.failure_reason ?? null,
      }),
      {
        status: 200,
        headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
      }
    );

  } catch (err) {
    return new Response(
      JSON.stringify({ error: `Edge function error: ${err}` }),
      { status: 500, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } }
    );
  }
});
