import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/core/resources/network_failure.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../domain/entities/article_failures.dart';

/// Turns a failure produced by the business layer into words a journalist can
/// act on.
///
/// The domain reports failures as values (enums and exceptions) and leaves the
/// wording — and now the language — to the presentation layer.
class ArticleFailureText extends StatelessWidget {
  final Object? failure;

  const ArticleFailureText(this.failure, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      messageFor(AppLocalizations.of(context), failure),
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    );
  }

  static String messageFor(AppLocalizations l10n, Object? failure) {
    if (failure is ArticleValidationException) {
      return failure.errors
          .map((error) => messageForValidationError(l10n, error))
          .join('\n');
    }
    if (failure is ThumbnailValidationException) {
      return failure.errors
          .map((error) => messageForThumbnailError(l10n, error))
          .join('\n');
    }
    if (failure is ArticleNotFoundException) {
      return l10n.errorArticleNotFound;
    }
    if (failure is ArticleNotStoredException) {
      return l10n.errorArticleNotStored;
    }
    if (failure is NetworkUnavailableException) {
      return l10n.errorNoConnection;
    }

    return l10n.errorGeneric;
  }

  static String messageForValidationError(
    AppLocalizations l10n,
    ArticleValidationError error,
  ) {
    switch (error) {
      case ArticleValidationError.titleRequired:
        return l10n.errorTitleRequired;
      case ArticleValidationError.titleTooLong:
        return l10n.errorTitleTooLong;
      case ArticleValidationError.descriptionRequired:
        return l10n.errorDescriptionRequired;
      case ArticleValidationError.descriptionTooLong:
        return l10n.errorDescriptionTooLong;
      case ArticleValidationError.contentRequired:
        return l10n.errorContentRequired;
      case ArticleValidationError.thumbnailRequired:
        return l10n.errorThumbnailRequired;
      case ArticleValidationError.authorRequired:
        return l10n.errorAuthorRequired;
      case ArticleValidationError.userRequired:
        return l10n.errorOwnerRequired;
    }
  }

  static String messageForThumbnailError(
    AppLocalizations l10n,
    ThumbnailValidationError error,
  ) {
    switch (error) {
      case ThumbnailValidationError.emptyFile:
        return l10n.errorImageEmpty;
      case ThumbnailValidationError.fileTooLarge:
        return l10n.errorImageTooLarge;
      case ThumbnailValidationError.unsupportedFormat:
        return l10n.errorImageFormat;
    }
  }
}
