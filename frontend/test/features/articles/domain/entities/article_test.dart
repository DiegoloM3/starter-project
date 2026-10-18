import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_content.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_topic.dart';

ArticleEntity buildArticle({ArticleContent? content}) {
  return ArticleEntity(
    id: 'article-1',
    title: 'Title',
    description: 'Description',
    content: content ?? ArticleContent.fromPlainText('Content'),
    thumbnailURL: 'https://example.com/thumbnail.jpg',
    topics: const [ArticleTopic.gaming],
    publishedAt: DateTime(2026, 10, 17),
    authorId: 'journalist-1',
    authorName: 'Jane Doe',
  );
}

String wordsRepeated(int count) => List.filled(count, 'word').join(' ');

void main() {
  group('ArticleEntity.isAuthoredBy', () {
    test('is true for the author', () {
      expect(buildArticle().isAuthoredBy('journalist-1'), isTrue);
    });

    test('is false for another user', () {
      expect(buildArticle().isAuthoredBy('someone-else'), isFalse);
    });

    test('is false when nobody is signed in', () {
      expect(buildArticle().isAuthoredBy(null), isFalse);
    });
  });

  group('ArticleEntity.readingTimeInMinutes', () {
    test('is one minute for up to 200 words', () {
      final article = buildArticle(content: ArticleContent.fromPlainText(wordsRepeated(200)));

      expect(article.readingTimeInMinutes, 1);
    });

    test('rounds up to the next minute', () {
      final article = buildArticle(content: ArticleContent.fromPlainText(wordsRepeated(201)));

      expect(article.readingTimeInMinutes, 2);
    });

    test('is at least one minute for very short articles', () {
      final article = buildArticle(content: ArticleContent.fromPlainText('Short'));

      expect(article.readingTimeInMinutes, 1);
    });
  });
}
