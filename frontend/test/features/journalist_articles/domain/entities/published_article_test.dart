import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/published_article.dart';

PublishedArticleEntity articleWith(String content) {
  return PublishedArticleEntity(
    id: 'article-1',
    title: 'Title',
    content: content,
    description: '',
    author: 'Daily News Staff',
    thumbnailUrl: 'https://example.com/1.jpg',
    publishedAt: DateTime.utc(2026, 9, 28),
  );
}

void main() {
  group('readingTimeInMinutes', () {
    test('counts 200 words per minute, rounding up', () {
      expect(articleWith('word ' * 200).readingTimeInMinutes, 1);
      expect(articleWith('word ' * 201).readingTimeInMinutes, 2);
      expect(articleWith('word ' * 1000).readingTimeInMinutes, 5);
    });

    test('ignores the Markdown syntax', () {
      expect(articleWith('## ${'**word** ' * 400}').readingTimeInMinutes, 2);
    });

    test('is at least one minute', () {
      expect(articleWith('Short.').readingTimeInMinutes, 1);
      expect(articleWith('').readingTimeInMinutes, 1);
    });
  });
}
