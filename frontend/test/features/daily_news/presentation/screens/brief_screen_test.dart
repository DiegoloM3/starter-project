import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/config/routes/app_routes.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/feed.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/brief_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/home_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/brief/brief_card_stack_step.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/brief/brief_summary_step.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/home/brief_card.dart';

import '../../../../helpers/feed_harness.dart';
import '../../../../helpers/fixtures.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('Home card opens the brief; topics, two cards, summary, then Brief done', (tester) async {
    final stories = [
      buildArticle(id: 'a', imageUrl: null, title: 'First story'),
      buildArticle(id: 'b', imageUrl: null, title: 'Second story'),
    ];
    final harness = ShellHarness(feed: FeedEntity(articles: stories));
    useScreen(tester, const Size(600, 1400));
    await tester.pump();
    await pumpRoutedApp(
      tester,
      initialLocation: AppRoutes.home,
      routes: {
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.brief: (_) => const BriefScreen(),
        AppRoutes.reader: (_) => const Text('reader'),
      },
      providers: harness.providers,
    );
    await tester.pumpAndSettle();

    expect(find.text("TODAY'S BRIEF"), findsOneWidget);
    await tester.tap(find.text('Start reading →'));
    await tester.pumpAndSettle();

    expect(find.text('WHAT DO YOU WANT TO READ TODAY?'), findsOneWidget);
    expect(find.text('Pick a topic to start'), findsOneWidget);
    await tester.tap(find.text('HEALTH'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start with 1 topic'));
    await tester.pumpAndSettle();

    verify(() => harness.getTopHeadlines(any())).called(1);
    expect(find.byType(BriefCardStackStep), findsOneWidget);
    expect(find.text('First story'), findsOneWidget);

    await tester.tap(find.text('Save').first);
    await tester.pumpAndSettle();
    verify(() => harness.save(stories.first)).called(1);

    await tester.tap(find.text('Swipe up for the next story'));
    await tester.pumpAndSettle();
    expect(harness.briefCubit.state.index, 1);
    await tester.tap(find.text('Finish the brief'));
    await tester.pumpAndSettle();

    expect(find.byType(BriefSummaryStep), findsOneWidget);
    expect(find.textContaining("THAT'S YOUR BRIEF, ADA"), findsOneWidget);
    expect(find.text('2 STORIES · 2 MIN · 1 SAVED FOR LATER'), findsOneWidget);

    await tester.tap(find.text('Back to feed'));
    await tester.pumpAndSettle();
    expect(find.byType(BriefCard), findsOneWidget);
    expect(find.text('BRIEF DONE'), findsOneWidget);
  });

  testWidgets('a brief that fails offers other topics; Listen, Read and Open Saved work from the cards',
      (tester) async {
    final stories = [buildArticle(id: 'a', imageUrl: null, title: 'First story')];
    final harness = ShellHarness(feed: FeedEntity(articles: stories));
    when(() => harness.getTopHeadlines(any())).thenAnswer((_) async => const DataFailed(Failure.server()));
    useScreen(tester, const Size(600, 1400));
    await tester.pump();
    final router = await pumpRoutedApp(
      tester,
      initialLocation: AppRoutes.brief,
      routes: {
        AppRoutes.brief: (_) => const BriefScreen(),
        AppRoutes.reader: (_) => const Text('reader'),
        AppRoutes.home: (_) => const Text('home'),
      },
      providers: harness.providers,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('HEALTH'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start with 1 topic'));
    await tester.pumpAndSettle();
    expect(find.text("Couldn't build your brief"), findsOneWidget);

    when(() => harness.getTopHeadlines(any())).thenAnswer((_) async => DataSuccess(stories));
    await tester.tap(find.text('Pick other topics'));
    await tester.pumpAndSettle();
    expect(find.text('WHAT DO YOU WANT TO READ TODAY?'), findsOneWidget);
    await tester.tap(find.text('HEALTH'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start with 1 topic'));
    await tester.pumpAndSettle();
    expect(find.text('First story'), findsOneWidget);

    await tester.tap(find.byTooltip('Listen'));
    await tester.pumpAndSettle();
    expect(harness.speech.spoken.single, startsWith('First story.'));
    await tester.tap(find.byTooltip('Stop'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Listen'), findsOneWidget);

    await tester.tap(find.text('Read'));
    await tester.pumpAndSettle();
    expect(find.text('reader'), findsOneWidget);
    expect(harness.briefCubit.state.readIds, contains('a'));
    router.pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Finish the brief'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open Saved'));
    await tester.pumpAndSettle();
    expect(locationOf(router), '${AppRoutes.home}?tab=2');
  });
}
