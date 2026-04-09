import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/utils/sanitize_article_content.dart';

// Pins spec 009 v1.1.0 content sanitizer. Each case corresponds to a
// real NewsAPI response shape we have observed.
void main() {
  group('sanitizeArticleContent', () {
    test('returns null for null input', () {
      expect(sanitizeArticleContent(null), isNull);
    });

    test('returns null for an empty string', () {
      expect(sanitizeArticleContent(''), isNull);
    });

    test('returns null for whitespace-only content', () {
      expect(sanitizeArticleContent('   \n\t  '), isNull);
    });

    test('strips the trailing "[+N chars]" truncation marker', () {
      final result = sanitizeArticleContent(
        'This is the body of the article. [+2978 chars]',
      );
      expect(result, 'This is the body of the article.');
    });

    test('strips the marker even with trailing whitespace', () {
      final result = sanitizeArticleContent(
        'Body here [+123 chars]   ',
      );
      expect(result, 'Body here');
    });

    test('normalizes CRLF to LF in plain text bodies', () {
      final result = sanitizeArticleContent(
        'Local\r\nUPDATE: something happened [+2978 chars]',
      );
      expect(result, 'Local\nUPDATE: something happened');
    });

    test('returns null for JSON scraper junk from blocked pages', () {
      final junk =
          '{"en":{"access_disabled":"Internet access has been disabled","code":"Code"}} [+6792 chars]';
      expect(sanitizeArticleContent(junk), isNull);
    });

    // Regression for the v1.1.0 shipping bug: NewsAPI truncates the scraper
    // junk to 200 chars mid-string, so after stripping "[+N chars]" the
    // remainder is structurally broken JSON. The earlier jsonDecode-based
    // detection fell through on this case and rendered the garbage.
    test('returns null for truncated JSON scraper junk (real NewsAPI shape)',
        () {
      final junk =
          '{"en":{"access_disabled":"Internet access has been disabled on this device","code":"Code","custom_block_list":"it is on a custom block list","email":"Email","file_ext_blocked":"the file extension is \u2026 [+6792 chars]';
      expect(sanitizeArticleContent(junk), isNull);
    });

    test('returns null for a JSON array keyed by a quoted identifier', () {
      expect(sanitizeArticleContent('[{"foo":"bar"}]'), isNull);
    });

    test('keeps text that starts with a brace but is not valid JSON', () {
      final result = sanitizeArticleContent(
        '{not a real json object} and some article text [+10 chars]',
      );
      expect(result, '{not a real json object} and some article text');
    });

    test('passes plain text through unchanged when no marker is present', () {
      final result = sanitizeArticleContent(
        'A clean article body without any NewsAPI markers.',
      );
      expect(result, 'A clean article body without any NewsAPI markers.');
    });
  });
}
