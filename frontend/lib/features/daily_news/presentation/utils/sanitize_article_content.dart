// Cleans the `content` field that NewsAPI returns before it is rendered.
//
// NewsAPI's `content` arrives in several shapes:
//
//   - Normal truncated text: "Local\r\nUPDATE: ... [+2978 chars]"
//     → strip the trailing "[+N chars]" marker, normalize CRLF to LF.
//
//   - Scraper junk from blocked pages: a JSON dictionary of translation
//     strings, e.g. '{"en":{"access_disabled":"..."}} [+6792 chars]' or a
//     truncated variant that ends mid-string before the JSON closes.
//     → return null so the UI falls back to "Full article available at the
//     source." instead of pasting JSON into the body.
//
//   - Null, empty, or whitespace-only.
//     → return null.
//
// Returning `null` is the signal to the widget layer that there is no
// renderable body text. Callers should show the fallback copy in that case.

// Matches strings that begin with a JSON object or array keyed by a
// quoted identifier, e.g. '{"en":{"access_disabled":...' or '[{"foo":'.
// Regex reasoning: scraper dumps always start with an opening brace/bracket
// followed by a quoted key and a colon. Article prose that happens to start
// with `{` (LaTeX, code samples) is extremely unlikely to have that exact
// shape, and truncated JSON is still caught because the detection only looks
// at the prefix — not at whether the structure is complete and parseable.
final _jsonJunkPrefix = RegExp(r'^\s*[\{\[][\{\[\s,]*"[^"]+"\s*:');

String? sanitizeArticleContent(String? raw) {
  if (raw == null) return null;

  // Normalize line endings first so downstream checks work uniformly.
  var cleaned = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

  // Strip the "[+N chars]" suffix NewsAPI appends to every truncated body.
  cleaned = cleaned.replaceAll(RegExp(r'\s*\[\+\d+\s+chars\]\s*$'), '');

  final trimmed = cleaned.trim();
  if (trimmed.isEmpty) return null;

  if (_jsonJunkPrefix.hasMatch(trimmed)) return null;

  return trimmed;
}
