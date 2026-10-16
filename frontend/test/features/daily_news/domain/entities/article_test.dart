import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

void main() {
  group('ArticleEntity', () {
    const article = ArticleEntity(
      id: 1,
      author: 'Author',
      title: 'Title',
      description: 'Description',
      url: 'https://example.com',
      urlToImage: 'https://example.com/image.jpg',
      publishedAt: '2026-10-14T09:30:00Z',
      content: 'Content',
    );

    test('is equal to another article with the same values', () {
      const sameArticle = ArticleEntity(
        id: 1,
        author: 'Author',
        title: 'Title',
        description: 'Description',
        url: 'https://example.com',
        urlToImage: 'https://example.com/image.jpg',
        publishedAt: '2026-10-14T09:30:00Z',
        content: 'Content',
      );

      expect(article, sameArticle);
      expect(article.hashCode, sameArticle.hashCode);
    });

    test('shows the description before the content of a news article', () {
      const newsArticle = ArticleEntity(description: 'Summary of the news.', content: 'First lines of the story…');

      expect(newsArticle.body, 'Summary of the news.\n\nFirst lines of the story…');
    });

    test('does not repeat a description that is the beginning of the content', () {
      const publishedArticle = ArticleEntity(
        description: 'This is breaking news! Arnold…',
        content: 'This is breaking news!  Arnold\nhas been seen in the park.',
      );

      expect(publishedArticle.body, 'This is breaking news!  Arnold\nhas been seen in the park.');
    });

    test('does not repeat the description of formatted content', () {
      const publishedArticle = ArticleEntity(
        description: 'Key facts The council approved the park.',
        content: '## Key facts\nThe council approved the **park**.',
      );

      expect(publishedArticle.body, '## Key facts\nThe council approved the **park**.');
    });

    test('converts formatted content to plain text', () {
      expect(
        ArticleEntity.convertToPlainText('## Key facts\nThe council approved the **new park**.'),
        'Key facts The council approved the new park.',
      );
    });

    test('shows only the content when there is no description', () {
      expect(const ArticleEntity(content: 'Content').body, 'Content');
    });

    test('reads its publication date', () {
      expect(article.publicationDate, DateTime.utc(2026, 10, 14, 9, 30));
    });

    test('has no publication date when it is missing or invalid', () {
      expect(const ArticleEntity().publicationDate, isNull);
      expect(const ArticleEntity(publishedAt: '').publicationDate, isNull);
      expect(const ArticleEntity(publishedAt: 'yesterday').publicationDate, isNull);
    });

    test('is not written by a journalist of the app', () {
      expect(article.isWrittenByJournalist, isFalse);
    });

    test('is not equal to an article with different values', () {
      expect(article, isNot(const ArticleEntity(id: 2, title: 'Title')));
    });
  });
}
