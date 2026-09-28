import 'package:equatable/equatable.dart';

/// Business object for an article, shared by API, cache, and UI.
class ArticleEntity extends Equatable {
  final String? id;
  final String? authorDisplayName;
  final String? title;
  final String? urlToImage;
  final String? publishedAt;
  final String? content;
  final String? authorId;

  const ArticleEntity({
    this.id,
    required this.authorDisplayName,
    required this.title,
    this.urlToImage,
    required this.publishedAt,
    required this.content,
    this.authorId,
  });

  @override
  List<Object?> get props {
    return [
      id,
      authorDisplayName,
      title,
      urlToImage,
      publishedAt,
      content,
      authorId,
    ];
  }

  /// Duplicate identity for saved articles: the stable `id` when both
  /// sides carry one, otherwise the title+date natural key. The natural
  /// key also covers re-fetched API articles, whose `local-` ids are
  /// regenerated on every fetch and never match across sessions.
  bool isSameArticle(ArticleEntity other) {
    if (_hasSameId(other)) return true;
    return _hasSameNaturalKey(other);
  }

  bool _hasSameId(ArticleEntity other) {
    return id != null && id == other.id;
  }

  bool _hasSameNaturalKey(ArticleEntity other) {
    return title != null &&
        publishedAt != null &&
        title == other.title &&
        publishedAt == other.publishedAt;
  }
}
