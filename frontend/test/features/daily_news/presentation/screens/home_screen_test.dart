import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/config/routes/app_routes.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/feed.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/news_query.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/home_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/feed/feed_error_card.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/feed/feed_hero.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/feed/feed_item.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/feed/feed_skeleton.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/feedback/empty_state.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/labels/you_badge.dart';

import '../../../../helpers/feed_harness.dart';
import '../../../../helpers/fixtures.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  Future<void> pumpHome(WidgetTester tester, ShellHarness harness) async {
    useScreen(tester, const Size(600, 1400));
    await tester.pump();
    await pumpRoutedApp(
      tester,
      initialLocation: AppRoutes.home,
      routes: {
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.reader: (_) => const Text('reader'),
        AppRoutes.settingsCategory: (_) => const Text('category picker'),
        AppRoutes.publish: (_) => const Text('publish form'),
      },
      providers: harness.providers,
    );
  }

  testWidgets('shows the skeleton, then the feed with the "You" badge on own articles',
      (tester) async {
    final harness = ShellHarness(
      feed: FeedEntity(articles: [
        buildArticle(id: 'r', title: 'Remote headline'),
        buildUserArticle(id: 'u', authorId: user.id),
      ]),
    );
    await pumpHome(tester, harness);
    expect(find.byType(FeedSkeleton), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.textContaining(', ADA'), findsOneWidget);
    expect(find.byType(FeedHero), findsOneWidget);
    expect(find.byType(FeedItem), findsOneWidget);
    expect(find.byType(YouBadge), findsOneWidget);
    expect(find.text('LATEST'), findsOneWidget);
  });

  testWidgets('tapping a row opens the reader', (tester) async {
    final harness = ShellHarness(feed: FeedEntity(articles: [buildArticle(title: 'Remote headline')]));
    await pumpHome(tester, harness);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Remote headline'));
    await tester.pumpAndSettle();

    expect(find.text('reader'), findsOneWidget);
  });

  testWidgets('an empty feed names the category, and a settings change reloads', (tester) async {
    final harness = ShellHarness();
    await pumpHome(tester, harness);
    await tester.pumpAndSettle();
    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.textContaining('Nothing new in Top stories'), findsOneWidget);

    harness.settings.settings.add(const AppSettings(defaultCategory: NewsCategory.health));
    await tester.pumpAndSettle();

    expect(find.textContaining('Nothing new in Health'), findsOneWidget);
    verify(() => harness.getFeed(const NewsQuery(category: NewsCategory.health))).called(1);

    await tester.tap(find.text('Change category'));
    await tester.pumpAndSettle();
    expect(find.text('category picker'), findsOneWidget);
  });

  testWidgets('a partial feed shows the error card above the own articles', (tester) async {
    final harness = ShellHarness(
      feed: FeedEntity(
        articles: [buildUserArticle(authorId: user.id)],
        remoteFailure: const Failure.network(),
      ),
    );
    await pumpHome(tester, harness);
    await tester.pumpAndSettle();

    expect(find.byType(FeedErrorCard), findsOneWidget);
    expect(find.text('YOUR ARTICLES'), findsOneWidget);
    expect(find.byType(FeedItem), findsOneWidget);
  });

  testWidgets('a total failure shows the error card and Try again reloads', (tester) async {
    final harness = ShellHarness();
    when(() => harness.getFeed(any())).thenAnswer((_) async => const DataFailed(Failure.server()));
    await pumpHome(tester, harness);
    await tester.pumpAndSettle();
    expect(find.byType(FeedErrorCard), findsOneWidget);

    when(() => harness.getFeed(any()))
        .thenAnswer((_) async => DataSuccess(FeedEntity(articles: [buildArticle()])));
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.byType(FeedHero), findsOneWidget);
  });

  testWidgets('the Write block hides while the feed moves, returns once it settles and opens the form',
      (tester) async {
    final harness = ShellHarness(
      feed: FeedEntity(articles: [for (var i = 0; i < 12; i++) buildArticle(id: '$i', imageUrl: null, title: 'Story $i')]),
    );
    await pumpHome(tester, harness);
    await tester.pumpAndSettle();
    AnimatedSlide slide() => tester.widget<AnimatedSlide>(find.byType(AnimatedSlide));
    expect(slide().offset, Offset.zero);

    final gesture = await tester.startGesture(tester.getCenter(find.byType(CustomScrollView)));
    await gesture.moveBy(const Offset(0, -80));
    await tester.pump();
    await gesture.moveBy(const Offset(0, -80));
    await tester.pump();
    expect(slide().offset, isNot(Offset.zero));

    await gesture.up();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(slide().offset, Offset.zero);

    await tester.tap(find.text('WRITE'));
    await tester.pumpAndSettle();
    expect(find.text('publish form'), findsOneWidget);
  });

  testWidgets('pulling down refreshes the feed and confirms it', (tester) async {
    final harness = ShellHarness(feed: FeedEntity(articles: [buildArticle(imageUrl: null)]));
    await pumpHome(tester, harness);
    await tester.pumpAndSettle();

    await tester.fling(find.byType(CustomScrollView), const Offset(0, 400), 1000);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    verify(() => harness.getFeed(any())).called(2);
    expect(find.text('Feed updated'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('Try again on a partial feed reloads it, and a numbered row opens the reader', (tester) async {
    final harness = ShellHarness(
      feed: FeedEntity(
        articles: [buildUserArticle(authorId: user.id, imageUrl: null).copyWith(title: 'Own one')],
        remoteFailure: const Failure.network(),
      ),
    );
    await pumpHome(tester, harness);
    await tester.pumpAndSettle();
    expect(find.byType(FeedErrorCard), findsOneWidget);

    when(() => harness.getFeed(any())).thenAnswer((_) async => DataSuccess(FeedEntity(articles: [
          buildArticle(id: 'r1', imageUrl: null, title: 'Lead'),
          buildArticle(id: 'r2', imageUrl: null, title: 'Second row'),
        ])));
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.byType(FeedErrorCard), findsNothing);
    expect(find.byType(FeedHero), findsOneWidget);

    await tester.ensureVisible(find.text('Second row'));
    await tester.tap(find.text('Second row'));
    await tester.pumpAndSettle();
    expect(find.text('reader'), findsOneWidget);
  });
}
