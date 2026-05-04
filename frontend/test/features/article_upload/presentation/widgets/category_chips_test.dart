import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_category.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/widgets/category_chips.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('CategoryChips', () {
    testWidgets('renders one ChoiceChip per category', (tester) async {
      await tester.pumpWidget(_wrap(CategoryChips(
        selected: null,
        onSelected: (_) {},
      )));

      expect(find.byType(ChoiceChip), findsNWidgets(ArticleCategory.values.length));
    });

    testWidgets('tapping a chip calls onSelected with that category', (tester) async {
      ArticleCategory? received;
      await tester.pumpWidget(_wrap(CategoryChips(
        selected: null,
        onSelected: (c) => received = c,
      )));

      await tester.tap(find.text('TECH'));
      await tester.pump();

      expect(received, ArticleCategory.tech);
    });

    testWidgets('selected chip renders differently from unselected', (tester) async {
      await tester.pumpWidget(_wrap(CategoryChips(
        selected: ArticleCategory.news,
        onSelected: (_) {},
      )));

      final chips = tester.widgetList<ChoiceChip>(find.byType(ChoiceChip)).toList();
      final newsChip = chips.firstWhere((c) {
        final label = c.label as Text;
        return label.data == 'NEWS';
      });
      expect(newsChip.selected, isTrue);
    });
  });
}
