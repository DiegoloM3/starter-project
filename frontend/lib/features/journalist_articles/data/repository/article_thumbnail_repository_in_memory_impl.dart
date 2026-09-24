import 'package:news_app_clean_architecture/core/resources/data_state.dart';

import '../../domain/entities/article_thumbnail.dart';
import '../../domain/repository/article_thumbnail_repository.dart';

/// In memory implementation of [ArticleThumbnailRepository] used while Cloud
/// Storage is not wired yet.
///
/// It returns the URL the real implementation will produce, built from the
/// `media/articles/{userId}` folder documented in `backend/docs/DB_SCHEMA.md`,
/// so the screens can already display the uploaded image path.
class ArticleThumbnailRepositoryInMemoryImpl
    implements ArticleThumbnailRepository {
  static const Duration _simulatedLatency = Duration(milliseconds: 600);
  static const String _storageBaseUrl =
      'https://storage.googleapis.com/mock-bucket/media/articles';

  const ArticleThumbnailRepositoryInMemoryImpl();

  @override
  Future<DataState<String>> uploadThumbnail({
    required String userId,
    required ArticleThumbnailEntity thumbnail,
  }) async {
    await Future.delayed(_simulatedLatency);

    return DataSuccess('$_storageBaseUrl/$userId/${thumbnail.fileName}');
  }
}
