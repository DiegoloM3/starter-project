import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/thumbnail_storage_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/user_article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/thumbnail_reference.dart';

/// Edits an article the signed-in journalist owns.
///
/// Thumbnail handling:
/// - a new image is uploaded first, the document updated, then the previous
///   file deleted;
/// - `removeThumbnail` updates the document without an image, then deletes
///   the previous file;
/// - otherwise the current thumbnail is kept untouched.
class UpdateArticleUseCase
    implements UseCase<DataState<ArticleEntity>, UpdateArticleParams> {
  final UserArticleRepository _userArticleRepository;
  final ThumbnailStorageRepository _thumbnailStorageRepository;
  final AuthRepository _authRepository;

  const UpdateArticleUseCase(
    this._userArticleRepository,
    this._thumbnailStorageRepository,
    this._authRepository,
  );

  @override
  Future<DataState<ArticleEntity>> call(UpdateArticleParams params) async {
    final validationFailure = _validate(params);
    if (validationFailure != null) {
      return DataFailed(validationFailure);
    }

    final ownershipFailure = _checkOwnership(params.article);
    if (ownershipFailure != null) {
      return DataFailed(ownershipFailure);
    }

    final thumbnailResolution = await _resolveThumbnail(params);
    if (thumbnailResolution is DataFailed<_ThumbnailChange>) {
      return DataFailed(thumbnailResolution.failure);
    }
    final change = thumbnailResolution.dataOrNull!;

    final updated = await _userArticleRepository.updateArticle(
      id: params.article.id,
      draft: params.draft,
      thumbnail: change.next,
    );

    if (updated is DataFailed<ArticleEntity>) {
      if (change.uploadedNew) {
        await _thumbnailStorageRepository.delete(change.next!.path);
      }
      return updated;
    }

    final previousPath = change.previousPathToDelete;
    if (previousPath != null) {
      await _thumbnailStorageRepository.delete(previousPath);
    }

    return updated;
  }

  Failure? _validate(UpdateArticleParams params) {
    final draftErrors = params.draft.validate();
    if (draftErrors.isNotEmpty) {
      return Failure.validation(draftErrors.first.message);
    }
    final imageErrors = params.newThumbnail?.validate() ?? const [];
    if (imageErrors.isNotEmpty) {
      return Failure.validation(imageErrors.first.message);
    }
    return null;
  }

  Failure? _checkOwnership(ArticleEntity article) {
    final user = _authRepository.currentUser;
    if (user == null) return const Failure.unauthenticated();
    if (!article.isOwnedBy(user.id)) {
      return const Failure.permissionDenied('You can only edit your own articles.');
    }
    return null;
  }

  Future<DataState<_ThumbnailChange>> _resolveThumbnail(
    UpdateArticleParams params,
  ) async {
    final current = _currentThumbnail(params.article);

    final newImage = params.newThumbnail;
    if (newImage != null) {
      final upload = await _thumbnailStorageRepository.upload(newImage);
      return upload.map(
        (reference) => _ThumbnailChange(
          next: reference,
          uploadedNew: true,
          previousPathToDelete: current?.path,
        ),
      );
    }

    if (params.removeThumbnail) {
      return DataSuccess(
        _ThumbnailChange(next: null, previousPathToDelete: current?.path),
      );
    }

    return DataSuccess(_ThumbnailChange(next: current));
  }

  ThumbnailReference? _currentThumbnail(ArticleEntity article) {
    final url = article.imageUrl;
    final path = article.imagePath;
    if (url == null || path == null) return null;
    return ThumbnailReference(url: url, path: path);
  }
}

class _ThumbnailChange {
  final ThumbnailReference? next;
  final bool uploadedNew;
  final String? previousPathToDelete;

  const _ThumbnailChange({
    required this.next,
    this.uploadedNew = false,
    this.previousPathToDelete,
  });
}
