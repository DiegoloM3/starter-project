import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_detail_app_bar.dart';

// Pins spec 011 scenario 5: the back icon pops the navigator.
// The bar is trivial but the back button is the only exit from a detail
// page, so a one-line regression guard is worth the cost.
void main() {
  testWidgets(
    'tapping the back icon pops the current route',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const Scaffold(
                        appBar: ArticleDetailAppBar(),
                        body: Text('detail route'),
                      ),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );

      // Push the detail route.
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('detail route'), findsOneWidget);

      // Tap the back icon — must pop back to the first route.
      await tester.tap(find.byIcon(Ionicons.chevron_back));
      await tester.pumpAndSettle();

      expect(find.text('detail route'), findsNothing);
      expect(find.text('open'), findsOneWidget);
    },
  );
}
