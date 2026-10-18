import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

/// Opens the gallery and returns the chosen image, resized and compressed
/// so it stays far below the upload limit. Null when nothing is chosen.
Future<Uint8List?> pickImageFromGallery() async {
  final image = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1600, imageQuality: 85);
  return image?.readAsBytes();
}
