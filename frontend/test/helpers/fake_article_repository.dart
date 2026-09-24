import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

/// Hand written test double for the `daily_news` [ArticleRepository].
///
/// It keeps the saved articles in a list rather than just recording calls, so
/// a test can assert what the reader would actually see after saving or
/// removing one.
class FakeArticleRepository implements ArticleRepository {
  DataState<List<ArticleEntity>> newsArticlesResult =
      const DataSuccess(<ArticleEntity>[]);

  final List<ArticleEntity> savedArticles = [];

  /// Set to make the local database misbehave, so a test can check what the
  /// screen does when saving or reading fails.
  DataState<void>? writeResult;
  DataState<List<ArticleEntity>>? savedArticlesResult;

  int saveCallCount = 0;
  int removeCallCount = 0;

  NewsCategory? lastRequestedCategory;

  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticles({
    NewsCategory category = NewsCategory.general,
  }) async {
    lastRequestedCategory = category;
    return newsArticlesResult;
  }

  @override
  Future<DataState<List<ArticleEntity>>> getSavedArticles() async {
    return savedArticlesResult ??
        DataSuccess(List<ArticleEntity>.from(savedArticles));
  }

  /// Mirrors `ArticleRepositoryImpl`: saving something already saved does
  /// nothing, and removal matches on the article rather than on the local id,
  /// which an article straight from the API does not have.
  @override
  Future<DataState<void>> saveArticle(ArticleEntity article) async {
    saveCallCount++;

    final failure = writeResult;
    if (failure != null) {
      return failure;
    }

    if (!savedArticles.any(article.isSameArticleAs)) {
      savedArticles.add(article);
    }

    return const DataSuccess(null);
  }

  @override
  Future<DataState<void>> removeArticle(ArticleEntity article) async {
    removeCallCount++;

    final failure = writeResult;
    if (failure != null) {
      return failure;
    }

    savedArticles.removeWhere(article.isSameArticleAs);

    return const DataSuccess(null);
  }
}

ArticleEntity newsArticle({
  String title = 'Global Supply Rebounds Amid Automated Shipping Surges',
  String author = 'Geneva Post',
  String? publishedAt = '2026-09-22T09:00:00Z',
  // The url is what tells two articles apart everywhere the app compares
  // them, so a test that needs a second, different article overrides it.
  String url = 'https://example.com/article',
}) {
  return ArticleEntity(
    author: author,
    title: title,
    description: 'Three lines, one new interchange and a fare system.',
    url: url,
    urlToImage: '',
    publishedAt: publishedAt,
    content: 'The transit authority published a 180 page plan.',
  );
}
