import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/thumbnail_storage_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/user_article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/thumbnail_reference.dart';

/// Publishes a new article on behalf of the signed-in journalist.
///
/// Order of operations: validate locally, upload the thumbnail (if any),
/// create the document. If the document cannot be created the uploaded
/// thumbnail is deleted so no orphan files are left in storage.
class PublishArticleUseCase
    implements UseCase<DataState<ArticleEntity>, PublishArticleParams> {
  final UserArticleRepository _userArticleRepository;
  final ThumbnailStorageRepository _thumbnailStorageRepository;
  final AuthRepository _authRepository;

  const PublishArticleUseCase(
    this._userArticleRepository,
    this._thumbnailStorageRepository,
    this._authRepository,
  );

  @override
  Future<DataState<ArticleEntity>> call(PublishArticleParams params) async {
    final validationFailure = _validate(params);
    if (validationFailure != null) {
      return DataFailed(validationFailure);
    }

    final user = _authRepository.currentUser;
    if (user == null) {
      return const DataFailed(Failure.unauthenticated());
    }

    ThumbnailReference? thumbnail;
    final image = params.thumbnail;
    if (image != null) {
      final upload = await _thumbnailStorageRepository.upload(image);
      if (upload is DataFailed<ThumbnailReference>) {
        return DataFailed(upload.failure);
      }
      thumbnail = upload.dataOrNull;
    }

    final created = await _userArticleRepository.createArticle(
      draft: params.draft,
      authorId: user.id,
      authorName: user.preferredName,
      thumbnail: thumbnail,
    );

    if (created is DataFailed<ArticleEntity> && thumbnail != null) {
      await _thumbnailStorageRepository.delete(thumbnail.path);
    }

    return created;
  }

  Failure? _validate(PublishArticleParams params) {
    final draftErrors = params.draft.validate();
    if (draftErrors.isNotEmpty) {
      return Failure.validation(draftErrors.first.message);
    }
    final imageErrors = params.thumbnail?.validate() ?? const [];
    if (imageErrors.isNotEmpty) {
      return Failure.validation(imageErrors.first.message);
    }
    return null;
  }
}
