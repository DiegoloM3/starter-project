import { _resetRateLimiterForTests } from '../shared/rate_limiter';

const mockEmbed = jest.fn();
const mockProvider = {
  dimensions: 768,
  modelName: 'gemini-embedding-001',
  embed: mockEmbed,
  embedBatch: jest.fn(),
};

jest.mock('../ai/factory', () => ({
  getEmbeddingProvider: () => mockProvider,
  _resetEmbeddingProviderForTests: jest.fn(),
}));

const mockGet = jest.fn();
const mockFindNearest = jest.fn(() => ({ get: mockGet }));
const mockWhere2 = jest.fn(() => ({ findNearest: mockFindNearest }));
const mockWhere1 = jest.fn(() => ({ where: mockWhere2 }));
const mockCollection = jest.fn(() => ({ where: mockWhere1 }));

jest.mock('firebase-admin/firestore', () => {
  const actual = jest.requireActual('firebase-admin/firestore');
  return {
    ...actual,
    FieldValue: {
      vector: jest.fn((arr: number[]) => ({ _vectorMarker: true, values: arr })),
    },
    getFirestore: jest.fn(() => ({ collection: mockCollection })),
  };
});

jest.mock('firebase-admin/app', () => ({
  initializeApp: jest.fn(),
  getApps: jest.fn(() => []),
}));

import { handleSearchRequest } from '../article/search_articles';
import { HttpsError } from 'firebase-functions/v2/https';

describe('searchArticles callable', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    _resetRateLimiterForTests();
    mockEmbed.mockReset();
    mockGet.mockReset();
  });

  function buildRequest({
    auth,
    data,
  }: {
    auth?: { uid: string } | null;
    data?: unknown;
  }) {
    return { auth: auth ?? null, data };
  }

  it('rejects unauthenticated calls', async () => {
    await expect(
      handleSearchRequest(buildRequest({ auth: null, data: { query: 'hi', limit: 5 } }) as any),
    ).rejects.toThrow(HttpsError);
  });

  it('rejects empty query string', async () => {
    await expect(
      handleSearchRequest(buildRequest({ auth: { uid: 'u1' }, data: { query: '', limit: 5 } }) as any),
    ).rejects.toMatchObject({ code: 'invalid-argument' });
  });

  it('rejects query longer than 200 chars', async () => {
    await expect(
      handleSearchRequest(buildRequest({ auth: { uid: 'u1' }, data: { query: 'A'.repeat(201), limit: 5 } }) as any),
    ).rejects.toMatchObject({ code: 'invalid-argument' });
  });

  it('rejects limit below 1', async () => {
    await expect(
      handleSearchRequest(buildRequest({ auth: { uid: 'u1' }, data: { query: 'ok', limit: 0 } }) as any),
    ).rejects.toMatchObject({ code: 'invalid-argument' });
  });

  it('rejects limit above 50', async () => {
    await expect(
      handleSearchRequest(buildRequest({ auth: { uid: 'u1' }, data: { query: 'ok', limit: 51 } }) as any),
    ).rejects.toMatchObject({ code: 'invalid-argument' });
  });

  it('rate-limits 6th request within window', async () => {
    mockEmbed.mockResolvedValue(new Array(768).fill(0.1));
    mockGet.mockResolvedValue({ docs: [] });

    for (let i = 0; i < 5; i++) {
      await handleSearchRequest(buildRequest({ auth: { uid: 'u1' }, data: { query: 'ok' } }) as any);
    }
    await expect(
      handleSearchRequest(buildRequest({ auth: { uid: 'u1' }, data: { query: 'ok' } }) as any),
    ).rejects.toMatchObject({ code: 'resource-exhausted' });
  });

  it('happy path: embeds query, calls findNearest with right args, returns mapped results', async () => {
    const queryVector = new Array(768).fill(0.42);
    mockEmbed.mockResolvedValue(queryVector);
    mockGet.mockResolvedValue({
      docs: [
        { id: 'art-1', get: (path: string) => (path === '_distance' ? 0.12 : null) },
        { id: 'art-2', get: (path: string) => (path === '_distance' ? 0.34 : null) },
      ],
    });

    const result = await handleSearchRequest(
      buildRequest({ auth: { uid: 'u1' }, data: { query: 'marathon training' } }) as any,
    );

    expect(mockEmbed).toHaveBeenCalledWith('marathon training', 'query');
    expect(mockCollection).toHaveBeenCalledWith('articles');
    expect(mockWhere1).toHaveBeenCalledWith('status', '==', 'published');
    expect(mockWhere2).toHaveBeenCalledWith('isDeleted', '==', false);

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const findNearestArgs = (mockFindNearest.mock.calls as any[][])[0][0];
    expect(findNearestArgs).toMatchObject({
      vectorField: 'embedding',
      limit: 10,
      distanceMeasure: 'COSINE',
      distanceResultField: '_distance',
    });

    expect(result).toEqual({
      results: [
        { articleId: 'art-1', distance: 0.12 },
        { articleId: 'art-2', distance: 0.34 },
      ],
    });
  });

  it('drops candidates whose cosine distance exceeds the relevance cutoff', async () => {
    mockEmbed.mockResolvedValue(new Array(768).fill(0.5));
    mockGet.mockResolvedValue({
      docs: [
        { id: 'direct', get: (path: string) => (path === '_distance' ? 0.27 : null) },
        { id: 'related', get: (path: string) => (path === '_distance' ? 0.33 : null) },
        { id: 'borderline', get: (path: string) => (path === '_distance' ? 0.42 : null) },
        { id: 'unrelated', get: (path: string) => (path === '_distance' ? 0.55 : null) },
      ],
    });

    const result = await handleSearchRequest(
      buildRequest({ auth: { uid: 'u1' }, data: { query: 'unrelated' } }) as any,
    );

    expect(result.results.map((r) => r.articleId)).toEqual(['direct', 'related']);
  });

  it('uses default limit of 10 when not provided', async () => {
    mockEmbed.mockResolvedValue(new Array(768).fill(0.1));
    mockGet.mockResolvedValue({ docs: [] });

    await handleSearchRequest(buildRequest({ auth: { uid: 'u1' }, data: { query: 'ok' } }) as any);

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    expect((mockFindNearest.mock.calls as any[][])[0][0].limit).toBe(10);
  });

  it('respects custom limit when provided', async () => {
    mockEmbed.mockResolvedValue(new Array(768).fill(0.1));
    mockGet.mockResolvedValue({ docs: [] });

    await handleSearchRequest(
      buildRequest({ auth: { uid: 'u1' }, data: { query: 'ok', limit: 25 } }) as any,
    );

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    expect((mockFindNearest.mock.calls as any[][])[0][0].limit).toBe(25);
  });
});
