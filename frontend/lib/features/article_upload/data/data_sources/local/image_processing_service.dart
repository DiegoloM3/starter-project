import 'dart:typed_data';

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

abstract class ImageProcessingService {
  Future<XFile?> pickImage({required ImageSource source});
  Future<CroppedFile?> cropToSixteenNine(String sourcePath);
  Future<Uint8List> compressForUpload(String filePath);
}
