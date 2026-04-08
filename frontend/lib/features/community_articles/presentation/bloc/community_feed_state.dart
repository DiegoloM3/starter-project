import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class CommunityFeedState {
  const CommunityFeedState();
}

class CommunityFeedLoading extends CommunityFeedState {
  const CommunityFeedLoading();
}

class CommunityFeedLoaded extends CommunityFeedState {
  final List<ArticleEntity> articles;
  const CommunityFeedLoaded(this.articles);
}

class CommunityFeedError extends CommunityFeedState {
  final String message;
  const CommunityFeedError(this.message);
}
