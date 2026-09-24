import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/journalist_stats.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/params/get_my_articles_params.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/get_journalist_stats.dart';

import '../../../../helpers/article_fixtures.dart';
import '../../../../helpers/fake_journalist_article_repository.dart';

void main() {
  late FakeJournalistArticleRepository repository;
  late GetJournalistStatsUseCase useCase;

  setUp(() {
    repository = FakeJournalistArticleRepository();
    useCase = GetJournalistStatsUseCase(repository);
  });

  test('summarises the articles of the journalist it was asked about',
      () async {
    repository.userArticlesResult = DataSuccess([
      publishableArticle(id: 'a-1').copyWith(viewCount: 7),
    ]);

    final result = await useCase(
      const GetMyArticlesParams(userId: 'journalist-1'),
    );

    expect(result, isA<DataSuccess<JournalistStatsEntity>>());
    expect(result.data!.articleCount, 1);
    expect(result.data!.totalViews, 7);
    expect(repository.lastUserId, 'journalist-1');
  });

  /// The summary covers everything a journalist has written, so it must not
  /// inherit the status filter "My articles" offers.
  test('asks for every article, not a filtered subset', () async {
    await useCase(const GetMyArticlesParams(userId: 'journalist-1'));

    expect(repository.lastStatusFilter, isNull);
  });

  test('passes a failure along instead of reporting zero articles', () async {
    repository.userArticlesResult = DataFailed(Exception('offline'));

    final result = await useCase(
      const GetMyArticlesParams(userId: 'journalist-1'),
    );

    expect(result, isA<DataFailed>());
  });
}
