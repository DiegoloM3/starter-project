import 'package:equatable/equatable.dart';

import '../../../domain/entities/article.dart';
import '../../../domain/params/article_draft.dart';

enum ArticleEditorStatus { editing, submitting, success, failure, imageUploadFailure }

class ArticleEditorState extends Equatable {
  final ArticleEditorStatus status;

  /// Empty on a failure means that something unexpected happened.
  final Set<ArticleValidationError> validationErrors;

  /// The published or updated article, once it succeeds.
  final ArticleEntity? savedArticle;

  final bool isUploadingImage;

  const ArticleEditorState({
    this.status = ArticleEditorStatus.editing,
    this.validationErrors = const {},
    this.savedArticle,
    this.isUploadingImage = false,
  });

  bool get isSubmitting => status == ArticleEditorStatus.submitting;

  @override
  List<Object?> get props => [status, validationErrors, savedArticle, isUploadingImage];
}
