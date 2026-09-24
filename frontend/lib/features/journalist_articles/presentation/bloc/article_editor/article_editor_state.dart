import 'package:equatable/equatable.dart';

import '../../../domain/entities/article_failures.dart';
import '../../../domain/entities/journalist_article.dart';

enum ArticleEditorStatus {
  editing,
  loading,
  uploadingThumbnail,
  saving,

  /// Saved because the journalist asked for it. The editor closes on this.
  saved,

  /// Made public. A separate state from [saved] because it leads somewhere
  /// else: publishing is worth an acknowledgement, saving a draft is not.
  published,

  /// Saved on its own after the journalist stopped typing. Deliberately a
  /// different state from [saved]: the editor must stay open, or autosaving
  /// would throw the person out of the article every few seconds.
  autosaved,
  failure,
}

/// UI state of the article editor: the article being written, the rules it is
/// currently breaking and what the screen is busy with.
class ArticleEditorState extends Equatable {
  final ArticleEditorStatus status;
  final JournalistArticleEntity article;

  /// The article as it was last written to the backend, or null while it has
  /// never been saved. It is what [hasUnsavedChanges] compares against.
  final JournalistArticleEntity? savedArticle;

  final List<ArticleValidationError> validationErrors;
  final Object? error;

  /// Whether a save is in flight right now.
  ///
  /// It is tracked apart from [status] because typing does not stop a save:
  /// a keystroke moves the status back to `editing`, and reading busyness off
  /// the status alone therefore re-enabled Save and Publish in the middle of
  /// a write. Pressing Save then started a second one, and a brand new
  /// article was created twice.
  final bool isSaving;

  const ArticleEditorState({
    this.status = ArticleEditorStatus.editing,
    this.article = const JournalistArticleEntity(),
    this.savedArticle,
    this.validationErrors = const [],
    this.error,
    this.isSaving = false,
  });

  bool get isBusy =>
      isSaving ||
      status == ArticleEditorStatus.loading ||
      status == ArticleEditorStatus.saving ||
      status == ArticleEditorStatus.uploadingThumbnail;

  /// Whether publishing is still something this article can be asked to do.
  ///
  /// An article that is already out cannot be published again: "Save changes"
  /// already stores the edits and leaves it public, so a second button that
  /// looks like it does more only invites a pointless round trip through the
  /// "published!" screen.
  bool get canPublish => !article.isPublished;

  bool get isEditingStoredArticle => article.isStored;

  bool get hasThumbnail => article.thumbnailUrl.isNotEmpty;

  /// Whether leaving now would lose something.
  ///
  /// Autosave covers drafts once they have a title, but not an article being
  /// written before it is named, and not a published one — where saving
  /// silently would change what readers already have. Both of those are
  /// exactly when somebody can walk away from work they meant to keep.
  bool get hasUnsavedChanges {
    final saved = savedArticle;

    if (saved == null) {
      // Nothing has been written yet, so there is nothing to lose.
      return article.title.isNotEmpty ||
          article.description.isNotEmpty ||
          article.content.isNotEmpty ||
          article.thumbnailUrl.isNotEmpty;
    }

    return article.title != saved.title ||
        article.description != saved.description ||
        article.content != saved.content ||
        article.thumbnailUrl != saved.thumbnailUrl;
  }

  ArticleEditorState copyWith({
    ArticleEditorStatus? status,
    JournalistArticleEntity? article,
    JournalistArticleEntity? savedArticle,
    List<ArticleValidationError>? validationErrors,
    Object? error,
    bool clearError = false,
    bool? isSaving,
  }) {
    return ArticleEditorState(
      status: status ?? this.status,
      article: article ?? this.article,
      savedArticle: savedArticle ?? this.savedArticle,
      validationErrors: validationErrors ?? this.validationErrors,
      error: clearError ? null : (error ?? this.error),
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  List<Object?> get props => [
        status,
        article,
        savedArticle,
        validationErrors,
        error,
        isSaving,
      ];
}
