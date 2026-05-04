import { GoogleGenerativeAI } from '@google/generative-ai';
import { EmbeddingProvider, EmbedKind } from './embedding_provider';

const MODEL_NAME = 'gemini-embedding-001';
const DIMENSIONS = 768;

// Gemini's RETRIEVAL_DOCUMENT / RETRIEVAL_QUERY split is required for
// usable retrieval — without it, doc and query vectors collapse into the
// same narrow cone and every distance lands ~0.5 regardless of semantic
// match. See Gemini embeddings docs: "Task types".
function taskTypeFor(kind: EmbedKind): 'RETRIEVAL_DOCUMENT' | 'RETRIEVAL_QUERY' {
  return kind === 'document' ? 'RETRIEVAL_DOCUMENT' : 'RETRIEVAL_QUERY';
}

export class GeminiEmbeddingProvider implements EmbeddingProvider {
  readonly dimensions = DIMENSIONS;
  readonly modelName = MODEL_NAME;

  private readonly client: GoogleGenerativeAI;

  constructor(apiKey: string) {
    this.client = new GoogleGenerativeAI(apiKey);
  }

  async embed(text: string, kind: EmbedKind): Promise<number[]> {
    const model = this.client.getGenerativeModel({ model: MODEL_NAME });
    // gemini-embedding-001 defaults to 3072 dims; we pin 768 to match the
    // Firestore vector index dimension declared at deploy time.
    // `outputDimensionality` and `taskType` are accepted by the Gemini
    // REST API but missing from the legacy `@google/generative-ai` SDK
    // types — the SDK JSON-stringifies the request verbatim, so the cast
    // is safe.
    const result = await model.embedContent({
      content: { role: 'user', parts: [{ text }] },
      outputDimensionality: DIMENSIONS,
      taskType: taskTypeFor(kind),
    } as Parameters<typeof model.embedContent>[0]);
    const values = result.embedding?.values;
    if (!values) {
      throw new Error('Gemini embed returned no values');
    }
    return values;
  }

  async embedBatch(texts: string[], kind: EmbedKind): Promise<number[][]> {
    const model = this.client.getGenerativeModel({ model: MODEL_NAME });
    const taskType = taskTypeFor(kind);
    const result = await model.batchEmbedContents({
      requests: texts.map((t) => ({
        content: { role: 'user', parts: [{ text: t }] },
        outputDimensionality: DIMENSIONS,
        taskType,
      })) as Parameters<typeof model.batchEmbedContents>[0]['requests'],
    });
    return result.embeddings.map((e) => {
      const v = e.values;
      if (!v) throw new Error('Gemini batch embed returned no values for an item');
      return v;
    });
  }
}
