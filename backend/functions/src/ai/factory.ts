import { EmbeddingProvider } from './embedding_provider';
import { GeminiEmbeddingProvider } from './gemini_embedding_provider';

let _provider: EmbeddingProvider | undefined;

/// Returns the active EmbeddingProvider. Memoized for the function-instance
/// lifetime so the SDK client is reused across invocations.
///
/// Switch providers by changing the body of this function — every Cloud
/// Function consumer goes through here, so the swap is a one-file change.
export function getEmbeddingProvider(): EmbeddingProvider {
  if (_provider) return _provider;
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    throw new Error('GEMINI_API_KEY secret not available in process.env');
  }
  _provider = new GeminiEmbeddingProvider(apiKey);
  return _provider;
}

/// Reset for tests only.
export function _resetEmbeddingProviderForTests(): void {
  _provider = undefined;
}
