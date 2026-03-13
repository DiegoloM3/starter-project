import 'package:equatable/equatable.dart';
import '../../../features/daily_news/domain/entities/article.dart';
import '../../../features/user_articles/domain/entities/user_article.dart';

/// Represents a unified feed item that can be either a NewsAPI article
/// or a user-created article.
enum FeedItemType { newsApi, userArticle }

class FeedItem extends Equatable {
  final FeedItemType type;
  final ArticleEntity? newsArticle;
  final UserArticleEntity? userArticle;

  const FeedItem._({
    required this.type,
    this.newsArticle,
    this.userArticle,
  });

  /// Creates a FeedItem from a NewsAPI article
  factory FeedItem.fromNewsArticle(ArticleEntity article) {
    return FeedItem._(
      type: FeedItemType.newsApi,
      newsArticle: article,
    );
  }

  /// Creates a FeedItem from a user-created article
  factory FeedItem.fromUserArticle(UserArticleEntity article) {
    return FeedItem._(
      type: FeedItemType.userArticle,
      userArticle: article,
    );
  }

  /// Common accessors for display
  String get title {
    switch (type) {
      case FeedItemType.newsApi:
        return newsArticle?.title ?? '';
      case FeedItemType.userArticle:
        return userArticle?.title ?? '';
    }
  }

  String get description {
    switch (type) {
      case FeedItemType.newsApi:
        return newsArticle?.description ?? '';
      case FeedItemType.userArticle:
        return userArticle?.description ?? '';
    }
  }

  String? get imageUrl {
    switch (type) {
      case FeedItemType.newsApi:
        return newsArticle?.urlToImage;
      case FeedItemType.userArticle:
        return userArticle?.thumbnailUrl;
    }
  }

  String get authorName {
    switch (type) {
      case FeedItemType.newsApi:
        return newsArticle?.author ?? 'Unknown';
      case FeedItemType.userArticle:
        return userArticle?.authorName ?? 'Unknown';
    }
  }

  DateTime? get publishedDate {
    switch (type) {
      case FeedItemType.newsApi:
        if (newsArticle?.publishedAt != null) {
          return DateTime.tryParse(newsArticle!.publishedAt!);
        }
        return null;
      case FeedItemType.userArticle:
        return userArticle?.publishedAt;
    }
  }

  String get source {
    switch (type) {
      case FeedItemType.newsApi:
        return 'News'; // Could extract from URL
      case FeedItemType.userArticle:
        return 'Community';
    }
  }

  bool get isFromNewsApi => type == FeedItemType.newsApi;
  bool get isUserArticle => type == FeedItemType.userArticle;

  @override
  List<Object?> get props => [type, newsArticle, userArticle];
}
