import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/feed.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/search_articles.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockNewsRepository news;
  late MockUserArticleRepository userArticles;
  late SearchArticlesUseCase useCase;

  final remote = buildArticle(id: 'r', publishedAt: DateTime.utc(2026, 9, 1));
  final own = buildUserArticle(id: 'u', publishedAt: DateTime.utc(2026, 9, 2));

  setUp(() {
    news = MockNewsRepository();
    userArticles = MockUserArticleRepository();
    useCase = SearchArticlesUseCase(news, userArticles);
  });

  test('returns an empty feed for a blank query without calling any source', () async {
    final result = await useCase('   ');

    expect(result, const DataSuccess(FeedEntity.empty));
    verifyNever(() => news.searchArticles(any()));
    verifyNever(() => userArticles.searchArticles(any()));
  });

  test('trims the query and searches both sources', () async {
    when(() => news.searchArticles('bikes')).thenAnswer((_) async => DataSuccess([remote]));
    when(() => userArticles.searchArticles('bikes'))
        .thenAnswer((_) async => DataSuccess([own]));

    final result = await useCase('  bikes ');

    expect(result.dataOrNull!.articles, [own, remote]);
  });

  test('keeps own results when the provider search fails', () async {
    when(() => news.searchArticles(any()))
        .thenAnswer((_) async => const DataFailed(Failure.server()));
    when(() => userArticles.searchArticles(any()))
        .thenAnswer((_) async => DataSuccess([own]));

    final result = await useCase('bikes');

    expect(result.dataOrNull!.articles, [own]);
    expect(result.dataOrNull!.isPartial, isTrue);
  });
}
