import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_content.dart';

void main() {
  group('ArticleContent', () {
    test('extracts the plain text of the rich text, ignoring formatting and images', () {
      const content = ArticleContent(
        '[{"insert":"Hello "},{"insert":"world","attributes":{"bold":true}},'
        '{"insert":{"image":"https://example.com/a.jpg"}},{"insert":"\\n"}]',
      );

      expect(content.plainText.trim(), 'Hello world');
    });

    test('is empty when it only contains line breaks or spaces', () {
      expect(const ArticleContent('[{"insert":"  \\n"}]').isEmpty, isTrue);
    });

    test('is not empty when it contains text', () {
      expect(ArticleContent.fromPlainText('Hello').isEmpty, isFalse);
    });

    test('treats malformed rich text as empty content', () {
      const content = ArticleContent('not json');

      expect(content.plainText, isEmpty);
      expect(content.isEmpty, isTrue);
    });

    test('counts the words of the plain text', () {
      expect(ArticleContent.fromPlainText('One two  three\nfour').wordCount, 4);
    });

    test('builds rich text from plain text', () {
      expect(ArticleContent.fromPlainText('Hello').plainText.trim(), 'Hello');
    });
  });
}
