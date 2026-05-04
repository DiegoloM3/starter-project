/// Whether the text being embedded is a corpus *document* (we'll later
/// search against it) or a *query* (we use it to search). Most modern
/// embedding APIs are asymmetric: the model produces specialized vectors
/// for each role, and mixing roles collapses the space and breaks
/// retrieval. Provider mapping:
///   Gemini  → taskType: RETRIEVAL_DOCUMENT / RETRIEVAL_QUERY
///   Cohere  → input_type: search_document / search_query
///   Voyage  → input_type: document / query
///   OpenAI  → no distinction (kind is ignored, same vectors either way)
export type EmbedKind = 'document' | 'query';

/// The contract every embedding backend must satisfy. Business logic depends
/// on this interface only — Gemini, OpenAI, Voyage, Anthropic are all
/// swappable behind it. The factory in ./factory.ts is the single source of
/// provider selection.
export interface EmbeddingProvider {
  readonly dimensions: number;
  readonly modelName: string;
  embed(text: string, kind: EmbedKind): Promise<number[]>;
  embedBatch(texts: string[], kind: EmbedKind): Promise<number[][]>;
}
