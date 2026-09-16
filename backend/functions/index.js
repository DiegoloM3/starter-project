// Callable Cloud Function that exposes the editorial assistant to the app.
// The Anthropic key lives in a Firebase secret; the app never sees it.

import Anthropic from '@anthropic-ai/sdk';
import { initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { HttpsError, onCall } from 'firebase-functions/v2/https';
import { defineSecret } from 'firebase-functions/params';
import { AssistantError, assist } from './assist.js';
import { reserveCall } from './usage.js';

const anthropicApiKey = defineSecret('ANTHROPIC_API_KEY');

initializeApp();

export const assistArticle = onCall(
  {
    region: 'us-central1',
    // Anyone may reach the endpoint; the handler refuses callers without a
    // Firebase Auth token and charges every accepted call against that
    // account's daily allowance (see usage.js). App Check is not enforced:
    // it needs the Android app registered with Play Integrity, which the
    // review build does not have. It is the next lock to turn.
    invoker: 'public',
    enforceAppCheck: false,
    secrets: [anthropicApiKey],
    timeoutSeconds: 60,
    memory: '256MiB',
  },
  async (request) => {
    try {
      const uid = request.auth?.uid;
      if (!uid) throw new AssistantError('unauthenticated', 'Sign in to use the editor.');
      await reserveCall(getFirestore(), uid);
      const client = new Anthropic({ apiKey: anthropicApiKey.value() });
      return await assist({ auth: request.auth, data: request.data }, client);
    } catch (error) {
      if (error instanceof AssistantError) throw new HttpsError(error.code, error.message);
      throw new HttpsError('internal', 'The editor hit an unexpected problem.');
    }
  },
);
