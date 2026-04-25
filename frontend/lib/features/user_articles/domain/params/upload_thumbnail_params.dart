import 'package:freezed_annotation/freezed_annotation.dart';

part 'upload_thumbnail_params.freezed.dart';

/// Upload payload that keeps the domain IO-free: the bytes + content type
/// reach the use case as primitives, so picking a file, taking a photo or
/// downloading one all feed the same pipeline.
@freezed
class UploadThumbnailParams with _$UploadThumbnailParams {
  const factory UploadThumbnailParams({
    required String authorId,
    required String articleId,
    required String fileName,
    required List<int> bytes,
    required String contentType,
  }) = _UploadThumbnailParams;
}
