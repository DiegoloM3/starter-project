import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:news_app_clean_architecture/core/error/app_failure.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';

part 'article_editor_state.freezed.dart';

/// Lifecycle of the editor submission — [idle] while the user types,
/// [submitting] during the publish/update round-trip, and terminal
/// [success]/[failure] that the page listens on to pop / show a snackbar.
enum EditorStatus { idle, submitting, success, failure }

@freezed
class ArticleEditorState with _$ArticleEditorState {
  const factory ArticleEditorState({
    required String? editingId,
    required String title,
    required String description,
    required String content,
    required List<String> tags,
    required String thumbnailURL,
    String? pendingFileName,
    List<int>? pendingBytes,
    String? pendingContentType,
    @Default(EditorStatus.idle) EditorStatus status,
    UserArticleEntity? saved,
    AppFailure? failure,
  }) = _ArticleEditorState;

  const ArticleEditorState._();

  factory ArticleEditorState.initial() => const ArticleEditorState(
        editingId: null,
        title: '',
        description: '',
        content: '',
        tags: <String>[],
        thumbnailURL: '',
      );

  factory ArticleEditorState.fromArticle(UserArticleEntity article) =>
      ArticleEditorState(
        editingId: article.id,
        title: article.title,
        description: article.description,
        content: article.content,
        tags: article.tags,
        thumbnailURL: article.thumbnailURL,
      );

  /// Mirrors `UserArticleEntity.canPublish` so the submit button can gate
  /// on the local form before any use case runs.
  bool get canSubmit =>
      title.length >= 5 &&
      content.length >= 50 &&
      thumbnailURL.isNotEmpty &&
      status != EditorStatus.submitting;

  bool get isEditing => editingId != null;
  bool get hasPendingThumbnail => pendingBytes != null;
}
