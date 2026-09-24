import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/network_failure.dart';
import 'package:news_app_clean_architecture/core/resources/remote_exception.dart';

import '../../domain/entities/article_thumbnail.dart';
import '../../domain/repository/article_thumbnail_repository.dart';
import '../data_sources/remote/article_storage_service.dart';

/// Cloud Storage implementation of [ArticleThumbnailRepository].
class ArticleThumbnailRepositoryImpl implements ArticleThumbnailRepository {
  final ArticleStorageService _storageService;

  const ArticleThumbnailRepositoryImpl(this._storageService);

  @override
  Future<DataState<String>> uploadThumbnail({
    required String userId,
    required ArticleThumbnailEntity thumbnail,
  }) async {
    try {
      final downloadUrl = await _storageService.uploadThumbnail(
        userId: userId,
        thumbnail: thumbnail,
      );

      return DataSuccess(downloadUrl);
    } on RemoteException catch (error) {
      // An upload that could not reach Cloud Storage is worth naming: it is
      // the one failure the journalist can fix by finding signal.
      return DataFailed(
        _connectivityCodes.contains(error.code)
            ? const NetworkUnavailableException()
            : error,
      );
    } catch (error) {
      // An error that escapes here would hang the editor's upload spinner
      // instead of reporting anything.
      return DataFailed(error);
    }
  }

  /// What Cloud Storage calls "I could not reach the server".
  static const Set<String> _connectivityCodes = {
    RemoteException.unavailableCode,
    'retry-limit-exceeded',
    'network-request-failed',
  };
}
