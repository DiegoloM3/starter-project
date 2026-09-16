part of 'publish_cubit.dart';

enum PublishStatus { editing, submitting, success, failure }

/// Why the cubit rewrote the whole form by itself, so the screen can resync
/// its text controllers and say what happened. Cleared by the next change.
enum DraftNotice { restored, cleared }

class PublishState extends Equatable {
  /// Set when editing an existing article.
  final ArticleEntity? original;
  final String title;
  final String description;
  final String content;
  final NewsCategory category;
  final DateTime publishedAt;

  /// A photo picked on the device, not uploaded yet.
  final LocalImage? pickedImage;

  /// True when the user removed the photo the article already had.
  final bool removedExistingImage;
  final PublishStatus status;
  final ArticleValidationError? titleError;
  final ArticleValidationError? descriptionError;
  final ArticleValidationError? contentError;
  final Failure? failure;

  /// The article as the backend returned it after a successful submit.
  final ArticleEntity? result;

  final DraftNotice? draftNotice;

  const PublishState({
    this.original,
    this.title = '',
    this.description = '',
    this.content = '',
    this.category = NewsCategory.general,
    required this.publishedAt,
    this.pickedImage,
    this.removedExistingImage = false,
    this.status = PublishStatus.editing,
    this.titleError,
    this.descriptionError,
    this.contentError,
    this.failure,
    this.result,
    this.draftNotice,
  });

  bool get isEditing => original != null;

  /// Something typed or picked in a new article, worth keeping as a draft.
  bool get hasDraftContent =>
      !isEditing &&
      (title.trim().isNotEmpty ||
          description.trim().isNotEmpty ||
          content.trim().isNotEmpty ||
          pickedImage != null);

  SavedDraft get savedDraft => SavedDraft(
        title: title,
        description: description,
        content: content,
        category: category,
        image: pickedImage,
      );

  bool get isSubmitting => status == PublishStatus.submitting;

  /// The image the preview should show: the picked file, else the current
  /// remote one unless it was removed.
  String? get existingImageUrl =>
      removedExistingImage || pickedImage != null ? null : original?.imageUrl;

  bool get hasPhoto => pickedImage != null || existingImageUrl != null;

  /// Publish is possible once both required texts have content.
  bool get canSubmit => title.trim().isNotEmpty && content.trim().isNotEmpty;

  /// The editor only needs the article text: it is the one who proposes the
  /// headline, so asking for one first would be backwards.
  bool get canAskEditor => content.trim().isNotEmpty;

  /// What is still missing, in the words the helper under the button uses.
  String? get missingHint {
    final missingTitle = title.trim().isEmpty;
    final missingContent = content.trim().isEmpty;
    if (missingTitle && missingContent) return 'Fill in the title and article text to publish.';
    if (missingTitle) return 'Add a title to publish.';
    if (missingContent) return 'Write the article text to publish.';
    return null;
  }

  ArticleDraft get draft => ArticleDraft(
        title: title,
        content: content,
        description: description,
        category: category,
        publishedAt: publishedAt,
      );

  PublishState copyWith({
    String? title,
    String? description,
    String? content,
    NewsCategory? category,
    DateTime? publishedAt,
    LocalImage? pickedImage,
    bool clearPickedImage = false,
    bool? removedExistingImage,
    PublishStatus? status,
    ArticleValidationError? titleError,
    ArticleValidationError? descriptionError,
    ArticleValidationError? contentError,
    Failure? failure,
    ArticleEntity? result,
    DraftNotice? draftNotice,
  }) {
    return PublishState(
      original: original,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      category: category ?? this.category,
      publishedAt: publishedAt ?? this.publishedAt,
      pickedImage: clearPickedImage ? null : (pickedImage ?? this.pickedImage),
      removedExistingImage: removedExistingImage ?? this.removedExistingImage,
      status: status ?? this.status,
      titleError: titleError,
      descriptionError: descriptionError,
      contentError: contentError,
      failure: failure,
      result: result ?? this.result,
      draftNotice: draftNotice,
    );
  }

  @override
  List<Object?> get props => [
        original,
        title,
        description,
        content,
        category,
        publishedAt,
        pickedImage,
        removedExistingImage,
        status,
        titleError,
        descriptionError,
        contentError,
        failure,
        result,
        draftNotice,
      ];
}
