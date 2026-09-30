import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../../models/article_thumbnail.dart';
import 'image_metadata_remover.dart';

class GalleryImageDataSource {
  // Downscaled on the device: plenty for a full-width thumbnail and keeps uploads well under 5 MB.
  static const double _maxDimensionInPixels = 1920;
  static const int _jpegQuality = 85;

  final ImagePicker _imagePicker;

  GalleryImageDataSource(this._imagePicker);

  /// Returns a copy of the chosen photo without private metadata, or `null` when the journalist
  /// closes the gallery. Throws a PlatformException when the gallery cannot be opened, and a
  /// FormatException when the image is invalid (its metadata could not be removed).
  Future<ArticleThumbnailModel?> pickImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: _maxDimensionInPixels,
      maxHeight: _maxDimensionInPixels,
      imageQuality: _jpegQuality,
      // Avoids asking for full photo library access. It does NOT remove EXIF (iOS still returns
      // the GPS location), hence _copyWithoutMetadata.
      requestFullMetadata: false,
    );
    if (picked == null) return null;
    final image = await _copyWithoutMetadata(picked);
    return ArticleThumbnailModel.fromRawData(localPath: image.path, sizeInBytes: await image.length());
  }

  /// Thumbnails are public: never publish where, when or with which camera a photo was taken.
  /// The copy is written next to image_picker's own temporary file; the picked file is not modified.
  Future<File> _copyWithoutMetadata(XFile picked) async {
    final bytes = ImageMetadataRemover.removeMetadata(await picked.readAsBytes());
    final copy = File('${File(picked.path).parent.path}/without-metadata-${picked.name}');
    return copy.writeAsBytes(bytes, flush: true);
  }
}
