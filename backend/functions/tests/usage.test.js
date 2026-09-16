import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { AssistantError } from '../assist.js';
import { COLLECTION, DAILY_LIMIT, dayKey, reserveCall } from '../usage.js';

/** A Firestore stand-in holding one counter document. */
function fakeDb(initial = null) {
  let stored = initial;
  const paths = [];
  return {
    get stored() {
      return stored;
    },
    paths,
    collection(name) {
      return {
        doc(id) {
          paths.push(`${name}/${id}`);
          return { id };
        },
      };
    },
    async runTransaction(run) {
      return run({
        async get() {
          return { exists: stored !== null, data: () => stored };
        },
        set(_ref, data) {
          stored = data;
        },
      });
    },
  };
}

const noon = new Date('2026-09-16T12:00:00Z');

describe('reserveCall', () => {
  it('starts a fresh counter for an account with no usage', async () => {
    const db = fakeDb();

    const left = await reserveCall(db, 'journalist-1', { now: noon });

    assert.equal(left, DAILY_LIMIT - 1);
    assert.deepEqual(db.stored, { day: '2026-09-16', count: 1, updatedAt: noon });
    assert.deepEqual(db.paths, [`${COLLECTION}/journalist-1`]);
  });

  it('counts calls within the same day and resets on the next', async () => {
    const db = fakeDb({ day: '2026-09-16', count: 3, updatedAt: noon });

    await reserveCall(db, 'journalist-1', { now: noon });
    assert.equal(db.stored.count, 4);

    const tomorrow = new Date('2026-09-17T00:30:00Z');
    const left = await reserveCall(db, 'journalist-1', { now: tomorrow });
    assert.equal(db.stored.count, 1);
    assert.equal(db.stored.day, dayKey(tomorrow));
    assert.equal(left, DAILY_LIMIT - 1);
  });

  it('refuses the call once the allowance is spent and leaves the counter alone', async () => {
    const db = fakeDb({ day: '2026-09-16', count: 2, updatedAt: noon });

    await assert.rejects(
      reserveCall(db, 'journalist-1', { now: noon, limit: 2 }),
      (error) => error instanceof AssistantError && error.code === 'resource-exhausted',
    );
    assert.equal(db.stored.count, 2);
  });
});
