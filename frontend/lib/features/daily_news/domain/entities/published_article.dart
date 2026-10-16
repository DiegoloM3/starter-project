import 'article.dart';

/// An article uploaded by a journalist, shown in the feed next to the
/// articles of the news API.
class PublishedArticleEntity extends ArticleEntity {
  static const int maxDescriptionLength = 150;

  PublishedArticleEntity({
    required String title,
    required String content,
    required String thumbnailUrl,
    required DateTime publishedAt,
  }) : super(
          title: title,
          content: content,
          description: describe(content),
          urlToImage: thumbnailUrl,
          publishedAt: formatPublicationDate(publishedAt),
        );

  @override
  bool get isWrittenByJournalist => true;

  /// Formats the date like the news API does (e.g. `2026-10-14T09:30:00Z`),
  /// so both kinds of articles are displayed the same way.
  static String formatPublicationDate(DateTime publishedAt) {
    final isoDate = publishedAt.toUtc().toIso8601String();
    return isoDate.replaceFirst(RegExp(r'\.\d+Z$'), 'Z');
  }

  /// Builds the short description shown under the title in the feed:
  /// the beginning of the content as plain text, cut at a word boundary.
  static String describe(String content) {
    final singleLineContent = ArticleEntity.convertToPlainText(content);
    if (singleLineContent.length <= maxDescriptionLength) {
      return singleLineContent;
    }
    final truncatedContent = singleLineContent.substring(0, maxDescriptionLength);
    final lastSpaceIndex = truncatedContent.lastIndexOf(' ');
    final wordBoundaryContent =
        lastSpaceIndex > 0 ? truncatedContent.substring(0, lastSpaceIndex) : truncatedContent;
    return '$wordBoundaryContent…';
  }
}
