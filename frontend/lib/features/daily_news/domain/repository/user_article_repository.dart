import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/thumbnail_reference.dart';

/// Articles written inside the app and stored in our backend.
abstract interface class UserArticleRepository {
  /// Every published article, newest first.
  Future<DataState<List<ArticleEntity>>> getArticles();

  /// Articles written by one journalist, newest first.
  Future<DataState<List<ArticleEntity>>> getArticlesByAuthor(String authorId);

  Future<DataState<ArticleEntity>> getArticle(String id);

  /// Case-insensitive match on title, summary and body.
  Future<DataState<List<ArticleEntity>>> searchArticles(String query);

  /// Stores a new article and returns it with its backend id.
  Future<DataState<ArticleEntity>> createArticle({
    required ArticleDraft draft,
    required String authorId,
    required String authorName,
    ThumbnailReference? thumbnail,
  });

  /// Overwrites the text fields and thumbnail of an existing article.
  Future<DataState<ArticleEntity>> updateArticle({
    required String id,
    required ArticleDraft draft,
    ThumbnailReference? thumbnail,
  });

  Future<DataState<void>> deleteArticle(String id);
}
