// Cosine distance ∈ [0, 2] where 0 = identical, 1 = orthogonal, 2 = opposite.
// Same convention used by Firestore's findNearest with COSINE measure, so
// the threshold tuned for searchArticles transfers cleanly to in-memory
// ranking here.
export function cosineDistance(a: number[], b: number[]): number {
  if (a.length !== b.length) {
    throw new Error(`vector length mismatch: ${a.length} vs ${b.length}`);
  }
  let dot = 0;
  let magA = 0;
  let magB = 0;
  for (let i = 0; i < a.length; i++) {
    dot += a[i] * b[i];
    magA += a[i] * a[i];
    magB += b[i] * b[i];
  }
  const denom = Math.sqrt(magA) * Math.sqrt(magB);
  if (denom === 0) return 1;
  const sim = dot / denom;
  return 1 - sim;
}

export function averageVectors(vectors: number[][]): number[] {
  if (vectors.length === 0) {
    throw new Error('cannot average zero vectors');
  }
  const dim = vectors[0].length;
  const out = new Array<number>(dim).fill(0);
  for (const v of vectors) {
    if (v.length !== dim) {
      throw new Error(`vector length mismatch: expected ${dim}, got ${v.length}`);
    }
    for (let i = 0; i < dim; i++) out[i] += v[i];
  }
  for (let i = 0; i < dim; i++) out[i] /= vectors.length;
  return out;
}
