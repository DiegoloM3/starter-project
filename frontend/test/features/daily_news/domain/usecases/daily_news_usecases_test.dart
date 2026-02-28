import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/delete_my_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_community_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_my_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_saved_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/remove_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/save_local_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/save_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/upload_article_image.dart';

class FakeArticleRepository implements ArticleRepository {
  DataState<List<ArticleEntity>> newsResult = const DataSuccess([]);
  DataState<List<ArticleEntity>> byAuthorResult = const DataSuccess([]);
  DataState<List<ArticleEntity>> communityResult = const DataSuccess([]);
  List<ArticleEntity> savedResult = const [];
  String uploadResult = '';

  String? lastRequestedAuthorId;
  String? lastUploadAuthorId;
  String? lastUploadPath;
  ArticleEntity? lastCreatedArticle;
  ArticleEntity? lastDeletedMyArticle;
  ArticleEntity? lastSavedLocalArticle;
  ArticleEntity? lastSavedArticle;
  ArticleEntity? lastRemovedArticle;

  @override
  Future<void> deleteMyArticle(ArticleEntity article) async {
    lastDeletedMyArticle = article;
  }

  @override
  Future<DataState<List<ArticleEntity>>> getArticlesByAuthor(
    String authorId,
  ) async {
    lastRequestedAuthorId = authorId;
    return byAuthorResult;
  }

  @override
  Future<DataState<List<ArticleEntity>>> getCommunityArticles() async {
    return communityResult;
  }

  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticles() async {
    return newsResult;
  }

  @override
  Future<List<ArticleEntity>> getSavedArticles() async {
    return savedResult;
  }

  @override
  Future<void> removeArticle(ArticleEntity article) async {
    lastRemovedArticle = article;
  }

  @override
  Future<void> saveArticle(ArticleEntity article) async {
    lastSavedArticle = article;
  }

  @override
  Future<void> saveArticleLocally(ArticleEntity article) async {
    lastSavedLocalArticle = article;
  }

  @override
  Future<String> uploadArticleImage({
    required String authorId,
    required String localPath,
  }) async {
    lastUploadAuthorId = authorId;
    lastUploadPath = localPath;
    return uploadResult;
  }
}

void main() {
  group('DailyNews use cases', () {
    late FakeArticleRepository repository;
    const article = ArticleEntity(
      authorId: 'uid-1',
      title: 'Title',
      description: 'Description',
      content: 'Content',
    );

    setUp(() {
      repository = FakeArticleRepository();
    });

    test('GetArticleUseCase returns repository news result', () async {
      const expected = DataSuccess<List<ArticleEntity>>([article]);
      repository.newsResult = expected;
      final useCase = GetArticleUseCase(repository);

      final result = await useCase();

      expect(result, same(expected));
    });

    test('GetSavedArticleUseCase returns saved articles', () async {
      repository.savedResult = const [article];
      final useCase = GetSavedArticleUseCase(repository);

      final result = await useCase();

      expect(result, equals(const [article]));
    });

    test('GetMyArticlesUseCase requests by authorId', () async {
      const expected = DataSuccess<List<ArticleEntity>>([article]);
      repository.byAuthorResult = expected;
      final useCase = GetMyArticlesUseCase(repository);

      final result = await useCase(params: GetMyArticlesParams('author-123'));

      expect(result, same(expected));
      expect(repository.lastRequestedAuthorId, 'author-123');
    });

    test('GetCommunityArticlesUseCase returns community articles', () async {
      const expected = DataSuccess<List<ArticleEntity>>([article]);
      repository.communityResult = expected;
      final useCase = GetCommunityArticlesUseCase(repository);

      final result = await useCase();

      expect(result, same(expected));
    });

    test('DeleteMyArticleUseCase forwards article', () async {
      final useCase = DeleteMyArticleUseCase(repository);

      await useCase(params: article);

      expect(repository.lastDeletedMyArticle, equals(article));
    });

    test('SaveArticleUseCase forwards article for remote creation', () async {
      final useCase = SaveArticleUseCase(repository);

      await useCase(params: article);

      expect(repository.lastSavedArticle, equals(article));
    });

    test('SaveLocalArticleUseCase forwards article for local save', () async {
      final useCase = SaveLocalArticleUseCase(repository);

      await useCase(params: article);

      expect(repository.lastSavedLocalArticle, equals(article));
    });

    test('RemoveArticleUseCase forwards article', () async {
      final useCase = RemoveArticleUseCase(repository);

      await useCase(params: article);

      expect(repository.lastRemovedArticle, equals(article));
    });

    test('UploadArticleImageUseCase forwards params and returns url', () async {
      repository.uploadResult = 'https://example.com/image.jpg';
      final useCase = UploadArticleImageUseCase(repository);

      final result = await useCase(
        params: UploadArticleImageParams(
          authorId: 'author-1',
          localPath: '/tmp/photo.jpg',
        ),
      );

      expect(result, 'https://example.com/image.jpg');
      expect(repository.lastUploadAuthorId, 'author-1');
      expect(repository.lastUploadPath, '/tmp/photo.jpg');
    });
  });
}
