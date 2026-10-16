import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/config/theme/app_design_tokens.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_image_placeholder.dart';

void main() {
  group('ArticleImagePlaceholder', () {
    testWidgets('uses the colors of the prototype', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ArticleImagePlaceholder()));

      final background = find.descendant(of: find.byType(ArticleImagePlaceholder), matching: find.byType(ColoredBox));

      expect(tester.widget<ColoredBox>(background).color, AppColors.lilac);
      expect(tester.widget<Icon>(find.byType(Icon)).color, AppColors.darkText);
    });

    testWidgets('tells screen readers that the article has no image', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ArticleImagePlaceholder()));

      expect(find.bySemanticsLabel('Article without image'), findsOneWidget);
    });
  });
}
