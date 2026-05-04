import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/features/article_upload/data/data_sources/local/image_processing_service.dart';

class ImageProcessingServiceImpl implements ImageProcessingService {
  @override
  Future<XFile?> pickImage({required ImageSource source}) {
    return ImagePicker().pickImage(source: source, imageQuality: 95);
  }

  @override
  Future<CroppedFile?> cropToSixteenNine(String sourcePath) {
    // uiSettings omitted: image_cropper_platform_interface 8.0.0 uses
    // Color.toARGB32() which is unavailable in native dart:ui (web-only),
    // so AndroidUiSettings/IOSUiSettings cannot be constructed without
    // analyzer errors. The aspectRatio param locks the 16:9 ratio natively.
    return ImageCropper().cropImage(
      sourcePath: sourcePath,
      aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
    );
  }

  /// Compress passes lower quality until ≤200KB or 3 attempts.
  @override
  Future<Uint8List> compressForUpload(String filePath) async {
    const target = 200 * 1024;
    const qualities = [85, 75, 65];

    Uint8List? best;
    for (final quality in qualities) {
      final result = await FlutterImageCompress.compressWithFile(
        filePath,
        quality: quality,
        minWidth: 1200,
        format: CompressFormat.jpeg,
      );
      if (result != null) {
        best = result;
        if (result.length <= target) break;
      }
    }
    return best ?? Uint8List(0);
  }
}
