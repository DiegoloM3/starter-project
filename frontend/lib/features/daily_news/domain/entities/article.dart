import 'package:equatable/equatable.dart';

class ArticleEntity extends Equatable {
  final int? id;
  final String? author;
  final String? title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final String? publishedAt;
  final String? content;

  const ArticleEntity({
    this.id,
    this.author,
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
  });

  /// Whether this is the same article as [other], ignoring [id].
  ///
  /// `==` cannot answer this: the copy that arrives from the news API has no
  /// id, and the copy in the saved list has one the local database assigned,
  /// so the two are never equal even when they are the same article. What
  /// identifies an article across both is where it was published.
  bool isSameArticleAs(ArticleEntity other) {
    final ownUrl = url;

    return ownUrl != null && ownUrl.isNotEmpty && ownUrl == other.url;
  }

  @override
  List<Object?> get props {
    return [
      id,
      author,
      title,
      description,
      url,
      urlToImage,
      publishedAt,
      content,
    ];
  }
}
