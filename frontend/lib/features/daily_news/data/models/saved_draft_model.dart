import 'package:news_app_clean_architecture/shared/media/domain/entities/local_image.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/saved_draft.dart';

/// The draft as stored on the device, one JSON document.
class SavedDraftModel extends SavedDraft {
  const SavedDraftModel({
    super.title,
    super.description,
    super.content,
    super.category,
    super.image,
  });

  /// Missing or malformed fields fall back to empty, so a document written
  /// by an older build still restores whatever it can.
  factory SavedDraftModel.fromJson(Map<String, dynamic> json) {
    return SavedDraftModel(
      title: _string(json['title']),
      description: _string(json['description']),
      content: _string(json['content']),
      category: NewsCategory.fromApiValue(json['category'] as String?),
      image: _image(json['image']),
    );
  }

  factory SavedDraftModel.fromEntity(SavedDraft draft) => SavedDraftModel(
        title: draft.title,
        description: draft.description,
        content: draft.content,
        category: draft.category,
        image: draft.image,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'content': content,
        'category': category.apiValue,
        if (image case final image?)
          'image': {
            'path': image.path,
            'mimeType': image.mimeType,
            'sizeInBytes': image.sizeInBytes,
          },
      };

  SavedDraft toEntity() => SavedDraft(
        title: title,
        description: description,
        content: content,
        category: category,
        image: image,
      );

  static String _string(Object? value) => value is String ? value : '';

  static LocalImage? _image(Object? value) {
    if (value is! Map) return null;
    final path = value['path'];
    final mimeType = value['mimeType'];
    final size = value['sizeInBytes'];
    if (path is! String || path.isEmpty || mimeType is! String || size is! int) return null;
    return LocalImage(path: path, mimeType: mimeType, sizeInBytes: size);
  }
}
