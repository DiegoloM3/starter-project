import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/get_journalist_stats.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/journalist_stats/journalist_stats_cubit.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/journalist_stats/journalist_stats_state.dart';

import '../../../../../helpers/article_fixtures.dart';
import '../../../../../helpers/fake_journalist_article_repository.dart';

void main() {
  late FakeJournalistArticleRepository repository;
  late JournalistStatsCubit cubit;

  setUp(() {
    repository = FakeJournalistArticleRepository();
    cubit = JournalistStatsCubit(GetJournalistStatsUseCase(repository));
  });

  tearDown(() => cubit.close());

  test('counts every article and adds up the views', () async {
    repository.userArticlesResult = DataSuccess([
      publishableArticle(id: 'a-1').copyWith(viewCount: 1200),
      publishableArticle(id: 'a-2').copyWith(viewCount: 300),
      // Drafts count towards the total: "My articles" lists them, so the
      // number beside it has to include them.
      publishableArticle(id: 'a-3'),
    ]);

    await cubit.loadFor('journalist-1');

    expect(cubit.state.status, JournalistStatsStatus.ready);
    expect(cubit.state.articleCount, 3);
    expect(cubit.state.totalViews, 1500);
    expect(repository.lastUserId, 'journalist-1');
  });

  test('a journalist who has written nothing has nothing to show', () async {
    await cubit.loadFor('journalist-1');

    expect(cubit.state.isReady, isTrue);
    expect(cubit.state.hasArticles, isFalse);
  });

  test('a failure leaves the account usable, without numbers', () async {
    repository.userArticlesResult = const DataFailed(FormatException('boom'));

    await cubit.loadFor('journalist-1');

    expect(cubit.state.status, JournalistStatsStatus.failure);
    expect(cubit.state.hasArticles, isFalse);
  });

  test('forgets the numbers when somebody signs out', () async {
    repository.userArticlesResult = DataSuccess([publishableArticle()]);
    await cubit.loadFor('journalist-1');

    cubit.clear();

    expect(cubit.state.articleCount, 0);
    expect(cubit.state.status, JournalistStatsStatus.initial);
  });
}
