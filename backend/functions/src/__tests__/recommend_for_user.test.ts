import { _resetRateLimiterForTests } from '../shared/rate_limiter';

const mockOrderBy = jest.fn();
const mockLimit = jest.fn();
const mockGet = jest.fn();
const mockCollection = jest.fn();

jest.mock('firebase-admin/firestore', () => ({
  getFirestore: jest.fn(() => ({
    collection: (name: string) => {
      mockCollection(name);
      return {
        doc: (uid: string) => ({
          collection: (sub: string) => {
            mockCollection(sub);
            return {
              orderBy: (field: string, dir: string) => {
                mockOrderBy(field, dir);
                return {
                  limit: (n: number) => {
                    mockLimit(n);
                    return { get: mockGet, _uid: uid };
                  },
                };
              },
            };
          },
        }),
      };
    },
  })),
}));

jest.mock('firebase-admin/app', () => ({
  initializeApp: jest.fn(),
  getApps: jest.fn(() => []),
}));

import { handleRecommendRequest, RecommendDeps } from '../recommendation/recommend_for_user';
import { HttpsError } from 'firebase-functions/v2/https';
import { EmbeddingProvider } from '../ai/embedding_provider';
import { NewsApiService, NewsApiArticle } from '../news/news_api_service';

class FakeProvider implements EmbeddingProvider {
  readonly dimensions = 3;
  readonly modelName = 'fake-test';
  embedCalls: { texts: string[]; kind: 'document' | 'query' }[] = [];
  responses: number[][] = [];

  embed(): Promise<number[]> {
    throw new Error('not used');
  }

  embedBatch(texts: string[], kind: 'document' | 'query'): Promise<number[][]> {
    this.embedCalls.push({ texts, kind });
    const vecs = this.responses.splice(0, texts.length);
    if (vecs.length !== texts.length) {
      throw new Error(
        `FakeProvider out of responses: needed ${texts.length}, queued ${vecs.length}`,
      );
    }
    return Promise.resolve(vecs);
  }
}

class FakeNewsApi implements NewsApiService {
  fetchCalls: Array<{ query: string; pageSize: number; apiKey: string }> = [];
  response: NewsApiArticle[] = [];

  fetchEverything(params: {
    query: string;
    pageSize: number;
    apiKey: string;
  }): Promise<NewsApiArticle[]> {
    this.fetchCalls.push(params);
    return Promise.resolve(this.response);
  }
}

function buildRequest({
  auth,
  data,
}: {
  auth?: { uid: string } | null;
  data?: unknown;
}) {
  return { auth: auth ?? null, data };
}

function buildSnapshot(titles: string[]) {
  return {
    empty: titles.length === 0,
    docs: titles.map((t) => ({
      get: (k: string) => (k === 'title' ? t : undefined),
    })),
  };
}

function buildArticle(title: string, url = `https://e.com/${title}`): NewsApiArticle {
  return {
    source: 'src',
    author: 'a',
    title,
    description: 'd',
    url,
    urlToImage: 'https://i.com/i.jpg',
    publishedAt: '2026-05-04T00:00:00Z',
    content: 'c',
  };
}

let provider: FakeProvider;
let newsApi: FakeNewsApi;
let deps: RecommendDeps;

beforeEach(() => {
  jest.clearAllMocks();
  _resetRateLimiterForTests();
  provider = new FakeProvider();
  newsApi = new FakeNewsApi();
  deps = { newsApiKey: 'key-x', provider, newsApi };
});

