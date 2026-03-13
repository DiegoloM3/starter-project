import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article.dart';

void main() {
  group('UserArticleEntity', () {
    final testArticle = UserArticleEntity(
      id: 'article-id',
      authorId: 'author-id',
      authorName: 'Author Name',
      title: 'Test Title',
      description: 'Test Description',
      content: 'Test Content',
      thumbnailUrl: 'https://example.com/thumb.jpg',
      categories: ['Tech', 'News'],
      isDraft: false,
      publishedAt: DateTime(2024, 1, 15),
      createdAt: DateTime(2024, 1, 10),
      updatedAt: DateTime(2024, 1, 15),
    );

    test('should create UserArticleEntity with all properties', () {
      expect(testArticle.id, 'article-id');
      expect(testArticle.authorId, 'author-id');
      expect(testArticle.authorName, 'Author Name');
      expect(testArticle.title, 'Test Title');
      expect(testArticle.description, 'Test Description');
      expect(testArticle.content, 'Test Content');
      expect(testArticle.thumbnailUrl, 'https://example.com/thumb.jpg');
      expect(testArticle.categories, ['Tech', 'News']);
      expect(testArticle.isDraft, false);
      expect(testArticle.publishedAt, DateTime(2024, 1, 15));
      expect(testArticle.createdAt, DateTime(2024, 1, 10));
      expect(testArticle.updatedAt, DateTime(2024, 1, 15));
    });

    test('should default isDraft to true', () {
      const article = UserArticleEntity();
      expect(article.isDraft, true);
    });

    test('copyWith should create new instance with updated values', () {
      final updatedArticle = testArticle.copyWith(
        title: 'Updated Title',
        isDraft: true,
      );

      expect(updatedArticle.title, 'Updated Title');
      expect(updatedArticle.isDraft, true);
      // Original values should be preserved
      expect(updatedArticle.id, testArticle.id);
      expect(updatedArticle.authorId, testArticle.authorId);
      expect(updatedArticle.content, testArticle.content);
    });

    test('copyWith should preserve original values when not specified', () {
      final copiedArticle = testArticle.copyWith();

      expect(copiedArticle.id, testArticle.id);
      expect(copiedArticle.title, testArticle.title);
      expect(copiedArticle.content, testArticle.content);
      expect(copiedArticle.categories, testArticle.categories);
    });

    test('copyWith should allow setting values to new values', () {
      final updatedArticle = testArticle.copyWith(
        thumbnailUrl: 'https://new-url.com/image.jpg',
        categories: ['Programming'],
        publishedAt: DateTime(2024, 2, 1),
      );

      expect(updatedArticle.thumbnailUrl, 'https://new-url.com/image.jpg');
      expect(updatedArticle.categories, ['Programming']);
      expect(updatedArticle.publishedAt, DateTime(2024, 2, 1));
    });

    test('props should return all properties for Equatable', () {
      expect(testArticle.props.length, 13);
      expect(testArticle.props, contains('article-id'));
      expect(testArticle.props, contains('Test Title'));
      expect(testArticle.props, contains(false)); // isDraft
    });

    test('two entities with same properties should be equal', () {
      final article1 = UserArticleEntity(
        id: 'same-id',
        title: 'Same Title',
        isDraft: true,
      );
      final article2 = UserArticleEntity(
        id: 'same-id',
        title: 'Same Title',
        isDraft: true,
      );

      expect(article1, equals(article2));
    });

    test('two entities with different properties should not be equal', () {
      final article1 = UserArticleEntity(id: 'id-1', title: 'Title 1');
      final article2 = UserArticleEntity(id: 'id-2', title: 'Title 2');

      expect(article1, isNot(equals(article2)));
    });

    test('should handle null categories in copyWith', () {
      const articleWithNullCategories = UserArticleEntity(
        id: 'test-id',
        categories: null,
      );

      final copied = articleWithNullCategories.copyWith(title: 'New Title');
      expect(copied.categories, isNull);
    });
  });
}
