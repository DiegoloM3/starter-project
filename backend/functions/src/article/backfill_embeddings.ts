import { onCall, CallableRequest, HttpsError } from 'firebase-functions/v2/https';
import {
  getFirestore,
  FieldValue,
  FieldPath,
  DocumentSnapshot,
} from 'firebase-admin/firestore';
import { logger } from 'firebase-functions/v2';
import { getEmbeddingProvider } from '../ai/factory';
import {
  composeArticleText,
  embeddingSourceHash,
  truncateForEmbed,
} from '../shared/article_text';
import { GEMINI_API_KEY } from '../shared/secrets';

interface BackfillResponse {
  processed: number;
  skipped: number;
  errors: number;
}

const BATCH_SIZE = 50;

function isAdminCaller(request: CallableRequest): boolean {
  if (request.auth?.token.admin === true) return true;
  const allowlist = (process.env.BACKFILL_ALLOWLIST_UIDS ?? '')
    .split(',')
    .map((s) => s.trim())
    .filter((s) => s.length > 0);
  return allowlist.includes(request.auth?.uid ?? '');
}

export async function handleBackfillRequest(
  request: CallableRequest,
): Promise<BackfillResponse> {
  if (!isAdminCaller(request)) {
    throw new HttpsError(
      'permission-denied',
      'backfillEmbeddings requires an admin custom claim or an allowlisted uid.',
    );
  }

  const provider = getEmbeddingProvider();
  const articles = getFirestore().collection('articles');

  let processed = 0;
  let skipped = 0;
  let errors = 0;
  let cursor: DocumentSnapshot | undefined;
  let hasMore = true;

  // Paginated cursor loop — survives the 9-minute function timeout for
  // thousands of articles. Each batch is 50 docs ordered by document ID.
  while (hasMore) {
    const baseQuery = articles
      .where('status', '==', 'published')
      .where('isDeleted', '==', false)
      .orderBy(FieldPath.documentId())
      .limit(BATCH_SIZE);

    const snap = await (cursor ? baseQuery.startAfter(cursor).get() : baseQuery.get());
    if (snap.empty) break;

    for (const doc of snap.docs) {
      const data = doc.data();
      const composed = composeArticleText({
        title: data.title,
        description: data.description,
        content: data.content,
      });
      const computedHash = embeddingSourceHash(composed, provider.modelName);

      if (data.embeddingSourceHash === computedHash) {
        skipped++;
        continue;
      }

      try {
        const vector = await provider.embed(truncateForEmbed(composed), 'document');
        await doc.ref.set(
          {
            embedding: FieldValue.vector(vector),
            embeddingSourceHash: computedHash,
            embeddingProvider: provider.modelName,
            embeddingDimensions: provider.dimensions,
          },
          { merge: true },
        );
        processed++;
      } catch (err) {
        errors++;
        logger.error('backfill embed failed', {
          articleId: doc.id,
          error: err instanceof Error ? err.message : String(err),
        });
      }
    }

    cursor = snap.docs[snap.docs.length - 1];
    if (snap.size < BATCH_SIZE) hasMore = false;
  }

  logger.info('backfill complete', { processed, skipped, errors });
  return { processed, skipped, errors };
}

export const backfillEmbeddings = onCall(
  {
    region: 'us-central1',
    secrets: [GEMINI_API_KEY],
    timeoutSeconds: 540,
  },
  handleBackfillRequest,
);