describe('recommendForUser', () => {
  it('rejects unauthenticated calls', async () => {
    await expect(
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      handleRecommendRequest(buildRequest({ auth: null }) as any, deps),
    ).rejects.toThrow(HttpsError);
  });

  it('returns empty results when the user has no saves', async () => {
    mockGet.mockResolvedValueOnce(buildSnapshot([]));

    const result = await handleRecommendRequest(
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      buildRequest({ auth: { uid: 'u-1' } }) as any,
      deps,
    );

    expect(result.results).toEqual([]);
    expect(provider.embedCalls).toHaveLength(0);
    expect(newsApi.fetchCalls).toHaveLength(0);
  });

  it('embeds saves with RETRIEVAL_QUERY and candidates with RETRIEVAL_DOCUMENT', async () => {
    mockGet.mockResolvedValueOnce(buildSnapshot(['fitness routine']));
    newsApi.response = [buildArticle('home workout tips')];
    provider.responses = [
      [1, 0, 0], // user vector for "fitness routine"
      [1, 0, 0], // candidate "home workout tips"
    ];

    await handleRecommendRequest(
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      buildRequest({ auth: { uid: 'u-1' } }) as any,
      deps,
    );

    expect(provider.embedCalls).toHaveLength(2);
    expect(provider.embedCalls[0].kind).toBe('query');
    expect(provider.embedCalls[0].texts).toEqual(['fitness routine']);
    expect(provider.embedCalls[1].kind).toBe('document');
    expect(provider.embedCalls[1].texts).toEqual(['home workout tips']);
  });

  it('ranks results by ascending cosine distance', async () => {
    mockGet.mockResolvedValueOnce(buildSnapshot(['t1']));
    newsApi.response = [
      buildArticle('far'),
      buildArticle('close'),
      buildArticle('mid'),
    ];
    provider.responses = [
      [1, 0, 0],   // user vector
      [-1, 0, 0],  // far  → distance ~2
      [1, 0, 0],   // close → distance 0
      [0.9, 0.1, 0], // mid  → distance ~0.005
    ];

    const result = await handleRecommendRequest(
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      buildRequest({ auth: { uid: 'u-1' } }) as any,
      deps,
    );

    expect(result.results.map((r) => r.title)).toEqual(['close', 'mid']);
    // 'far' is excluded by the threshold (distance ~2 > 0.35)
  });

  it('drops candidates whose distance exceeds the cutoff', async () => {
    mockGet.mockResolvedValueOnce(buildSnapshot(['t1']));
    newsApi.response = [buildArticle('borderline'), buildArticle('orthogonal')];
    provider.responses = [
      [1, 0, 0],
      [0.5, 0.5, 0], // distance ~0.293 → kept
      [0, 1, 0],     // distance 1 → dropped
    ];

    const result = await handleRecommendRequest(
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      buildRequest({ auth: { uid: 'u-1' } }) as any,
      deps,
    );

    expect(result.results.map((r) => r.title)).toEqual(['borderline']);
  });

  it('skips NewsAPI articles with empty or "[Removed]" titles', async () => {
    mockGet.mockResolvedValueOnce(buildSnapshot(['t1']));
    newsApi.response = [
      buildArticle(''),
      { ...buildArticle('[Removed]'), title: '[Removed]' },
      buildArticle('valid'),
    ];
    provider.responses = [
      [1, 0, 0],
      [1, 0, 0], // only the valid one is embedded
    ];

    const result = await handleRecommendRequest(
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      buildRequest({ auth: { uid: 'u-1' } }) as any,
      deps,
    );

    expect(provider.embedCalls[1].texts).toEqual(['valid']);
    expect(result.results.map((r) => r.title)).toEqual(['valid']);
  });

  it('rejects limit values outside 1-30', async () => {
    await expect(
      handleRecommendRequest(
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        buildRequest({ auth: { uid: 'u-1' }, data: { limit: 0 } }) as any,
        deps,
      ),
    ).rejects.toMatchObject({ code: 'invalid-argument' });

    await expect(
      handleRecommendRequest(
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        buildRequest({ auth: { uid: 'u-1' }, data: { limit: 31 } }) as any,
        deps,
      ),
    ).rejects.toMatchObject({ code: 'invalid-argument' });
  });

  it('rate-limits the 6th request within the window', async () => {
    mockGet.mockResolvedValue(buildSnapshot([]));

    for (let i = 0; i < 5; i++) {
      await handleRecommendRequest(
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        buildRequest({ auth: { uid: 'u-1' } }) as any,
        deps,
      );
    }
    await expect(
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      handleRecommendRequest(buildRequest({ auth: { uid: 'u-1' } }) as any, deps),
    ).rejects.toMatchObject({ code: 'resource-exhausted' });
  });
});
