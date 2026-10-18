import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/article.dart';
import '../entities/article_topic.dart';
import '../entities/topic_trend.dart';
import '../repository/article_repository.dart';

class TrendLimits {
  /// Trends count the articles published in the last week.
  static const Duration period = Duration(days: 7);
}

/// Topics ranked by the number of articles published in the last week. Ties go to the topic
/// with the most recent article. An article with several topics counts for each of them.
class GetTrendingTopicsUseCase implements UseCase<DataState<List<TopicTrend>>, NoParams> {
  final ArticleRepository _articleRepository;
  final DateTime Function() _now;

  /// [now] can be replaced in tests to make the period predictable.
  GetTrendingTopicsUseCase(this._articleRepository, {DateTime Function() now = DateTime.now}) : _now = now;

  @override
  Future<DataState<List<TopicTrend>>> call(NoParams params) async {
    final result = await _articleRepository.getArticlesPublishedSince(_now().subtract(TrendLimits.period));
    if (result is DataFailed) return DataFailed(result.error!);
    return DataSuccess(_rank(result.data!));
  }

  List<TopicTrend> _rank(List<ArticleEntity> articles) {
    final newestFirst = [...articles]..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    final articlesByTopic = <ArticleTopic, List<ArticleEntity>>{};
    for (final article in newestFirst) {
      for (final topic in article.topics) {
        articlesByTopic.putIfAbsent(topic, () => []).add(article);
      }
    }
    final trends = [for (final entry in articlesByTopic.entries) TopicTrend(topic: entry.key, articles: entry.value)];
    return trends..sort(_byArticleCountThenRecency);
  }

  int _byArticleCountThenRecency(TopicTrend a, TopicTrend b) {
    final byCount = b.articleCount.compareTo(a.articleCount);
    if (byCount != 0) return byCount;
    return b.articles.first.publishedAt.compareTo(a.articles.first.publishedAt);
  }
}
