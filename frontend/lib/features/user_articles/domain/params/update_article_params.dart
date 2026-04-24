import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_article_params.freezed.dart';

@freezed
class UpdateArticleParams with _$UpdateArticleParams {
  const factory UpdateArticleParams({
    required String id,
    required String title,
    required String description,
    required String content,
    required String thumbnailURL,
    @Default(<String>[]) List<String> tags,
  }) = _UpdateArticleParams;
}
