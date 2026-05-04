import { createHash } from 'crypto';

// Unicode Start-of-Header: cannot appear in normal user text, preventing hash
// collisions between adjacent fields (e.g. ('ab','cd','') vs ('a','','bcd')).
export const ARTICLE_TEXT_FIELD_SEPARATOR = '\x01';

// Well under the embedding provider's effective input cap (~8 KB).
// Truncation applies only to the embed() call — NOT to the idempotency hash.
export const EMBED_TEXT_MAX_CHARS = 8000;

interface ArticleTextSource {
  title?: string;
  description?: string;
  content?: string;
}

export function composeArticleText(article: ArticleTextSource): string {
  const title = article.title ?? '';
  const description = article.description ?? '';
  const content = article.content ?? '';
  return [title, description, content].join(ARTICLE_TEXT_FIELD_SEPARATOR);
}

export function sha256(text: string): string {
  return createHash('sha256').update(text, 'utf8').digest('hex');
}

// The embedding source hash is what the trigger compares against to decide
// whether to re-embed. It MUST cover (a) the composed text, (b) the active
// embedding model, and (c) the task-type contract — because changing any of
// the three invalidates the stored vector. Mixing them in the same hash
// means a provider swap (Gemini → OpenAI) or task-type fix auto-invalidates
// all stored embeddings: next write fires the trigger and re-embeds with
// the current configuration. No manual backfill required.
export function embeddingSourceHash(
  composedText: string,
  modelName: string,
): string {
  return sha256(
    [modelName, composedText].join(ARTICLE_TEXT_FIELD_SEPARATOR),
  );
}

export function truncateForEmbed(text: string): string {
  if (text.length <= EMBED_TEXT_MAX_CHARS) return text;
  return text.slice(0, EMBED_TEXT_MAX_CHARS);
}
