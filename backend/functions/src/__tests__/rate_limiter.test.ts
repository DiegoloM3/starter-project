import { checkRateLimit, _resetRateLimiterForTests, RATE_LIMIT_MAX, RATE_LIMIT_WINDOW_MS } from '../shared/rate_limiter';

describe('rate_limiter', () => {
  beforeEach(() => {
    _resetRateLimiterForTests();
  });

  it('exposes window=10000ms and max=5', () => {
    expect(RATE_LIMIT_WINDOW_MS).toBe(10000);
    expect(RATE_LIMIT_MAX).toBe(5);
  });

  it('allows the first 5 calls in the window', () => {
    for (let i = 0; i < 5; i++) {
      expect(checkRateLimit('uid-1')).toBe(true);
    }
  });

  it('blocks the 6th call within the window', () => {
    for (let i = 0; i < 5; i++) checkRateLimit('uid-1');
    expect(checkRateLimit('uid-1')).toBe(false);
  });

  it('isolates limits per uid', () => {
    for (let i = 0; i < 5; i++) checkRateLimit('uid-1');
    expect(checkRateLimit('uid-1')).toBe(false);
    expect(checkRateLimit('uid-2')).toBe(true);
  });

  it('expires old timestamps after the window passes', () => {
    jest.useFakeTimers();
    const start = Date.now();
    jest.setSystemTime(start);

    for (let i = 0; i < 5; i++) checkRateLimit('uid-1');
    expect(checkRateLimit('uid-1')).toBe(false);

    jest.setSystemTime(start + RATE_LIMIT_WINDOW_MS + 100);
    expect(checkRateLimit('uid-1')).toBe(true);

    jest.useRealTimers();
  });
});
