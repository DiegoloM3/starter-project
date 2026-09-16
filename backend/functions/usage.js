// Daily allowance of assistant calls per account. Every call costs money on
// the Anthropic side, and the endpoint is reachable by anyone who can sign
// up, so each uid gets a fixed number of requests per calendar day (UTC).
// The counters live in Firestore under `assistantUsage/{uid}`, a collection
// the security rules never expose to clients.

import { AssistantError } from './assist.js';

export const COLLECTION = 'assistantUsage';
export const DAILY_LIMIT = 40;

/** The UTC calendar day of `now`, e.g. "2026-09-16". */
export function dayKey(now) {
  return now.toISOString().slice(0, 10);
}

/**
 * Reserves one call for `uid` on the day of `now`, or throws
 * `resource-exhausted` when the allowance is spent. Runs in a transaction so
 * concurrent calls cannot slip past the limit together.
 *
 * @param {{ collection: Function, runTransaction: Function }} db a Firestore instance
 * @returns {Promise<number>} calls left today after this one
 */
export async function reserveCall(db, uid, { now = new Date(), limit = DAILY_LIMIT } = {}) {
  const ref = db.collection(COLLECTION).doc(uid);
  const day = dayKey(now);
  return db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(ref);
    const stored = snapshot.exists ? snapshot.data() : null;
    const used = stored?.day === day ? stored.count : 0;
    if (used >= limit) {
      throw new AssistantError(
        'resource-exhausted',
        `You have used today's ${limit} editor requests. Try again tomorrow.`,
      );
    }
    transaction.set(ref, { day, count: used + 1, updatedAt: now });
    return limit - used - 1;
  });
}
