import 'dart:typed_data';

import 'article_draft.dart';

/// An image picked by the journalist, as raw bytes so the domain does not depend on Flutter files.
class ArticleImage {
  final Uint8List bytes;

  const ArticleImage(this.bytes);

  Set<ArticleValidationError> get validationErrors => {
        if (bytes.isEmpty) ArticleValidationError.imageEmpty,
        if (bytes.length >= ArticleLimits.imageMaxBytes) ArticleValidationError.imageTooLarge,
      };
}
