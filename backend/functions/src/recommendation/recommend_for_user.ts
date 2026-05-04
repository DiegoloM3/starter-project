import { onCall, CallableRequest, HttpsError } from 'firebase-functions/v2/https';
import { getFirestore } from 'firebase-admin/firestore';
import { logger } from 'firebase-functions/v2';
import { getEmbeddingProvider } from '../ai/factory';
import { EmbeddingProvider } from '../ai/embedding_provider';
import { NewsApiService, NewsApiServiceImpl, NewsApiArticle } from '../news/news_api_service';
import { checkRateLimit } from '../shared/rate_limiter';
import { GEMINI_API_KEY, NEWS_API_KEY } from '../shared/secrets';
import { averageVectors, cosineDistance } from '../shared/vector_math';

interface RecommendRequestData {
  limit?: unknown;
}

interface Recommendation {
  url: string;
  title: string;
  description: string;
  urlToImage: string;
  publishedAt: string;
  author: string;
  content: string;
  source: string;
  distance: number;
}

interface RecommendResponse {
  results: Recommendation[];
}

const DEFAULT_LIMIT = 20;
const MAX_LIMIT = 30;
const SAVES_SAMPLE_SIZE = 10;
const NEWS_POOL_SIZE = 30;

// Same threshold as searchArticles — calibrated against gemini-embedding-001
// at 768 dims with proper RETRIEVAL_DOCUMENT/RETRIEVAL_QUERY taskType.
const MAX_RELEVANT_DISTANCE = 0.35;

const NEWS_POOL_QUERY =
  'news OR breaking OR world OR business OR fitness OR health OR wellness OR nutrition';

export interface RecommendDeps {
  newsApiKey: string;
  provider: EmbeddingProvider;
  newsApi: NewsApiService;
}

export async function handleRecommendRequest(
  request: CallableRequest<RecommendRequestData>,
  deps: RecommendDeps,
): Promise<RecommendResponse> {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in for personalized recommendations.');
  }
  const uid = request.auth.uid;
  if (!checkRateLimit(uid)) {
    throw new HttpsError('resource-exhausted', 'Too many requests. Try again in a moment.');
  }

  const limit = parseLimit(request.data);

  const savedSnap = await getFirestore()
    .collection('users')
    .doc(uid)
    .collection('savedArticles')
    .orderBy('savedAt', 'desc')
    .limit(SAVES_SAMPLE_SIZE)
    .get();

  if (savedSnap.empty) {
    logger.info('recommend: no saves', { uid });
    return { results: [] };
  }

  const savedTitles = savedSnap.docs
    .map((d) => (d.get('title') as string | undefined) ?? '')
    .filter((t) => t.length > 0);

  if (savedTitles.length === 0) {
    return { results: [] };
  }

  const tasteVectors = await deps.provider.embedBatch(savedTitles, 'query');
  const userVector = averageVectors(tasteVectors);

  const candidates = await deps.newsApi.fetchEverything({
    query: NEWS_POOL_QUERY,
    pageSize: NEWS_POOL_SIZE,
    apiKey: deps.newsApiKey,
  });
  const usable = candidates.filter((c) => c.title && c.title !== '[Removed]');
  if (usable.length === 0) {
    return { results: [] };
  }

  const candidateVectors = await deps.provider.embedBatch(
    usable.map((c) => c.title),
    'document',
  );

  const ranked = usable
    .map((article, i) => ({
      article,
      distance: cosineDistance(userVector, candidateVectors[i]),
    }))
    .filter((r) => r.distance <= MAX_RELEVANT_DISTANCE)
    .sort((a, b) => a.distance - b.distance)
    .slice(0, limit);

  logger.info('recommend completed', {
    uid,
    savesUsed: savedTitles.length,
    candidatePoolSize: usable.length,
    resultCount: ranked.length,
    topDistance: ranked[0]?.distance,
    cutoff: MAX_RELEVANT_DISTANCE,
    provider: deps.provider.modelName,
  });

  return { results: ranked.map((r) => toRecommendation(r.article, r.distance)) };
}

function parseLimit(data: RecommendRequestData): number {
  const raw = data?.limit;
  if (raw === undefined || raw === null) return DEFAULT_LIMIT;
  if (typeof raw !== 'number' || !Number.isInteger(raw)) {
    throw new HttpsError('invalid-argument', 'limit must be an integer');
  }
  if (raw < 1 || raw > MAX_LIMIT) {
    throw new HttpsError('invalid-argument', `limit must be 1-${MAX_LIMIT}`);
  }
  return raw;
}

function toRecommendation(a: NewsApiArticle, distance: number): Recommendation {
  return {
    url: a.url,
    title: a.title,
    description: a.description,
    urlToImage: a.urlToImage,
    publishedAt: a.publishedAt,
    author: a.author,
    content: a.content,
    source: a.source,
    distance,
  };
}

export const recommendForUser = onCall(
  {
    region: 'us-central1',
    secrets: [GEMINI_API_KEY, NEWS_API_KEY],
    timeoutSeconds: 30,
  },
  (request) =>
    handleRecommendRequest(request, {
      newsApiKey: NEWS_API_KEY.value(),
      provider: getEmbeddingProvider(),
      newsApi: new NewsApiServiceImpl(),
    }),
);
