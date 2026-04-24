import 'package:dartz/dartz.dart';
import 'package:news_app_clean_architecture/core/error/app_failure.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/delete_article_params.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/update_article_params.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/upload_thumbnail_params.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/repository/user_article_repository.dart';

/// In-memory implementation used while F7 builds the presentation layer.
/// F8 swaps it for the real Firestore-backed repository without touching
/// a single use case or bloc.
class FakeUserArticleRepository implements UserArticleRepository {
  FakeUserArticleRepository({DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  final Map<String, UserArticleEntity> _store = <String, UserArticleEntity>{};
  int _idSeed = 1;

  @override
  Future<Either<AppFailure, List<UserArticleEntity>>> getMyArticles(
    String authorId,
  ) async {
    final articles = _store.values
        .where((article) => article.authorId == authorId)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return Right(articles);
  }

  @override
  Future<Either<AppFailure, UserArticleEntity>> publishArticle(
    PublishArticleParams params,
  ) async {
    final now = _now();
    final id = 'fake_${_idSeed++}';
    final article = UserArticleEntity(
      id: id,
      authorId: params.authorId,
      authorName: params.authorName,
      title: params.title,
      description: params.description,
      content: params.content,
      thumbnailURL: params.thumbnailURL,
      tags: params.tags,
      status: UserArticleStatus.published,
      publishedAt: now,
      updatedAt: now,
    );
    _store[id] = article;
    return Right(article);
  }

  @override
  Future<Either<AppFailure, UserArticleEntity>> updateArticle(
    UpdateArticleParams params,
  ) async {
    final existing = _store[params.id];
    if (existing == null) {
      return const Left(
        AppFailure.validation(field: 'id', reason: 'not found'),
      );
    }
    final updated = existing.copyWith(
      title: params.title,
      description: params.description,
      content: params.content,
      thumbnailURL: params.thumbnailURL,
      tags: params.tags,
      updatedAt: _now(),
    );
    _store[params.id] = updated;
    return Right(updated);
  }

  @override
  Future<Either<AppFailure, Unit>> deleteArticle(
    DeleteArticleParams params,
  ) async {
    final removed = _store.remove(params.id);
    if (removed == null) {
      return const Left(
        AppFailure.validation(field: 'id', reason: 'not found'),
      );
    }
    return const Right(unit);
  }

  @override
  Future<Either<AppFailure, String>> uploadThumbnail(
    UploadThumbnailParams params,
  ) async {
    final url =
        'https://fake.storage/media/articles/${params.authorId}/${params.articleId}/${params.fileName}';
    return Right(url);
  }
}
