import { cosineDistance, averageVectors } from '../shared/vector_math';

describe('cosineDistance', () => {
  it('returns 0 for identical vectors', () => {
    expect(cosineDistance([1, 2, 3], [1, 2, 3])).toBeCloseTo(0, 6);
  });

  it('returns 1 for orthogonal vectors', () => {
    expect(cosineDistance([1, 0], [0, 1])).toBeCloseTo(1, 6);
  });

  it('returns 2 for opposite vectors', () => {
    expect(cosineDistance([1, 1], [-1, -1])).toBeCloseTo(2, 6);
  });

  it('returns 1 when either vector is zero (degenerate)', () => {
    expect(cosineDistance([0, 0, 0], [1, 2, 3])).toBe(1);
  });

  it('throws on dimension mismatch', () => {
    expect(() => cosineDistance([1, 2], [1, 2, 3])).toThrow(/length mismatch/);
  });
});

describe('averageVectors', () => {
  it('returns the centroid of N vectors', () => {
    expect(averageVectors([[1, 0, 0], [0, 1, 0], [0, 0, 1]])).toEqual([
      1 / 3,
      1 / 3,
      1 / 3,
    ]);
  });

  it('returns the original vector when given just one', () => {
    expect(averageVectors([[2, 4, 6]])).toEqual([2, 4, 6]);
  });

  it('throws on empty input', () => {
    expect(() => averageVectors([])).toThrow(/zero vectors/);
  });

  it('throws on dimension mismatch', () => {
    expect(() => averageVectors([[1, 2], [1, 2, 3]])).toThrow(/length mismatch/);
  });
});
