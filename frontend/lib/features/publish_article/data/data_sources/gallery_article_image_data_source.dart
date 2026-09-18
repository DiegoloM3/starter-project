import 'package:image_picker/image_picker.dart';

import '../../domain/entities/article_thumbnail.dart';
import '../../domain/repository/article_image_picker.dart';

typedef PickGalleryImage = Future<XFile?> Function({
  required ImageSource source,
  required bool requestFullMetadata,
});

class GalleryArticleImagePicker implements ArticleImagePicker {
  final PickGalleryImage _pickImage;

  GalleryArticleImagePicker({PickGalleryImage? pickImage})
      : _pickImage = pickImage ?? ImagePicker().pickImage;

  @override
  Future<ArticleThumbnail?> pickImage() async {
    final file = await _pickImage(
      source: ImageSource.gallery,
      requestFullMetadata: false,
    );
    if (file == null) return null;

    final providedMime = file.mimeType?.trim().toLowerCase();
    final extension = file.name.split('.').last.toLowerCase();
    const mimeByExtension = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'webp': 'image/webp',
    };

    return ArticleThumbnail(
      fileName: file.name,
      mimeType: providedMime != null && providedMime.isNotEmpty
          ? providedMime
          : file.name.contains('.')
              ? mimeByExtension[extension] ?? ''
              : '',
      bytes: await file.readAsBytes(),
    );
  }
}
