import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/config/routes/app_routes.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/feed.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/home_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/reader_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/my_articles/delete_article_dialog.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/reader/reader_lens_body.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';
import 'package:news_app_clean_architecture/shared/presentation/formatters/failure_message_formatter.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/labels/you_badge.dart';

import '../../../../helpers/feed_harness.dart';
import '../../../../helpers/fixtures.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  /// The reader asks the platform for haptics and the system UI; answer silently.
  void mockPlatformChannel() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (_) async => null);
    addTearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
  }

  testWidgets('shows the article, saves it and steps the text size', (tester) async {
    final harness = ShellHarness();
    mockPlatformChannel();
    useScreen(tester, const Size(600, 1400));
    final article = buildUserArticle(authorId: user.id, imageUrl: null).copyWith(
      title: 'Own story',
      content: 'Body text of the story.',
    );
    await tester.pump();
    await pumpApp(tester, ReaderScreen(article: article), providers: harness.providers);
    await tester.pumpAndSettle();

    expect(find.text('Own story'), findsOneWidget);
    expect(find.text('Body text of the story.'), findsOneWidget);
    expect(find.byType(YouBadge), findsOneWidget);
    expect(find.textContaining('(you)'), findsOneWidget);
    expect(find.text('SAVE'), findsOneWidget);

    await tester.tap(find.text('SAVE'));
    await tester.pumpAndSettle();
    expect(find.text('SAVED'), findsOneWidget);
    verify(() => harness.save(article)).called(1);

    await tester.tap(find.text('SAVED'));
    await tester.pumpAndSettle();
    expect(find.text('SAVE'), findsOneWidget);
    verify(() => harness.remove(article.id)).called(1);

    await tester.tap(find.text('A+'));
    await tester.pumpAndSettle();
    expect(harness.settings.cubit.state.settings.textSize, TextSizePreference.large);
    await tester.tap(find.text('A−'));
    await tester.pumpAndSettle();
    expect(harness.settings.cubit.state.settings.textSize, TextSizePreference.medium);
  });

  testWidgets('lenses show bullets, toggle back, and Listen plays the current view', (tester) async {
    final harness = ShellHarness();
    mockPlatformChannel();
    useScreen(tester, const Size(600, 1600));
    final article = buildArticle(imageUrl: null, title: 'Tram strike', content: 'Long original body text.');
    await tester.pump();
    await pumpApp(tester, ReaderScreen(article: article), providers: harness.providers);
    await tester.pumpAndSettle();

    expect(find.text('Long original body text.'), findsOneWidget);

    await tester.tap(find.text('Brief it'));
    await tester.pumpAndSettle();
    expect(find.text('First fact'), findsOneWidget);
    expect(find.textContaining('WRITTEN BY AI'), findsOneWidget);
    expect(find.text('Long original body text.'), findsNothing);

    await tester.tap(find.text('LISTEN'));
    await tester.pumpAndSettle();
    expect(find.text('PAUSE'), findsOneWidget);
    expect(harness.speech.spoken.single, 'Tram strike. First fact. Second fact. Third fact');

    await tester.tap(find.text('Brief it'));
    await tester.pumpAndSettle();
    expect(find.text('Long original body text.'), findsOneWidget);
    expect(find.byType(ReaderLensBody), findsOneWidget);
    verify(() => harness.applyLens(any())).called(1);
  });

  testWidgets('More on an own article edits it, or deletes it after confirming', (tester) async {
    final article = buildUserArticle(authorId: user.id, imageUrl: null).copyWith(title: 'Own story');
    final harness = ShellHarness(feed: FeedEntity(articles: [article]));
    mockPlatformChannel();
    useScreen(tester, const Size(600, 1400));
    await tester.pump();
    final router = await pumpRoutedApp(
      tester,
      initialLocation: AppRoutes.home,
      routes: {
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.reader: (_) => ReaderScreen(article: article),
        AppRoutes.publish: (_) => const Text('publish form'),
      },
      providers: harness.providers,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Own story'));
    await tester.pumpAndSettle();
    expect(find.byType(ReaderScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit article'));
    await tester.pumpAndSettle();
    expect(find.text('publish form'), findsOneWidget);
    router.pop();
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete article'));
    await tester.pumpAndSettle();
    expect(find.byType(DeleteArticleDialog), findsOneWidget);
    await tester.tap(find.text('Keep it'));
    await tester.pumpAndSettle();
    verifyNever(() => harness.deleteArticle(any()));
    expect(find.byType(ReaderScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete article'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete article'));
    await tester.pumpAndSettle();

    verify(() => harness.deleteArticle(article)).called(1);
    expect(find.byType(ReaderScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
    verify(() => harness.getFeed(any())).called(2);
  });

  testWidgets('a delete the server rejects is announced and the reader stays', (tester) async {
    final article = buildUserArticle(authorId: user.id, imageUrl: null).copyWith(title: 'Own story');
    final harness = ShellHarness();
    when(() => harness.deleteArticle(any())).thenAnswer((_) async => const DataFailed(Failure.server()));
    mockPlatformChannel();
    useScreen(tester, const Size(600, 1400));
    await tester.pump();
    await pumpApp(tester, ReaderScreen(article: article), providers: harness.providers);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete article'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete article'));
    await tester.pumpAndSettle();

    expect(find.byType(ReaderScreen), findsOneWidget);
    expect(find.text(FailureMessageFormatter.of(const Failure.server())), findsOneWidget);
  });

  testWidgets('a lens that fails explains itself and keeps the original text', (tester) async {
    final harness = ShellHarness();
    when(() => harness.applyLens(any())).thenAnswer((_) async => const DataFailed(Failure.server()));
    mockPlatformChannel();
    useScreen(tester, const Size(600, 1600));
    final article = buildArticle(imageUrl: null, title: 'Tram strike', content: 'Long original body text.');
    await tester.pump();
    await pumpApp(tester, ReaderScreen(article: article), providers: harness.providers);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Brief it'));
    await tester.pumpAndSettle();

    expect(find.text(FailureMessageFormatter.of(const Failure.server())), findsOneWidget);
    expect(find.text('Long original body text.'), findsOneWidget);
  });
}
