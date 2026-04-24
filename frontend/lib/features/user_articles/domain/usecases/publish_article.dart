import 'package:dartz/dartz.dart';
import 'package:news_app_clean_architecture/core/error/app_failure.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/repository/user_article_repository.dart';

/// Enforces the same contract as `firestore.rules#isValidArticle` so the
/// UI gets a fast, offline validation before hitting Firestore and so the
/// server never returns a surprise failure for a request the client could
/// have caught.
class PublishArticleUseCase
    extends UseCase<UserArticleEntity, PublishArticleParams> {
  PublishArticleUseCase(this._repository);

  final UserArticleRepository _repository;

  @override
  Future<Either<AppFailure, UserArticleEntity>> call(
    PublishArticleParams params,
  ) {
    final validation = _validate(params);
    if (validation != null) {
      return Future.value(Left(validation));
    }
    return _repository.publishArticle(params);
  }

  AppFailure? _validate(PublishArticleParams params) {
    if (params.authorId.isEmpty) {
      return const AppFailure.validation(
        field: 'authorId',
        reason: 'required',
      );
    }
    if (params.title.length < 5 || params.title.length > 120) {
      return const AppFailure.validation(
        field: 'title',
        reason: 'must be between 5 and 120 chars',
      );
    }
    if (params.description.length > 280) {
      return const AppFailure.validation(
        field: 'description',
        reason: 'max 280 chars',
      );
    }
    if (params.content.length < 50 || params.content.length > 20000) {
      return const AppFailure.validation(
        field: 'content',
        reason: 'must be between 50 and 20000 chars',
      );
    }
    if (params.thumbnailURL.isEmpty) {
      return const AppFailure.validation(
        field: 'thumbnailURL',
        reason: 'required',
      );
    }
    if (params.tags.length > 5) {
      return const AppFailure.validation(
        field: 'tags',
        reason: 'max 5 tags',
      );
    }
    return null;
  }
}
