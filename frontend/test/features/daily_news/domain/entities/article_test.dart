import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

void main() {
  group('isSameArticleAs', () {
    test('matches the saved copy of an article that came from the API', () {
      // The API copy has no id; the database gave the saved copy one. They are
      // the same article, and `==` would say otherwise.
      const fromApi = ArticleEntity(
        title: 'Retro Vinyl Returns',
        url: 'https://example.com/vinyl',
      );
      const fromDatabase = ArticleEntity(
        id: 7,
        title: 'Retro Vinyl Returns',
        url: 'https://example.com/vinyl',
      );

      expect(fromApi.isSameArticleAs(fromDatabase), isTrue);
      expect(fromApi == fromDatabase, isFalse);
    });

    test('does not match a different article', () {
      const one = ArticleEntity(url: 'https://example.com/vinyl');
      const other = ArticleEntity(url: 'https://example.com/transit');

      expect(one.isSameArticleAs(other), isFalse);
    });

    test('never matches when there is no url to compare', () {
      const withoutUrl = ArticleEntity(title: 'No link');

      expect(withoutUrl.isSameArticleAs(withoutUrl), isFalse);
      expect(const ArticleEntity(url: '').isSameArticleAs(withoutUrl), isFalse);
    });
  });
}
