import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/core/design_system/design_system.dart';
import 'package:news_app_clean_architecture/l10n/generated/app_localizations.dart';

void main() {
  group('BreakingBanner', () {
    testWidgets('shows BREAKING label and first headline', (tester) async {
      await tester.pumpDesignSystem(BreakingBanner(headlines: ['Headline A']));

      expect(find.text('BREAKING'), findsOneWidget);
      expect(find.text('Headline A'), findsOneWidget);
    });

    testWidgets('rotates headlines on interval', (tester) async {
      await tester.pumpDesignSystem(
        BreakingBanner(headlines: ['Headline A', 'Headline B']),
      );

      expect(find.text('Headline A'), findsOneWidget);

      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Headline B'), findsOneWidget);
    });

    test('asserts when headlines list is empty', () {
      expect(() => BreakingBanner(headlines: []), throwsAssertionError);
    });
  });

  group('CategoryBadge', () {
    testWidgets('renders uppercase label when filled', (tester) async {
      await tester.pumpDesignSystem(const CategoryBadge('Featured'));

      expect(find.text('FEATURED'), findsOneWidget);
    });

    testWidgets('renders uppercase label when outlined', (tester) async {
      await tester.pumpDesignSystem(
        const CategoryBadge('Local News', filled: false),
      );

      expect(find.text('LOCAL NEWS'), findsOneWidget);
    });
  });

  group('CommunityArticleTile', () {
    testWidgets('renders article metadata and falls back to initials', (
      tester,
    ) async {
      await tester.pumpDesignSystem(
        const CommunityArticleTile(
          authorName: 'Jane Smith',
          title: 'Community title',
          excerpt: 'A short summary.',
          timeAgo: '2h ago',
          commentCount: 7,
          category: 'Community',
        ),
      );

      expect(find.text('Jane Smith'), findsOneWidget);
      expect(find.text('Community title'), findsOneWidget);
      expect(find.text('A short summary.'), findsOneWidget);
      expect(find.text('2h ago'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('COMMUNITY'), findsOneWidget);
      expect(find.text('JA'), findsOneWidget);
      expect(find.byIcon(Ionicons.chatbox_ellipses_outline), findsOneWidget);
    });

    testWidgets('calls onTap when tile is tapped', (tester) async {
      var tapped = false;

      await tester.pumpDesignSystem(
        CommunityArticleTile(
          authorName: 'Jane Smith',
          title: 'Community title',
          excerpt: 'A short summary.',
          timeAgo: '2h ago',
          commentCount: 7,
          onTap: () => tapped = true,
        ),
      );

      await tester.tap(find.byType(CommunityArticleTile));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });

  group('DeleteConfirmationSheet', () {
    testWidgets('calls onDelete and closes sheet', (tester) async {
      var deleteCalled = false;

      await tester.pumpDeleteSheet(onDelete: () => deleteCalled = true);

      expect(find.text('Delete article?'), findsOneWidget);

      await tester.tap(find.text('DELETE'));
      await tester.pumpAndSettle();

      expect(deleteCalled, isTrue);
      expect(find.text('Delete article?'), findsNothing);
    });

    testWidgets('calls onCancel and closes sheet', (tester) async {
      var cancelCalled = false;

      await tester.pumpDeleteSheet(
        onDelete: () {},
        onCancel: () => cancelCalled = true,
      );

      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();

      expect(cancelCalled, isTrue);
      expect(find.text('Delete article?'), findsNothing);
    });
  });

  group('ErrorDisplay', () {
    testWidgets('shows message and no retry button when callback is absent', (
      tester,
    ) async {
      await tester.pumpDesignSystem(
        const ErrorDisplay(message: 'Something went wrong'),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('shows retry button and invokes callback', (tester) async {
      var retried = false;

      await tester.pumpDesignSystem(
        ErrorDisplay(
          message: 'Something went wrong',
          onRetry: () => retried = true,
          icon: Ionicons.warning_outline,
        ),
      );

      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(retried, isTrue);
    });
  });

  group('HeroArticleCard', () {
    testWidgets('shows placeholder icon when imageUrl is missing', (
      tester,
    ) async {
      await tester.pumpDesignSystem(const HeroArticleCard(title: 'Hero title'));

      expect(find.text('Hero title'), findsOneWidget);
      expect(find.byIcon(Ionicons.image_outline), findsOneWidget);
    });

    testWidgets('renders optional metadata and invokes onTap', (tester) async {
      var tapped = false;

      await tester.pumpDesignSystem(
        HeroArticleCard(
          title: 'Hero title',
          imageUrl: 'https://example.com/image.png',
          category: 'Technology',
          description: 'Hero description',
          author: 'Alex',
          publishedAt: 'Feb 11, 2026',
          onTap: () => tapped = true,
        ),
      );

      expect(find.text('TECHNOLOGY'), findsOneWidget);
      expect(find.text('Hero title'), findsOneWidget);
      expect(find.text('Hero description'), findsOneWidget);
      expect(find.text('By Alex • Feb 11, 2026'), findsOneWidget);

      await tester.tap(find.text('Hero title'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });

  group('LoadingIndicator', () {
    testWidgets('shows progress indicator without message', (tester) async {
      await tester.pumpDesignSystem(const LoadingIndicator());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsNothing);
    });

    testWidgets('shows message when provided', (tester) async {
      await tester.pumpDesignSystem(
        const LoadingIndicator(message: 'Loading articles...'),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading articles...'), findsOneWidget);
    });
  });
}

extension _WidgetPumps on WidgetTester {
  Future<void> pumpDesignSystem(Widget child) async {
    await pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );
    await pump();
  }

  Future<void> pumpDeleteSheet({
    required VoidCallback onDelete,
    VoidCallback? onCancel,
  }) async {
    await pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (_) => DeleteConfirmationSheet(
                        onDelete: onDelete,
                        onCancel: onCancel,
                      ),
                    );
                  },
                  child: const Text('Open Sheet'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tap(find.text('Open Sheet'));
    await pumpAndSettle();
  }
}
