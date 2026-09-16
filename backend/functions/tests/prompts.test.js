import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { buildPrompt, parseAnswer } from '../prompts.js';

describe('buildPrompt', () => {
  it('puts the article and the task instructions in the user prompt', () => {
    const { system, user } = buildPrompt({ task: 'suggest', title: 'Sea wall', content: 'Body text.' });
    assert.match(system, /JSON only/);
    assert.match(user, /Title: Sea wall/);
    assert.match(user, /three alternative headlines/);
  });

  it('omits the title line when the draft has none', () => {
    const { user } = buildPrompt({ task: 'plain', title: '', content: 'Body' });
    assert.match(user, /90 years old/);
    assert.doesNotMatch(user, /Title:/);
  });
});

describe('parseAnswer', () => {
  it('reads plain JSON and JSON inside code fences', () => {
    const plain = parseAnswer('brief', '{"bullets": ["a", "b", "c"]}');
    const fenced = parseAnswer('brief', 'Sure!\n```json\n{"bullets": ["a", "b", "c", "d"]}\n```');
    assert.deepEqual(plain, { bullets: ['a', 'b', 'c'] });
    assert.deepEqual(fenced, { bullets: ['a', 'b', 'c'] });
  });

  it('normalises suggestions: keeps three headlines and caps lengths', () => {
    const answer = parseAnswer('suggest', JSON.stringify({
      headlines: ['One', 'x'.repeat(200), 3, 'Four'],
      summary: 's'.repeat(400),
    }));
    assert.equal(answer.headlines.length, 3);
    assert.equal(answer.headlines[1].length, 150);
    assert.equal(answer.summary.length, 300);
    assert.equal('category' in answer, false);
  });

  it('rejects answers without JSON or without the expected field', () => {
    assert.throws(() => parseAnswer('brief', 'I cannot help with that.'));
    assert.throws(() => parseAnswer('plain', '{"bullets": ["not text"]}'));
    assert.throws(() => parseAnswer('suggest', '{"summary": "no headlines"}'));
  });
});
