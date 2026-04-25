import 'package:dartz/dartz.dart';
import 'package:news_app_clean_architecture/core/error/app_failure.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/upload_thumbnail_params.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/repository/user_article_repository.dart';

class UploadThumbnailUseCase extends UseCase<String, UploadThumbnailParams> {
  UploadThumbnailUseCase(this._repository);

  final UserArticleRepository _repository;

  static const _maxBytes = 5 * 1024 * 1024;

  @override
  Future<Either<AppFailure, String>> call(UploadThumbnailParams params) {
    if (params.authorId.isEmpty) {
      return Future.value(
        const Left(
          AppFailure.validation(field: 'authorId', reason: 'required'),
        ),
      );
    }
    if (params.articleId.isEmpty) {
      return Future.value(
        const Left(
          AppFailure.validation(field: 'articleId', reason: 'required'),
        ),
      );
    }
    if (params.bytes.isEmpty) {
      return Future.value(
        const Left(
          AppFailure.validation(field: 'bytes', reason: 'required'),
        ),
      );
    }
    if (params.bytes.length > _maxBytes) {
      return Future.value(
        const Left(
          AppFailure.validation(field: 'bytes', reason: 'max 5 MiB'),
        ),
      );
    }
    if (!params.contentType.startsWith('image/')) {
      return Future.value(
        const Left(
          AppFailure.validation(
            field: 'contentType',
            reason: 'must be image/*',
          ),
        ),
      );
    }
    return _repository.uploadThumbnail(params);
  }
}
