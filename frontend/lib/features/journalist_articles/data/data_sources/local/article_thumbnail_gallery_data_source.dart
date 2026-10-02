import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/models/article_thumbnail.dart';

abstract class ArticleThumbnailGalleryDataSource {
  /// Opens the gallery to choose a photo. Returns `null` when the gallery is closed without choosing one.
  Future<ArticleThumbnailModel?> pickThumbnail();
}

/// Throws a [PlatformException] when the gallery cannot be opened.
class ArticleThumbnailGalleryDataSourceImpl implements ArticleThumbnailGalleryDataSource {
  // Phone photos are scaled down so they stay well below the 5 MB allowed for a thumbnail.
  static const double _maxImageWidth = 1600;
  static const int _imageQuality = 85;

  final ImagePicker _imagePicker;

  ArticleThumbnailGalleryDataSourceImpl({ImagePicker? imagePicker})
      : _imagePicker = imagePicker ?? ImagePicker();

  @override
  Future<ArticleThumbnailModel?> pickThumbnail() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: _maxImageWidth,
      imageQuality: _imageQuality,
    );
    if (image == null) return null;
    return ArticleThumbnailModel.fromRawData(await image.readAsBytes(), image.name);
  }
}
