import '../../../../l10n/l10n.dart';
import '../../domain/entities/article_draft.dart';
import '../../domain/entities/article_thumbnail.dart';

/// User-facing message for each field of the publish form, or `null` when the field is fine.
class ArticleDraftErrorMessages {
  final Set<ArticleDraftError> _errors;
  final AppLocalizations _texts;

  const ArticleDraftErrorMessages(this._errors, this._texts);

  String? get title => _firstOf([ArticleDraftError.titleEmpty, ArticleDraftError.titleTooLong]);

  String? get author => _firstOf([ArticleDraftError.authorEmpty, ArticleDraftError.authorTooLong]);

  String? get content => _firstOf([ArticleDraftError.contentEmpty, ArticleDraftError.contentTooLong]);

  String? get thumbnail => _firstOf([
        ArticleDraftError.thumbnailMissing,
        ArticleDraftError.thumbnailUnsupportedFormat,
        ArticleDraftError.thumbnailTooLarge,
      ]);

  String? _firstOf(List<ArticleDraftError> fieldErrors) {
    for (final error in fieldErrors) {
      if (_errors.contains(error)) return _messageFor(error);
    }
    return null;
  }

  String _messageFor(ArticleDraftError error) {
    return switch (error) {
      ArticleDraftError.titleEmpty => _texts.titleEmpty,
      ArticleDraftError.titleTooLong => _texts.titleTooLong(ArticleDraftEntity.titleMaxLength),
      ArticleDraftError.authorEmpty => _texts.authorEmpty,
      ArticleDraftError.authorTooLong => _texts.authorTooLong(ArticleDraftEntity.authorMaxLength),
      ArticleDraftError.contentEmpty => _texts.contentEmpty,
      ArticleDraftError.contentTooLong => _texts.contentTooLong(ArticleDraftEntity.contentMaxLength),
      ArticleDraftError.thumbnailMissing => _texts.thumbnailMissing,
      ArticleDraftError.thumbnailUnsupportedFormat => _texts.thumbnailUnsupportedFormat,
      ArticleDraftError.thumbnailTooLarge =>
        _texts.thumbnailTooLarge(ArticleThumbnailEntity.maxSizeInBytes ~/ (1024 * 1024)),
    };
  }
}
