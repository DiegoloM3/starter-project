import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_topic.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/topic_trend.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/get_trending_topics.dart';

import 'article_test_data.dart';

ArticleEntity articleAbout(List<ArticleTopic> topics, {required String id, required DateTime publishedAt}) {
  return ArticleEntity(
    id: id,
    title: testArticle.title,
    description: testArticle.description,
    content: testArticle.content,
    thumbnailURL: testArticle.thumbnailURL,
    topics: topics,
    publishedAt: publishedAt,
    authorId: testArticle.authorId,
    authorName: testArticle.authorName,
  );
}

void main() {
  final now = DateTime(2026, 10, 18, 12);
  late MockArticleRepository repository;
  late GetTrendingTopicsUseCase getTrendingTopics;

  setUpAll(() => registerFallbackValue(DateTime(2000)));

  setUp(() {
    repository = MockArticleRepository();
    getTrendingTopics = GetTrendingTopicsUseCase(repository, now: () => now);
  });

  test('asks for the articles of the last week', () async {
    when(() => repository.getArticlesPublishedSince(any())).thenAnswer((_) async => const DataSuccess([]));

    await getTrendingTopics(const NoParams());

    verify(() => repository.getArticlesPublishedSince(now.subtract(TrendLimits.period))).called(1);
  });

  test('ranks the topics by their number of articles', () async {
    final sports = articleAbout([ArticleTopic.sports], id: 'a', publishedAt: now);
    final sportsAndHealth = articleAbout([ArticleTopic.sports, ArticleTopic.health], id: 'b', publishedAt: now);
    final technology = articleAbout([ArticleTopic.technology], id: 'c', publishedAt: now);
    when(
      () => repository.getArticlesPublishedSince(any()),
    ).thenAnswer((_) async => DataSuccess([sports, sportsAndHealth, technology]));

    final result = await getTrendingTopics(const NoParams());

    expect(result.data!.first, TopicTrend(topic: ArticleTopic.sports, articles: [sports, sportsAndHealth]));
    expect(result.data!.map((trend) => trend.topic), contains(ArticleTopic.health));
    expect(result.data!.length, 3);
  });

  test('breaks ties with the topic of the most recent article', () async {
    final olderTechnology = articleAbout(
      [ArticleTopic.technology],
      id: 'a',
      publishedAt: now.subtract(const Duration(days: 2)),
    );
    final newerScience = articleAbout([ArticleTopic.science], id: 'b', publishedAt: now);
    when(
      () => repository.getArticlesPublishedSince(any()),
    ).thenAnswer((_) async => DataSuccess([newerScience, olderTechnology]));

    final result = await getTrendingTopics(const NoParams());

    expect(result.data!.map((trend) => trend.topic), [ArticleTopic.science, ArticleTopic.technology]);
  });

  test('fails with the error of the repository', () async {
    final error = Exception('offline');
    when(() => repository.getArticlesPublishedSince(any())).thenAnswer((_) async => DataFailed(error));

    final result = await getTrendingTopics(const NoParams());

    expect(result.error, error);
  });
}
