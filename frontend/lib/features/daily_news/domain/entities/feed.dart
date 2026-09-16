import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

/// Articles from both sources combined into one timeline.
///
/// A feed can be *partial*: when one source fails and the other succeeds the
/// reader still gets content, and the failure is kept so the UI can say so.
class FeedEntity extends Equatable {
  /// Newest first, without duplicates.
  final List<ArticleEntity> articles;

  /// Set when the news provider could not be reached.
  final Failure? remoteFailure;

  /// Set when our own backend could not be reached.
  final Failure? userFailure;

  const FeedEntity({
    required this.articles,
    this.remoteFailure,
    this.userFailure,
  });

  static const FeedEntity empty = FeedEntity(articles: []);

  bool get isPartial => remoteFailure != null || userFailure != null;

  bool get isEmpty => articles.isEmpty;

  /// Combines the outcome of both sources.
  ///
  /// Fails only when *both* sources failed; the remote failure is reported
  /// because the provider is the primary source of content.
  static DataState<FeedEntity> merge({
    required DataState<List<ArticleEntity>> remote,
    required DataState<List<ArticleEntity>> user,
  }) {
    if (remote is DataFailed<List<ArticleEntity>> &&
        user is DataFailed<List<ArticleEntity>>) {
      return DataFailed(remote.failure);
    }

    final articles = sortNewestFirst([
      ...?remote.dataOrNull,
      ...?user.dataOrNull,
    ]);

    return DataSuccess(
      FeedEntity(
        articles: articles,
        remoteFailure: remote.failureOrNull,
        userFailure: user.failureOrNull,
      ),
    );
  }

  /// Orders by publication date, newest first, dropping repeated ids.
  static List<ArticleEntity> sortNewestFirst(Iterable<ArticleEntity> source) {
    final seen = <String>{};
    final unique = source.where((article) => seen.add(article.id)).toList();
    unique.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return unique;
  }

  @override
  List<Object?> get props => [articles, remoteFailure, userFailure];
}
