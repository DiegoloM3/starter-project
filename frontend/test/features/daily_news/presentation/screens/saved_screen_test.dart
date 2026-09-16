import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/config/routes/app_routes.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/home_shell_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/saved_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/feed/feed_item.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/screens/profile_screen.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/feedback/empty_state.dart';

import '../../../../helpers/feed_harness.dart';
import '../../../../helpers/fixtures.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  Future<ShellHarness> pumpShell(WidgetTester tester) async {
    final harness = ShellHarness();
    when(() => harness.getSaved(any())).thenAnswer(
      (_) async => DataSuccess([buildArticle(id: 'a', title: 'Kept story')]),
    );
    useScreen(tester, const Size(600, 1400));
    await tester.pump();
    await pumpRoutedApp(
      tester,
      initialLocation: AppRoutes.home,
      routes: {
        AppRoutes.home: (_) => const HomeShellScreen(),
        AppRoutes.reader: (_) => const Text('reader'),
      },
      providers: harness.providers,
    );
    await tester.pumpAndSettle();
    return harness;
  }

  testWidgets('the shell switches tabs and Saved lists the bookmarks', (tester) async {
    await pumpShell(tester);

    await tester.tap(find.text('SAVED'));
    await tester.pumpAndSettle();
    expect(find.byType(SavedScreen), findsOneWidget);
    expect(find.text('Kept story'), findsOneWidget);
    expect(find.text('01'), findsOneWidget);

    await tester.tap(find.text('PROFILE'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('ADA LOVELACE'), findsOneWidget);
  });

  testWidgets('swiping a row removes it, Undo brings it back', (tester) async {
    final harness = await pumpShell(tester);
    await tester.tap(find.text('SAVED'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(FeedItem), const Offset(-600, 0));
    await tester.pumpAndSettle();

    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('Removed from Saved'), findsOneWidget);
    verify(() => harness.remove('a')).called(1);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Kept story'), findsOneWidget);
  });

  testWidgets('tapping a saved row opens the reader', (tester) async {
    await pumpShell(tester);
    await tester.tap(find.text('SAVED'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kept story'));
    await tester.pumpAndSettle();

    expect(find.text('reader'), findsOneWidget);
  });
}
