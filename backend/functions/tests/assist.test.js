import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { AssistantError, MODEL, assist } from '../assist.js';

/** An Anthropic client that answers with a fixed text or throws. */
function fakeClient({ text, error } = {}) {
  const calls = [];
  return {
    calls,
    messages: {
      async create(params) {
        calls.push(params);
        if (error) throw error;
        return { content: [{ type: 'text', text }] };
      },
    },
  };
}

const signedIn = { uid: 'journalist-1' };

describe('assist', () => {
  it('refuses anonymous callers before touching the model', async () => {
    const client = fakeClient({ text: '{}' });
    await assert.rejects(
      assist({ auth: null, data: { task: 'brief', content: 'x' } }, client),
      (e) => e instanceof AssistantError && e.code === 'unauthenticated',
    );
    assert.equal(client.calls.length, 0);
  });

  it('turns validation problems into invalid-argument', async () => {
    await assert.rejects(
      assist({ auth: signedIn, data: { task: 'nope', content: 'x' } }, fakeClient()),
      (e) => e.code === 'invalid-argument',
    );
  });

  it('asks the configured model and returns the parsed suggestion', async () => {
    const client = fakeClient({
      text: '{"headlines":["A","B","C"],"summary":"S"}',
    });

    const result = await assist({ auth: signedIn, data: { task: 'suggest', title: 'T', content: 'Body' } }, client);

    assert.deepEqual(result, { headlines: ['A', 'B', 'C'], summary: 'S' });
    assert.equal(client.calls[0].model, MODEL);
    assert.match(client.calls[0].messages[0].content, /Title: T/);
  });

  it('maps model outages and rate limits to callable error codes', async () => {
    const limited = Object.assign(new Error('rate'), { status: 429 });
    const down = Object.assign(new Error('down'), { status: 503 });
    await assert.rejects(
      assist({ auth: signedIn, data: { task: 'brief', content: 'x' } }, fakeClient({ error: limited })),
      (e) => e.code === 'resource-exhausted',
    );
    await assert.rejects(
      assist({ auth: signedIn, data: { task: 'brief', content: 'x' } }, fakeClient({ error: down })),
      (e) => e.code === 'unavailable',
    );
  });

  it('reports an unusable answer as internal', async () => {
    await assert.rejects(
      assist({ auth: signedIn, data: { task: 'plain', content: 'x' } }, fakeClient({ text: 'no json here' })),
      (e) => e.code === 'internal',
    );
  });
});
