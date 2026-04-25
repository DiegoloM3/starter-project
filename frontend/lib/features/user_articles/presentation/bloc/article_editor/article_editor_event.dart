import 'package:freezed_annotation/freezed_annotation.dart';

part 'article_editor_event.freezed.dart';

@freezed
class ArticleEditorEvent with _$ArticleEditorEvent {
  const factory ArticleEditorEvent.titleChanged(String value) =
      ArticleEditorTitleChanged;
  const factory ArticleEditorEvent.descriptionChanged(String value) =
      ArticleEditorDescriptionChanged;
  const factory ArticleEditorEvent.contentChanged(String value) =
      ArticleEditorContentChanged;
  const factory ArticleEditorEvent.tagsChanged(List<String> tags) =
      ArticleEditorTagsChanged;
  const factory ArticleEditorEvent.thumbnailPicked({
    required String fileName,
    required List<int> bytes,
    required String contentType,
  }) = ArticleEditorThumbnailPicked;
  const factory ArticleEditorEvent.submitted() = ArticleEditorSubmitted;
}
