import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/feed.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/news_query.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_feed.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockNewsRepository news;
  late MockUserArticleRepository userArticles;
  late GetFeedUseCase useCase;

  const query = NewsQuery(category: NewsCategory.technology);
  final remote = buildArticle(id: 'r', publishedAt: DateTime.utc(2026, 9, 1));
  final own = buildUserArticle(id: 'u', publishedAt: DateTime.utc(2026, 9, 2));

  setUp(() {
    news = MockNewsRepository();
    userArticles = MockUserArticleRepository();
    useCase = GetFeedUseCase(news, userArticles);
  });

  test('passes the query to the provider and merges both sources', () async {
    when(() => news.getTopHeadlines(query)).thenAnswer((_) async => DataSuccess([remote]));
    when(() => userArticles.getArticles()).thenAnswer((_) async => DataSuccess([own]));

    final result = await useCase(query);

    expect(result.dataOrNull!.articles, [own, remote]);
    verify(() => news.getTopHeadlines(query)).called(1);
    verify(() => userArticles.getArticles()).called(1);
  });

  test('returns a partial feed when only the provider fails', () async {
    when(() => news.getTopHeadlines(query))
        .thenAnswer((_) async => const DataFailed(Failure.network()));
    when(() => userArticles.getArticles()).thenAnswer((_) async => DataSuccess([own]));

    final result = await useCase(query);

    expect(result.dataOrNull!.articles, [own]);
    expect(result.dataOrNull!.remoteFailure?.type, FailureType.network);
  });

  test('fails when both sources fail', () async {
    when(() => news.getTopHeadlines(query))
        .thenAnswer((_) async => const DataFailed(Failure.server()));
    when(() => userArticles.getArticles())
        .thenAnswer((_) async => const DataFailed(Failure.permissionDenied()));

    final result = await useCase(query);

    expect(result, isA<DataFailed<FeedEntity>>());
    expect(result.failureOrNull?.type, FailureType.server);
  });
}
