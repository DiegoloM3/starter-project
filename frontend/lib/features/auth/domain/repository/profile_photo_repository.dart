import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/shared/media/domain/entities/local_image.dart';

/// Storage for account photos. Each account owns exactly one file, so an
/// upload replaces the previous photo.
abstract interface class ProfilePhotoRepository {
  /// Returns the public URL of the stored photo.
  Future<DataState<String>> upload({required String userId, required LocalImage image});
}
