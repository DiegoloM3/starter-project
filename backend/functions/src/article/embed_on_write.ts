import { onDocumentWritten, FirestoreEvent, Change } from 'firebase-functions/v2/firestore';
import { FieldValue, DocumentSnapshot } from 'firebase-admin/firestore';
import { logger } from 'firebase-functions/v2';
import { getEmbeddingProvider } from '../ai/factory';
import {
  composeArticleText,
  EMBED_TEXT_MAX_CHARS,
  embeddingSourceHash,
  truncateForEmbed,
} from '../shared/article_text';
import { GEMINI_API_KEY } from '../shared/secrets';

interface ArticleData {
  status?: string;
  isDeleted?: boolean;
  title?: string;
  description?: string;
  content?: string;
  embeddingSourceHash?: string;
}

type ArticleWriteEvent = FirestoreEvent<
  Change<DocumentSnapshot> | undefined,
  { articleId: string }
>;

export async function handleArticleWrite(event: ArticleWriteEvent): Promise<void> {
  const after = event.data?.after?.data() as ArticleData | undefined;
  if (!after) return;
  if (after.status !== 'published' || after.isDeleted === true) return;

  const composed = composeArticleText({
    title: after.title,
    description: after.description,
    content: after.content,
  });

  const provider = getEmbeddingProvider();
  const computedHash = embeddingSourceHash(composed, provider.modelName);

  if (after.embeddingSourceHash === computedHash) return;

  const vector = await provider.embed(truncateForEmbed(composed), 'document');

  await event.data!.after.ref.set(
    {
      embedding: FieldValue.vector(vector),
      embeddingSourceHash: computedHash,
      embeddingProvider: provider.modelName,
      embeddingDimensions: provider.dimensions,
    },
    { merge: true },
  );

  logger.info('article embedded', {
    articleId: event.data!.after.id,
    composedLength: composed.length,
    truncated: composed.length > EMBED_TEXT_MAX_CHARS,
    provider: provider.modelName,
  });
}

export const embedArticleOnWrite = onDocumentWritten(
  {
    document: 'articles/{articleId}',
    region: 'us-central1',
    secrets: [GEMINI_API_KEY],
  },
  handleArticleWrite,
);
