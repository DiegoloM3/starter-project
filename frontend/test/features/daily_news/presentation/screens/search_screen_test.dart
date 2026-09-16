import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/config/routes/app_routes.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/feed.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/search_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/search/highlighted_text.dart';

import '../../../../helpers/feed_harness.dart';
import '../../../../helpers/fixtures.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  Future<ShellHarness> pumpSearch(WidgetTester tester) async {
    final harness = ShellHarness(feed: FeedEntity(articles: [buildArticle(title: 'Tram strike ends')]));
    useScreen(tester, const Size(600, 1400));
    await tester.pump();
    await pumpRoutedApp(
      tester,
      initialLocation: AppRoutes.home,
      routes: {
        AppRoutes.home: (_) => const SearchScreen(),
        AppRoutes.reader: (_) => const Text('reader'),
      },
      providers: harness.providers,
    );
    await tester.pumpAndSettle();
    return harness;
  }

  testWidgets('idle shows topics; typing searches, highlights and lists results', (tester) async {
    final harness = await pumpSearch(tester);
    expect(find.text('SECTIONS'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'tram');
    await tester.pumpAndSettle();

    verify(() => harness.searchArticles('tram')).called(1);
    expect(find.text('1 RESULT'), findsOneWidget);
    final highlighted = tester.widget<HighlightedText>(find.byType(HighlightedText).first);
    expect(highlighted.query, 'tram');

    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();
    expect(find.text('RECENT'), findsOneWidget);
    expect(find.text('tram'), findsOneWidget);

  });

  testWidgets('a topic chip runs that search and no results is explained', (tester) async {
    final harness = await pumpSearch(tester);
    when(() => harness.searchArticles(any())).thenAnswer((_) async => const DataSuccess(FeedEntity.empty));

    await tester.tap(find.text('Sports'));
    await tester.pumpAndSettle();

    verify(() => harness.searchArticles('Sports')).called(1);
    expect(find.text('No stories about "Sports"'), findsOneWidget);
  });

  testWidgets('Clear returns to the recent list, and a recent query runs again', (tester) async {
    final harness = await pumpSearch(tester);

    await tester.enterText(find.byType(TextField), 'tram');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();
    expect(find.text('RECENT'), findsOneWidget);

    await tester.tap(find.text('tram'));
    await tester.pumpAndSettle();

    verify(() => harness.searchArticles('tram')).called(greaterThanOrEqualTo(2));
    expect(find.text('1 RESULT'), findsOneWidget);
  });
}
