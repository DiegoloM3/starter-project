import 'package:dartz/dartz.dart';
import 'package:news_app_clean_architecture/core/error/app_failure.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/delete_article_params.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/update_article_params.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/upload_thumbnail_params.dart';

/// Port that the domain use cases depend on. Implemented by the Firestore
/// data source in F8 and by `FakeUserArticleRepository` in the meantime.
abstract class UserArticleRepository {
  Future<Either<AppFailure, List<UserArticleEntity>>> getMyArticles(
    String authorId,
  );

  Future<Either<AppFailure, UserArticleEntity>> publishArticle(
    PublishArticleParams params,
  );

  Future<Either<AppFailure, UserArticleEntity>> updateArticle(
    UpdateArticleParams params,
  );

  Future<Either<AppFailure, Unit>> deleteArticle(DeleteArticleParams params);

  /// Returns the publicly-accessible URL for the uploaded thumbnail.
  Future<Either<AppFailure, String>> uploadThumbnail(
    UploadThumbnailParams params,
  );
}
