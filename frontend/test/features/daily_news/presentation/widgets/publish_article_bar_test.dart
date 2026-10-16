import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/publish_article_bar.dart';

void main() {
  Future<void> pumpBar(WidgetTester tester, VoidCallback onPressed) {
    return tester.pumpWidget(MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(padding: EdgeInsets.only(bottom: 24)),
        child: Scaffold(bottomNavigationBar: PublishArticleBar(onPressed: onPressed)),
      ),
    ));
  }

  group('PublishArticleBar', () {
    testWidgets('centers its content in the bar, including the system navigation area', (tester) async {
      await pumpBar(tester, () {});

      final barCenter = tester.getCenter(find.byType(PublishArticleBar));
      final contentCenter = tester.getCenter(find.text('Publish Article'));

      expect(contentCenter.dy, moreOrLessEquals(barCenter.dy, epsilon: 0.5));
    });

    testWidgets('reports a tap', (tester) async {
      var taps = 0;
      await pumpBar(tester, () => taps++);

      await tester.tap(find.text('Publish Article'));

      expect(taps, 1);
    });
  });
}
