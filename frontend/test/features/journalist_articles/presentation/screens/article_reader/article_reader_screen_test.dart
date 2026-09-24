import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/get_published_articles.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/increment_article_view_count.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/article_feed/article_feed_cubit.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/article_reader/article_reader_cubit.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/screens/article_reader/article_reader_screen.dart';

import '../../../../../helpers/article_fixtures.dart';
import '../../../../../helpers/fake_journalist_article_repository.dart';
import '../../../../../helpers/localized_app.dart';

void main() {
  late FakeJournalistArticleRepository repository;
  late ArticleReaderCubit readerCubit;
  late ArticleFeedCubit moreFromAuthorCubit;

  final article = publishableArticle(id: 'a-1').copyWith(
    author: 'Marcus Aurelius',
    viewCount: 41,
  );

  setUp(() {
    repository = FakeJournalistArticleRepository();
    readerCubit = ArticleReaderCubit(
      IncrementArticleViewCountUseCase(repository),
      article: article,
    );
    moreFromAuthorCubit = ArticleFeedCubit(
      GetPublishedArticlesUseCase(repository),
      authorId: article.userId,
      excludeArticleId: article.id,
      onlyRecent: false,
    );
  });

  tearDown(() async {
    await readerCubit.close();
    await moreFromAuthorCubit.close();
  });

  Future<void> pumpScreen(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: testLocalizationDelegates,
        supportedLocales: testSupportedLocales,
        home: MultiBlocProvider(
          providers: [
            BlocProvider<ArticleReaderCubit>.value(value: readerCubit),
            BlocProvider<ArticleFeedCubit>.value(value: moreFromAuthorCubit),
          ],
          child: const ArticleReaderScreen(),
        ),
      ),
    );
  }

  testWidgets('shows the article and who wrote it', (tester) async {
    await pumpScreen(tester);

    expect(find.text(article.title), findsOneWidget);
    expect(find.text('Marcus Aurelius'), findsOneWidget);
    expect(find.text(article.content), findsOneWidget);
  });

  testWidgets('counts the reading and shows it straight away', (tester) async {
    await pumpScreen(tester);

    await readerCubit.recordView();
    await tester.pump();

    expect(repository.incrementViewCountCallCount, 1);
    expect(repository.lastViewedArticleId, 'a-1');
    expect(find.text('42 views'), findsOneWidget);
  });

  testWidgets('counts one reading however often the screen rebuilds',
      (tester) async {
    await pumpScreen(tester);

    await readerCubit.recordView();
    await readerCubit.recordView();
    await tester.pump();

    expect(repository.incrementViewCountCallCount, 1);
    expect(find.text('42 views'), findsOneWidget);
  });

  testWidgets("offers the author's other work under the article",
      (tester) async {
    repository.publishedArticlesResult = DataSuccess([
      publishableArticle(id: 'a-2').copyWith(title: 'My Stoic Dawn Routines'),
    ]);

    await pumpScreen(tester);
    await moreFromAuthorCubit.loadFeed();
    await tester.pump();

    // First name only: "More from Marcus" reads like a person.
    expect(find.text('More from Marcus'), findsOneWidget);
    expect(find.text('My Stoic Dawn Routines'), findsOneWidget);
  });

  testWidgets('hides that section when the author has nothing else',
      (tester) async {
    await pumpScreen(tester);
    await moreFromAuthorCubit.loadFeed();
    await tester.pump();

    expect(find.textContaining('More from'), findsNothing);
  });

  testWidgets('a reading with no stored article is never counted',
      (tester) async {
    final unsavedCubit = ArticleReaderCubit(
      IncrementArticleViewCountUseCase(repository),
      article: const JournalistArticleEntity(title: 'Never stored'),
    );

    await unsavedCubit.recordView();

    expect(repository.incrementViewCountCallCount, 0);

    await unsavedCubit.close();
  });
}
