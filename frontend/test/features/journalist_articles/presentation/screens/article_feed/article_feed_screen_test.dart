import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/get_published_articles.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/article_feed/article_feed_cubit.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/screens/article_feed/article_feed_screen.dart';

import '../../../../../helpers/article_fixtures.dart';
import '../../../../../helpers/fake_journalist_article_repository.dart';
import '../../../../../helpers/localized_app.dart';

void main() {
  late FakeJournalistArticleRepository repository;
  late ArticleFeedCubit cubit;

  setUp(() {
    repository = FakeJournalistArticleRepository();
    cubit = ArticleFeedCubit(GetPublishedArticlesUseCase(repository));
  });

  tearDown(() => cubit.close());

  Future<void> pumpScreen(WidgetTester tester,
      {String title = 'Community Articles'}) {
    return tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: testLocalizationDelegates,
        supportedLocales: testSupportedLocales,
        home: BlocProvider<ArticleFeedCubit>.value(
          value: cubit,
          child: ArticleFeedScreen(titleOverride: title),
        ),
      ),
    );
  }

  testWidgets('lists published articles once loaded', (tester) async {
    repository.publishedArticlesResult = DataSuccess([publishableArticle()]);

    await pumpScreen(tester);
    await cubit.loadFeed();
    await tester.pump();

    expect(find.text(publishableArticle().title), findsOneWidget);
    expect(find.text('By ${publishableArticle().author}'), findsOneWidget);
  });

  testWidgets(
      'an empty community feed says the week was quiet, not that the '
      'app is empty', (tester) async {
    await pumpScreen(tester);
    await cubit.loadFeed();
    await tester.pump();

    expect(find.text('Nothing new this week'), findsOneWidget);
    expect(find.textContaining('last 7 days'), findsOneWidget);
  });

  testWidgets("an empty author feed says that author has published nothing",
      (tester) async {
    final authorCubit = ArticleFeedCubit(
      GetPublishedArticlesUseCase(repository),
      authorId: 'journalist-1',
      onlyRecent: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: testLocalizationDelegates,
        supportedLocales: testSupportedLocales,
        home: BlocProvider<ArticleFeedCubit>.value(
          value: authorCubit,
          child: const ArticleFeedScreen(),
        ),
      ),
    );
    await authorCubit.loadFeed();
    await tester.pump();

    expect(find.text('No articles yet'), findsOneWidget);

    await authorCubit.close();
  });

  testWidgets(
      'renders the given title, used to tell the feed and an author '
      'profile apart', (tester) async {
    await pumpScreen(tester, title: 'More from Alex Rivera');
    await cubit.loadFeed();
    await tester.pump();

    expect(find.text('More from Alex Rivera'), findsOneWidget);
  });

  testWidgets('offers a load more button while another page may exist',
      (tester) async {
    final pagedCubit = ArticleFeedCubit(
      GetPublishedArticlesUseCase(repository),
      pageSize: 1,
    );
    repository.publishedArticlesResult = DataSuccess([publishableArticle()]);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: testLocalizationDelegates,
        supportedLocales: testSupportedLocales,
        home: BlocProvider<ArticleFeedCubit>.value(
          value: pagedCubit,
          child: const ArticleFeedScreen(),
        ),
      ),
    );
    await pagedCubit.loadFeed();
    await tester.pump();

    expect(
      find.widgetWithText(OutlinedButton, 'Load more articles'),
      findsOneWidget,
    );

    await pagedCubit.close();
  });
}
