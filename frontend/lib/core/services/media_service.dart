import 'dart:io';
import 'package:image_picker/image_picker.dart';

enum AppImageSource { camera, gallery }

class MediaService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage(AppImageSource source) async {
    final ImageSource pickerSource = source == AppImageSource.camera
        ? ImageSource.camera
        : ImageSource.gallery;

    try {
      final XFile? image = await _picker.pickImage(
        source: pickerSource,
        imageQuality: 80,
      );

      return image != null ? File(image.path) : null;
    } catch (e) {
      // Log the error or handle it according to your error policy
      return null;
    }
  }
}
