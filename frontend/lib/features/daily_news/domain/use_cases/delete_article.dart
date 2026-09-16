import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/thumbnail_storage_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/user_article_repository.dart';

/// Deletes an article the signed-in journalist owns, then its thumbnail.
///
/// The document is the source of truth: once it is gone the operation counts
/// as successful even if the thumbnail could not be removed, because the
/// reader can no longer see the article either way.
class DeleteArticleUseCase implements UseCase<DataState<void>, ArticleEntity> {
  final UserArticleRepository _userArticleRepository;
  final ThumbnailStorageRepository _thumbnailStorageRepository;
  final AuthRepository _authRepository;

  const DeleteArticleUseCase(
    this._userArticleRepository,
    this._thumbnailStorageRepository,
    this._authRepository,
  );

  @override
  Future<DataState<void>> call(ArticleEntity params) async {
    final user = _authRepository.currentUser;
    if (user == null) {
      return const DataFailed(Failure.unauthenticated());
    }
    if (!params.isOwnedBy(user.id)) {
      return const DataFailed(
        Failure.permissionDenied('You can only delete your own articles.'),
      );
    }

    final deleted = await _userArticleRepository.deleteArticle(params.id);
    if (deleted is DataFailed<void>) {
      return deleted;
    }

    final imagePath = params.imagePath;
    if (imagePath != null) {
      await _thumbnailStorageRepository.delete(imagePath);
    }

    return const DataSuccess(null);
  }
}
