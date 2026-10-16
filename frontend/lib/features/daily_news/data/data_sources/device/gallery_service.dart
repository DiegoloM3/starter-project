import 'package:image_picker/image_picker.dart';

class GalleryService {
  static const double maxImageWidth = 1600;
  static const int imageQuality = 85;

  final ImagePicker _imagePicker;

  GalleryService(this._imagePicker);

  /// Opens the gallery (photos only) and returns the local path of the picked
  /// image, or `null` when the user closes it without picking one.
  Future<String?> pickImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: maxImageWidth,
      imageQuality: imageQuality,
    );
    return image?.path;
  }
}
