import 'package:equatable/equatable.dart';

import '../entities/article_thumbnail.dart';

/// Input of `UploadArticleThumbnailUseCase`: the image and the journalist that
/// owns the folder it is stored in.
class UploadArticleThumbnailParams extends Equatable {
  final String userId;
  final ArticleThumbnailEntity thumbnail;

  const UploadArticleThumbnailParams({
    required this.userId,
    required this.thumbnail,
  });

  @override
  List<Object?> get props => [userId, thumbnail];
}
