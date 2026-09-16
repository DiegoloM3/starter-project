import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/article_firestore_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/user_article_model.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/feed.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/user_article_repository.dart';
import 'package:news_app_clean_architecture/shared/firebase/data/data_sources/firebase_failure_mapper.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/thumbnail_reference.dart';

class UserArticleRepositoryImpl implements UserArticleRepository {
  final ArticleFirestoreService _service;

  const UserArticleRepositoryImpl(this._service);

  /// Firestore has no full-text search, so the newest documents are fetched
  /// and filtered on the device.
  static const int searchWindow = 200;

  @override
  Future<DataState<List<ArticleEntity>>> getArticles() {
    return _guard(() async {
      final models = await _service.fetchArticles();
      return FeedEntity.sortNewestFirst(models.map((m) => m.toEntity()));
    });
  }

  @override
  Future<DataState<List<ArticleEntity>>> getArticlesByAuthor(String authorId) {
    return _guard(() async {
      final models = await _service.fetchArticlesByAuthor(authorId);
      return FeedEntity.sortNewestFirst(models.map((m) => m.toEntity()));
    });
  }

  @override
  Future<DataState<ArticleEntity>> getArticle(String id) {
    return _guard(() async {
      final model = await _service.fetchArticle(id);
      if (model == null) throw const _NotFound();
      return model.toEntity();
    });
  }

  @override
  Future<DataState<List<ArticleEntity>>> searchArticles(String query) {
    return _guard(() async {
      final needle = query.trim().toLowerCase();
      if (needle.isEmpty) return const [];
      final models = await _service.fetchArticles(limit: searchWindow);
      final matches = models.where((m) => _matches(m, needle)).map((m) => m.toEntity());
      return FeedEntity.sortNewestFirst(matches);
    });
  }

  @override
  Future<DataState<ArticleEntity>> createArticle({
    required ArticleDraft draft,
    required String authorId,
    required String authorName,
    ThumbnailReference? thumbnail,
  }) {
    return _guard(() async {
      final pending = UserArticleModel.fromDraft(
        id: '',
        draft: draft,
        authorId: authorId,
        authorName: authorName,
        thumbnail: thumbnail,
      );
      final id = await _service.createArticle(pending.toRawData());
      return pending.toEntity().copyWith(id: id);
    });
  }

  @override
  Future<DataState<ArticleEntity>> updateArticle({
    required String id,
    required ArticleDraft draft,
    ThumbnailReference? thumbnail,
  }) {
    return _guard(() async {
      final current = await _service.fetchArticle(id);
      if (current == null) throw const _NotFound();
      final updated = UserArticleModel.fromDraft(
        id: id,
        draft: draft,
        authorId: current.authorId!,
        authorName: current.author,
        thumbnail: thumbnail,
      );
      await _service.updateArticle(id, updated.toRawData());
      return updated.toEntity();
    });
  }

  @override
  Future<DataState<void>> deleteArticle(String id) => _guard(() => _service.deleteArticle(id));

  static bool _matches(ArticleEntity article, String needle) {
    return article.title.toLowerCase().contains(needle) ||
        (article.description?.toLowerCase().contains(needle) ?? false) ||
        article.content.toLowerCase().contains(needle);
  }

  Future<DataState<T>> _guard<T>(Future<T> Function() operation) => runGuarded(
        operation,
        onError: (error) =>
            error is _NotFound ? const Failure.notFound('Article not found.') : FirebaseFailureMapper.map(error),
      );
}

class _NotFound implements Exception {
  const _NotFound();
}
