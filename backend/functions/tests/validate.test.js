import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { CONTENT_MAX, TITLE_MAX, ValidationError, validateRequest } from '../validate.js';

describe('validateRequest', () => {
  it('trims and returns a clean request', () => {
    const clean = validateRequest({ task: 'brief', title: '  Sea wall ', content: ' Body ' });
    assert.deepEqual(clean, { task: 'brief', title: 'Sea wall', content: 'Body' });
  });

  it('rejects unknown tasks, empty content and oversized fields', () => {
    assert.throws(() => validateRequest({ task: 'poem', content: 'x' }), ValidationError);
    assert.throws(() => validateRequest({ task: 'brief', content: '   ' }), ValidationError);
    assert.throws(
      () => validateRequest({ task: 'brief', title: 'x'.repeat(TITLE_MAX + 1), content: 'x' }),
      ValidationError,
    );
    assert.throws(
      () => validateRequest({ task: 'brief', content: 'x'.repeat(CONTENT_MAX + 1) }),
      ValidationError,
    );
    assert.throws(() => validateRequest(null), ValidationError);
  });
});
