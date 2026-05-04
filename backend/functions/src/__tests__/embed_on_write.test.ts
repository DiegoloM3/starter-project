const mockSet = jest.fn();
const mockRef = { set: mockSet };

jest.mock('firebase-admin/firestore', () => {
  const originalModule = jest.requireActual('firebase-admin/firestore');
  return {
    ...originalModule,
    FieldValue: {
      vector: jest.fn((arr: number[]) => ({ _vectorMarker: true, values: arr })),
    },
    getFirestore: jest.fn(),
  };
});

jest.mock('firebase-admin/app', () => ({
  initializeApp: jest.fn(),
  getApps: jest.fn(() => []),
}));

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

import { handleArticleWrite } from '../article/embed_on_write';
import {
  ARTICLE_TEXT_FIELD_SEPARATOR,
  composeArticleText,
  embeddingSourceHash,
} from '../shared/article_text';

describe('embedArticleOnWrite', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockSet.mockReset();
    mockEmbed.mockReset();
  });

  function buildEvent(afterData: Record<string, unknown> | undefined) {
    return {
      data: afterData
        ? {
            after: {
              data: () => afterData,
              ref: mockRef,
              exists: true,
            },
          }
        : { after: undefined },
    };
  }

  it('skips when status is not published', async () => {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    await handleArticleWrite(buildEvent({ status: 'publishing', isDeleted: false, title: 'A', description: 'B', content: 'C' }) as any);
    expect(mockEmbed).not.toHaveBeenCalled();
    expect(mockSet).not.toHaveBeenCalled();
  });

  it('skips when isDeleted is true', async () => {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    await handleArticleWrite(buildEvent({ status: 'published', isDeleted: true, title: 'A', description: 'B', content: 'C' }) as any);
    expect(mockEmbed).not.toHaveBeenCalled();
    expect(mockSet).not.toHaveBeenCalled();
  });

  it('skips when after data is undefined (real delete)', async () => {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    await handleArticleWrite(buildEvent(undefined) as any);
    expect(mockEmbed).not.toHaveBeenCalled();
    expect(mockSet).not.toHaveBeenCalled();
  });

  it('skips when embeddingSourceHash matches the computed hash', async () => {
    const composed = composeArticleText({ title: 'Sample', description: 'Description', content: 'Body' });
    const knownHash = embeddingSourceHash(composed, 'gemini-embedding-001');

    await handleArticleWrite(
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      buildEvent({ status: 'published', isDeleted: false, title: 'Sample', description: 'Description', content: 'Body', embeddingSourceHash: knownHash }) as any,
    );
    expect(mockEmbed).not.toHaveBeenCalled();
    expect(mockSet).not.toHaveBeenCalled();
  });

  it('re-embeds when stored hash was computed for a different model (provider swap path)', async () => {
    const composed = composeArticleText({ title: 'Sample', description: 'Description', content: 'Body' });
    const oldModelHash = embeddingSourceHash(composed, 'text-embedding-004');
    const fakeVector = new Array(768).fill(0.4);
    mockEmbed.mockResolvedValue(fakeVector);

    await handleArticleWrite(
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      buildEvent({ status: 'published', isDeleted: false, title: 'Sample', description: 'Description', content: 'Body', embeddingSourceHash: oldModelHash }) as any,
    );

    expect(mockEmbed).toHaveBeenCalledTimes(1);
    expect(mockSet).toHaveBeenCalledTimes(1);
    const newHash = mockSet.mock.calls[0][0].embeddingSourceHash as string;
    expect(newHash).toBe(embeddingSourceHash(composed, 'gemini-embedding-001'));
  });

  it('embeds and writes the 4 fields when status=published and hash differs', async () => {
    const fakeVector = new Array(768).fill(0.1);
    mockEmbed.mockResolvedValue(fakeVector);

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    await handleArticleWrite(buildEvent({ status: 'published', isDeleted: false, title: 'Sample', description: 'Description', content: 'Body' }) as any);

    expect(mockEmbed).toHaveBeenCalledTimes(1);
    const expectedText = `Sample${ARTICLE_TEXT_FIELD_SEPARATOR}Description${ARTICLE_TEXT_FIELD_SEPARATOR}Body`;
    expect(mockEmbed).toHaveBeenCalledWith(expectedText, 'document');

    expect(mockSet).toHaveBeenCalledTimes(1);
    const [payload, options] = mockSet.mock.calls[0];
    expect(payload.embedding).toEqual({ _vectorMarker: true, values: fakeVector });
    expect(payload.embeddingSourceHash).toMatch(/^[a-f0-9]{64}$/);
    expect(payload.embeddingProvider).toBe('gemini-embedding-001');
    expect(payload.embeddingDimensions).toBe(768);
    expect(options).toEqual({ merge: true });
  });

  it('truncates the embed input to 8000 chars but hashes the full text', async () => {
    const fakeVector = new Array(768).fill(0.2);
    mockEmbed.mockResolvedValue(fakeVector);

    const longContent = 'X'.repeat(20000);
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    await handleArticleWrite(buildEvent({ status: 'published', isDeleted: false, title: 'T', description: 'D', content: longContent }) as any);

    const [embedArg, embedKind] = mockEmbed.mock.calls[0] as [string, string];
    expect(embedArg.length).toBe(8000);
    expect(embedKind).toBe('document');

    const writtenHash = mockSet.mock.calls[0][0].embeddingSourceHash as string;
    const fullComposed = `T${ARTICLE_TEXT_FIELD_SEPARATOR}D${ARTICLE_TEXT_FIELD_SEPARATOR}` + longContent;
    expect(writtenHash).toBe(embeddingSourceHash(fullComposed, 'gemini-embedding-001'));
  });

  it('handles missing description/content gracefully (treat as empty)', async () => {
    const fakeVector = new Array(768).fill(0.3);
    mockEmbed.mockResolvedValue(fakeVector);

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    await handleArticleWrite(buildEvent({ status: 'published', isDeleted: false, title: 'OnlyTitle' }) as any);

    const expectedText = `OnlyTitle${ARTICLE_TEXT_FIELD_SEPARATOR}${ARTICLE_TEXT_FIELD_SEPARATOR}`;
    expect(mockEmbed).toHaveBeenCalledWith(expectedText, 'document');
    expect(mockSet).toHaveBeenCalledTimes(1);
  });
});
