import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

sealed class FeedItem extends Equatable {
  const FeedItem();

  String get id;
  String get title;
  String get thumbnailUrl;
  DateTime get publishedAt;
  String? get authorDisplayName;
  String get sourceLabel;

  @override
  List<Object?> get props => [id, sourceLabel];
}

final class NewsApiFeedItem extends FeedItem {
  final ArticleEntity article;

  const NewsApiFeedItem(this.article);

  @override
  String get id => 'news:${article.id ?? article.url ?? article.title ?? ''}';

  @override
  String get title => article.title ?? '';

  @override
  String get thumbnailUrl => article.urlToImage ?? '';

  @override
  DateTime get publishedAt =>
      DateTime.tryParse(article.publishedAt ?? '') ??
      DateTime.fromMillisecondsSinceEpoch(0);

  @override
  String? get authorDisplayName => article.author;

  @override
  String get sourceLabel => 'News';

  @override
  List<Object?> get props => [id, sourceLabel, article];
}

final class JournalistFeedItem extends FeedItem {
  final JournalistArticleEntity article;

  const JournalistFeedItem(this.article);

  @override
  String get id => 'journalist:${article.id}';

  @override
  String get title => article.title;

  @override
  String get thumbnailUrl => article.urlToImage;

  @override
  DateTime get publishedAt => article.publishedAt;

  @override
  String? get authorDisplayName => article.userDisplayName;

  @override
  String get sourceLabel => 'Community';

  @override
  List<Object?> get props => [id, sourceLabel, article];
}
