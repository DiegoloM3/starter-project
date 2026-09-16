// The editorial assistant, independent of Firebase so it can be tested with
// a fake Anthropic client. index.js wraps it as a callable function.

import { buildPrompt, parseAnswer } from './prompts.js';
import { ValidationError, validateRequest } from './validate.js';

/** Fast and inexpensive: a phone should not wait on a long generation. */
export const MODEL = 'claude-haiku-4-5-20251001';

/**
 * The plain rewrite keeps every fact of an article of up to CONTENT_MAX
 * characters (about 5 000 tokens), so the answer needs about as much room
 * as the input plus the JSON wrapper.
 */
export const MAX_TOKENS = 8192;

export class AssistantError extends Error {
  /** @param {'unauthenticated'|'invalid-argument'|'resource-exhausted'|'unavailable'|'internal'} code */
  constructor(code, message) {
    super(message);
    this.name = 'AssistantError';
    this.code = code;
  }
}

/**
 * Runs one assistant task for a signed-in caller.
 * @param {{ auth?: { uid: string } | null, data: unknown }} request
 * @param {{ messages: { create: Function } }} client an Anthropic client
 */
export async function assist(request, client) {
  if (!request.auth?.uid) {
    throw new AssistantError('unauthenticated', 'Sign in to use the editor.');
  }

  let input;
  try {
    input = validateRequest(request.data);
  } catch (error) {
    if (error instanceof ValidationError) throw new AssistantError('invalid-argument', error.message);
    throw error;
  }

  const { system, user } = buildPrompt(input);
  let response;
  try {
    response = await client.messages.create({
      model: MODEL,
      max_tokens: MAX_TOKENS,
      system,
      messages: [{ role: 'user', content: user }],
    });
  } catch (error) {
    throw new AssistantError(codeForSdkError(error), 'The editor could not be reached.');
  }

  const text = (response.content ?? [])
    .filter((block) => block.type === 'text')
    .map((block) => block.text)
    .join('\n');

  try {
    return parseAnswer(input.task, text);
  } catch (error) {
    throw new AssistantError('internal', `The editor gave an unusable answer: ${error.message}`);
  }
}

function codeForSdkError(error) {
  const status = error?.status ?? error?.statusCode;
  if (status === 429) return 'resource-exhausted';
  if (status === 401 || status === 403) return 'internal';
  if (status >= 500 || status === undefined) return 'unavailable';
  return 'internal';
}
