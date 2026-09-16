import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/shared/media/domain/entities/local_image.dart';

/// Access to the device's photo library.
abstract interface class ImagePickerRepository {
  /// Lets the user choose one image. Resolves to `null` when they dismiss
  /// the picker without choosing.
  Future<DataState<LocalImage?>> pickFromGallery();
}
