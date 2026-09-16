import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/config/routes/app_routes.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/my_articles_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/my_articles/delete_article_dialog.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/my_articles/my_article_row.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/screens/profile_screen.dart';
import 'package:news_app_clean_architecture/shared/presentation/formatters/failure_message_formatter.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/feedback/empty_state.dart';

import '../../../../helpers/feed_harness.dart';
import '../../../../helpers/fixtures.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  final live = buildUserArticle(id: 'live', authorId: user.id).copyWith(title: 'Live story');
  final older = buildUserArticle(id: 'older', authorId: user.id).copyWith(title: 'Older story');

  Future<ShellHarness> pumpMyArticles(WidgetTester tester, {required String initial}) async {
    final harness = ShellHarness(myArticles: [live, older]);
    useScreen(tester, const Size(600, 1600));
    await tester.pump();
    await pumpRoutedApp(
      tester,
      initialLocation: initial,
      routes: {
        AppRoutes.myArticles: (_) => const MyArticlesScreen(),
        AppRoutes.home: (_) => const ProfileScreen(),
        AppRoutes.publish: (_) => const Text('publish form'),
        AppRoutes.reader: (_) => const Text('reader'),
      },
      providers: harness.providers,
    );
    await tester.pumpAndSettle();
    return harness;
  }

  testWidgets('lists the articles with their badges', (tester) async {
    await pumpMyArticles(tester, initial: AppRoutes.myArticles);

    expect(find.text('02'), findsWidgets);
    expect(find.byType(MyArticleRow), findsNWidgets(2));
    expect(find.text('PUBLISHED'), findsNWidgets(2));

    await tester.tap(find.text('Edit').first);
    await tester.pumpAndSettle();
    expect(find.text('publish form'), findsOneWidget);
  });

  testWidgets('Delete asks first, then removes the row and refreshes the feed', (tester) async {
    final harness = await pumpMyArticles(tester, initial: AppRoutes.myArticles);

    await tester.tap(find.text('Delete').first);
    await tester.pumpAndSettle();
    expect(find.byType(DeleteArticleDialog), findsOneWidget);
    await tester.tap(find.text('Keep it'));
    await tester.pumpAndSettle();
    verifyNever(() => harness.deleteArticle(any()));

    await tester.tap(find.text('Delete').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete article'));
    await tester.pumpAndSettle();

    verify(() => harness.deleteArticle(live)).called(1);
    expect(find.byType(MyArticleRow), findsOneWidget);
    expect(find.text('Article deleted'), findsOneWidget);
  });

  testWidgets('Profile shows the counters and opens My articles', (tester) async {
    await pumpMyArticles(tester, initial: AppRoutes.home);

    expect(find.text('PUBLISHED'), findsOneWidget);
    expect(find.text('02'), findsWidgets);

    await tester.tap(find.text('My articles').last);
    await tester.pumpAndSettle();
    expect(find.byType(MyArticlesScreen), findsOneWidget);
  });

  testWidgets('an empty list shows the byline empty state', (tester) async {
    final harness = ShellHarness();
    await tester.pump();
    await pumpRoutedApp(
      tester,
      initialLocation: AppRoutes.myArticles,
      routes: {AppRoutes.myArticles: (_) => const MyArticlesScreen()},
      providers: harness.providers,
    );
    await tester.pumpAndSettle();

    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('Your byline starts here'), findsOneWidget);
  });

  testWidgets('Edit opens the form for that article', (tester) async {
    await pumpMyArticles(tester, initial: AppRoutes.myArticles);

    await tester.tap(find.text('Edit').first);
    await tester.pumpAndSettle();

    expect(find.text('publish form'), findsOneWidget);
  });

  testWidgets('a failed load explains itself and Try again reloads', (tester) async {
    final harness = ShellHarness();
    when(() => harness.getMyArticles(any())).thenAnswer((_) async => const DataFailed(Failure.server()));
    await tester.pump();
    await pumpRoutedApp(
      tester,
      initialLocation: AppRoutes.myArticles,
      routes: {AppRoutes.myArticles: (_) => const MyArticlesScreen()},
      providers: harness.providers,
    );
    await tester.pumpAndSettle();
    expect(find.text("Couldn't load your articles"), findsOneWidget);

    when(() => harness.getMyArticles(any())).thenAnswer((_) async => DataSuccess([live]));
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.byType(MyArticleRow), findsOneWidget);
  });

  testWidgets('a delete the server rejects keeps the row and says why', (tester) async {
    final harness = await pumpMyArticles(tester, initial: AppRoutes.myArticles);
    when(() => harness.deleteArticle(any())).thenAnswer((_) async => const DataFailed(Failure.server()));

    await tester.tap(find.text('Delete').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete article'));
    await tester.pumpAndSettle();

    expect(find.byType(MyArticleRow), findsNWidgets(2));
    expect(find.text(FailureMessageFormatter.of(const Failure.server())), findsOneWidget);
  });

  testWidgets('Write your first article opens the form', (tester) async {
    final harness = ShellHarness();
    await tester.pump();
    await pumpRoutedApp(
      tester,
      initialLocation: AppRoutes.myArticles,
      routes: {
        AppRoutes.myArticles: (_) => const MyArticlesScreen(),
        AppRoutes.publish: (_) => const Text('publish form'),
      },
      providers: harness.providers,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Write your first article'));
    await tester.pumpAndSettle();

    expect(find.text('publish form'), findsOneWidget);
  });
}
