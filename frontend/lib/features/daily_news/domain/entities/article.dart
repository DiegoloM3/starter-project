import 'package:freezed_annotation/freezed_annotation.dart';

part 'article.freezed.dart';

/// Immutable domain entity representing a news article.
///
/// Fields stay nullable because NewsAPI frequently omits them and we prefer
/// carrying partial records into the UI over discarding them.
@freezed
class ArticleEntity with _$ArticleEntity {
  const factory ArticleEntity({
    int? id,
    String? author,
    String? title,
    String? description,
    String? url,
    String? urlToImage,
    String? publishedAt,
    String? content,
    String? sourceId,
    String? sourceName,
  }) = _ArticleEntity;

  const ArticleEntity._();

  /// Minimum data we need to show an article in a list/card.
  bool get isValidForDisplay => title?.isNotEmpty ?? false;
}
