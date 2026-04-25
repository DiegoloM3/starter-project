import 'package:freezed_annotation/freezed_annotation.dart';

part 'delete_article_params.freezed.dart';

@freezed
class DeleteArticleParams with _$DeleteArticleParams {
  const factory DeleteArticleParams({required String id}) =
      _DeleteArticleParams;
}
