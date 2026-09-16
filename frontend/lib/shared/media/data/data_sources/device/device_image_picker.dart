// coverage:ignore-file
// Thin wrapper over the platform image picker plugin.
// Covered by the repository tests above it, with the SDK mocked at this seam.
import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/shared/media/data/models/local_image_model.dart';

/// Talks to the platform photo library through `image_picker`.
class DeviceImagePicker {
  final ImagePicker _picker;

  DeviceImagePicker(this._picker);

  /// `null` when the user closed the picker without choosing.
  Future<LocalImageModel?> pickImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (file == null) return null;
    return LocalImageModel.fromRawData(
      path: file.path,
      mimeType: file.mimeType,
      sizeInBytes: await file.length(),
    );
  }
}
