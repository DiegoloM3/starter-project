import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/add_article_button.dart';

void main() {
  group('AddArticleButton', () {
    testWidgets('centers its plus sign', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Center(child: AddArticleButton(onPressed: () {}))));

      expect(tester.getCenter(find.byIcon(Icons.add)), tester.getCenter(find.byType(AddArticleButton)));
    });

    testWidgets('reports a tap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(MaterialApp(home: Center(child: AddArticleButton(onPressed: () => taps++))));

      await tester.tap(find.byType(AddArticleButton));

      expect(taps, 1);
    });
  });
}
