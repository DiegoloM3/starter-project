import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/feed/feed_state.dart';

sealed class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

final class LoadFeedEvent extends FeedEvent {
  const LoadFeedEvent();
}

final class LoadMoreEvent extends FeedEvent {
  const LoadMoreEvent();
}

final class NewsFeedAppendedEvent extends FeedEvent {
  final List<ArticleEntity> articles;
  const NewsFeedAppendedEvent(this.articles);

  @override
  List<Object?> get props => [articles];
}

final class FitnessFeedAppendedEvent extends FeedEvent {
  final List<ArticleEntity> articles;
  const FitnessFeedAppendedEvent(this.articles);

  @override
  List<Object?> get props => [articles];
}

final class FilterChangedEvent extends FeedEvent {
  final FeedFilter filter;
  const FilterChangedEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}

final class SearchQueryChangedEvent extends FeedEvent {
  final String query;
  const SearchQueryChangedEvent(this.query);

  @override
  List<Object?> get props => [query];
}

final class NewsFeedUpdatedEvent extends FeedEvent {
  final List<ArticleEntity> articles;
  const NewsFeedUpdatedEvent(this.articles);

  @override
  List<Object?> get props => [articles];
}

final class FitnessFeedUpdatedEvent extends FeedEvent {
  final List<ArticleEntity> articles;
  const FitnessFeedUpdatedEvent(this.articles);

  @override
  List<Object?> get props => [articles];
}

final class CommunityFeedUpdatedEvent extends FeedEvent {
  final List<JournalistArticleEntity> articles;
  const CommunityFeedUpdatedEvent(this.articles);

  @override
  List<Object?> get props => [articles];
}

final class CommunityFeedFailedEvent extends FeedEvent {
  final AppException error;
  const CommunityFeedFailedEvent(this.error);

  @override
  List<Object?> get props => [error];
}

final class SearchExecutedEvent extends FeedEvent {
  final String query;
  const SearchExecutedEvent(this.query);

  @override
  List<Object?> get props => [query];
}

final class SearchSucceededEvent extends FeedEvent {
  final List<String> articleIds;
  const SearchSucceededEvent(this.articleIds);

  @override
  List<Object?> get props => [articleIds];
}

final class SearchFailedEvent extends FeedEvent {
  final AppException error;
  const SearchFailedEvent(this.error);

  @override
  List<Object?> get props => [error];
}

final class RecommendationsLoadedEvent extends FeedEvent {
  final List<ArticleEntity> articles;
  const RecommendationsLoadedEvent(this.articles);

  @override
  List<Object?> get props => [articles];
}

final class RecommendationsFailedEvent extends FeedEvent {
  final AppException error;
  const RecommendationsFailedEvent(this.error);

  @override
  List<Object?> get props => [error];
}
