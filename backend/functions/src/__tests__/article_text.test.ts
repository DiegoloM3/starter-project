import {
  composeArticleText,
  sha256,
  truncateForEmbed,
  ARTICLE_TEXT_FIELD_SEPARATOR,
  EMBED_TEXT_MAX_CHARS,
} from '../shared/article_text';

describe('article_text', () => {
  describe('composeArticleText', () => {
    it('joins title, description and content with the field separator', () => {
      const result = composeArticleText({
        title: 'A',
        description: 'B',
        content: 'C',
      });
      expect(result).toBe(`A${ARTICLE_TEXT_FIELD_SEPARATOR}B${ARTICLE_TEXT_FIELD_SEPARATOR}C`);
    });

    it('treats missing fields as empty strings', () => {
      const result = composeArticleText({ title: 'A' } as { title: string; description?: string; content?: string });
      expect(result).toBe(`A${ARTICLE_TEXT_FIELD_SEPARATOR}${ARTICLE_TEXT_FIELD_SEPARATOR}`);
    });

    it('field separator is the Unicode Start-of-Header', () => {
      expect(ARTICLE_TEXT_FIELD_SEPARATOR).toBe('\x01');
    });

    it('two articles that would collide with empty separator do NOT collide', () => {
      const a = composeArticleText({ title: 'ab', description: 'cd', content: '' });
      const b = composeArticleText({ title: 'a', description: '', content: 'bcd' });
      expect(a).not.toBe(b);
    });
  });

  describe('sha256', () => {
    it('returns a 64-char lowercase hex string', () => {
      const hash = sha256('hello');
      expect(hash).toMatch(/^[a-f0-9]{64}$/);
    });

    it('is deterministic on the same input', () => {
      expect(sha256('hello')).toBe(sha256('hello'));
    });

    it('differs when one character changes', () => {
      expect(sha256('hello')).not.toBe(sha256('hellp'));
    });

    it('handles unicode separator correctly', () => {
      const a = sha256(`A\x01BC`);
      const b = sha256('ABC');
      expect(a).not.toBe(b);
    });
  });

  describe('truncateForEmbed', () => {
    it('returns text unchanged when shorter than the cap', () => {
      const text = 'A'.repeat(100);
      expect(truncateForEmbed(text)).toBe(text);
    });

    it('truncates to EMBED_TEXT_MAX_CHARS when longer', () => {
      const text = 'A'.repeat(EMBED_TEXT_MAX_CHARS + 100);
      expect(truncateForEmbed(text)).toHaveLength(EMBED_TEXT_MAX_CHARS);
    });

    it('truncation does NOT alter the hash', () => {
      const longText = 'A'.repeat(10000);
      const shortHash = sha256(longText);
      const truncatedHash = sha256(truncateForEmbed(longText));
      expect(shortHash).not.toBe(truncatedHash);
    });

    it('exposes EMBED_TEXT_MAX_CHARS as 8000', () => {
      expect(EMBED_TEXT_MAX_CHARS).toBe(8000);
    });
  });
});
