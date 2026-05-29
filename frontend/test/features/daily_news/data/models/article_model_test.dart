import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';

void main() {
  group('ArticleModel.fromJson id generation', () {
    test('derives a deterministic id from the url (md5)', () {
      const url = 'https://example.com/article';
      final a = ArticleModel.fromJson(const {'url': url});
      final b = ArticleModel.fromJson(const {'url': url});

      // Same url -> same id, regardless of device/run. This is what makes the
      // shared comment thread stable (String.hashCode would not guarantee it).
      expect(a.id, b.id);
      expect(a.id, '141fbc787408697a5d22735982be532a');
    });

    test('different urls produce different ids', () {
      final a = ArticleModel.fromJson(const {'url': 'https://a.com/x'});
      final b = ArticleModel.fromJson(const {'url': 'https://b.com/y'});

      expect(a.id, isNot(b.id));
    });

    test('empty/missing url yields a null id (non-commentable)', () {
      expect(ArticleModel.fromJson(const {'url': ''}).id, isNull);
      expect(ArticleModel.fromJson(const {}).id, isNull);
    });
  });
}
