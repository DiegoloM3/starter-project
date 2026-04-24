import 'package:freezed_annotation/freezed_annotation.dart';

part 'publish_article_params.freezed.dart';

@freezed
class PublishArticleParams with _$PublishArticleParams {
  const factory PublishArticleParams({
    required String id,
    required String authorId,
    required String authorName,
    required String title,
    required String description,
    required String content,
    required String thumbnailURL,
    @Default(<String>[]) List<String> tags,
  }) = _PublishArticleParams;
}
