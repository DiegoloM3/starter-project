import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article.dart';

/// Test fixtures for creating consistent test data across tests.
class TestFixtures {
  // ==================== User Fixtures ====================

  static UserEntity get testUser => UserEntity(
        id: 'test-user-id',
        email: 'test@example.com',
        displayName: 'Test User',
        photoUrl: 'https://example.com/photo.jpg',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

  static UserEntity get testUser2 => UserEntity(
        id: 'test-user-id-2',
        email: 'test2@example.com',
        displayName: 'Test User 2',
        photoUrl: null,
        createdAt: DateTime(2024, 2, 1),
        updatedAt: DateTime(2024, 2, 1),
      );

  // ==================== Article Fixtures ====================

  static UserArticleEntity get testArticle => UserArticleEntity(
        id: 'test-article-id',
        authorId: 'test-user-id',
        authorName: 'Test User',
        title: 'Test Article Title',
        description: 'Test article description',
        content:
            'This is the test article content. It contains multiple paragraphs.',
        thumbnailUrl: 'https://example.com/thumbnail.jpg',
        categories: const ['Technology', 'Flutter'],
        isDraft: false,
        publishedAt: DateTime(2024, 1, 15),
        createdAt: DateTime(2024, 1, 10),
        updatedAt: DateTime(2024, 1, 15),
      );

  static UserArticleEntity get testDraftArticle => UserArticleEntity(
        id: 'test-draft-id',
        authorId: 'test-user-id',
        authorName: 'Test User',
        title: 'Draft Article Title',
        description: 'Draft article description',
        content: 'This is a draft article content.',
        thumbnailUrl: null,
        categories: const ['Programming'],
        isDraft: true,
        publishedAt: null,
        createdAt: DateTime(2024, 1, 20),
        updatedAt: DateTime(2024, 1, 20),
      );

  static UserArticleEntity get newArticle => const UserArticleEntity(
        authorId: 'test-user-id',
        authorName: 'Test User',
        title: 'New Article',
        description: 'New article description',
        content: 'Content for new article.',
        categories: ['News'],
        isDraft: true,
      );

  static List<UserArticleEntity> get testArticleList => [
        testArticle,
        testDraftArticle,
        UserArticleEntity(
          id: 'test-article-3',
          authorId: 'test-user-id',
          authorName: 'Test User',
          title: 'Another Published Article',
          description: 'Another description',
          content: 'More content here.',
          categories: const ['Technology'],
          isDraft: false,
          publishedAt: DateTime(2024, 1, 12),
          createdAt: DateTime(2024, 1, 5),
          updatedAt: DateTime(2024, 1, 12),
        ),
      ];

  static List<UserArticleEntity> get publishedArticlesOnly =>
      testArticleList.where((a) => !a.isDraft).toList();

  static List<UserArticleEntity> get technologyArticles => testArticleList
      .where((a) => (a.categories ?? []).contains('Technology'))
      .toList();
}
