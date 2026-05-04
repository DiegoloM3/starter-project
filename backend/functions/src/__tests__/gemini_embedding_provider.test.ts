import { GeminiEmbeddingProvider } from '../ai/gemini_embedding_provider';

const mockEmbedContent = jest.fn();
const mockBatchEmbedContents = jest.fn();
const mockGetGenerativeModel = jest.fn(() => ({
  embedContent: mockEmbedContent,
  batchEmbedContents: mockBatchEmbedContents,
}));

jest.mock('@google/generative-ai', () => ({
  GoogleGenerativeAI: jest.fn(() => ({
    getGenerativeModel: mockGetGenerativeModel,
  })),
}));

describe('GeminiEmbeddingProvider', () => {
  let provider: GeminiEmbeddingProvider;

  beforeEach(() => {
    jest.clearAllMocks();
    provider = new GeminiEmbeddingProvider('test-api-key');
  });

  it('exposes dimensions = 768', () => {
    expect(provider.dimensions).toBe(768);
  });

  it('exposes modelName = gemini-embedding-001', () => {
    expect(provider.modelName).toBe('gemini-embedding-001');
  });

  it('embed() returns the SDK embedding values and pins outputDimensionality', async () => {
    const fakeVector = new Array(768).fill(0.1);
    mockEmbedContent.mockResolvedValue({
      embedding: { values: fakeVector },
    });

    const result = await provider.embed('hello world', 'document');

    expect(result).toHaveLength(768);
    expect(result).toEqual(fakeVector);
    expect(mockGetGenerativeModel).toHaveBeenCalledWith({
      model: 'gemini-embedding-001',
    });
    expect(mockEmbedContent).toHaveBeenCalledWith({
      content: { role: 'user', parts: [{ text: 'hello world' }] },
      outputDimensionality: 768,
      taskType: 'RETRIEVAL_DOCUMENT',
    });
  });

  it('embed() forwards RETRIEVAL_QUERY for queries', async () => {
    mockEmbedContent.mockResolvedValue({ embedding: { values: new Array(768).fill(0.5) } });

    await provider.embed('hello', 'query');

    expect(mockEmbedContent).toHaveBeenCalledWith({
      content: { role: 'user', parts: [{ text: 'hello' }] },
      outputDimensionality: 768,
      taskType: 'RETRIEVAL_QUERY',
    });
  });

  it('embedBatch() returns vectors in the same order as input', async () => {
    const v1 = new Array(768).fill(0.1);
    const v2 = new Array(768).fill(0.2);
    mockBatchEmbedContents.mockResolvedValue({
      embeddings: [{ values: v1 }, { values: v2 }],
    });

    const result = await provider.embedBatch(['first', 'second'], 'document');

    expect(result).toHaveLength(2);
    expect(result[0]).toEqual(v1);
    expect(result[1]).toEqual(v2);
    expect(mockBatchEmbedContents).toHaveBeenCalledWith({
      requests: [
        {
          content: { role: 'user', parts: [{ text: 'first' }] },
          outputDimensionality: 768,
          taskType: 'RETRIEVAL_DOCUMENT',
        },
        {
          content: { role: 'user', parts: [{ text: 'second' }] },
          outputDimensionality: 768,
          taskType: 'RETRIEVAL_DOCUMENT',
        },
      ],
    });
  });

  it('embed() throws if SDK returns malformed response', async () => {
    mockEmbedContent.mockResolvedValue({ embedding: undefined });

    await expect(provider.embed('hello', 'document')).rejects.toThrow();
  });
});
