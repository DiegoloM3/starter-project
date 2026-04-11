import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/chips/section_chip.dart';

import '../../../../../helpers/test_wrapper.dart';

void main() {
  group('SectionChip', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        testableWidget(
          SectionChip(label: 'Sports', isActive: false, onTap: () {}),
        ),
      );

      expect(find.text('Sports'), findsOneWidget);
    });

    testWidgets('applies active style when isActive is true', (tester) async {
      await tester.pumpWidget(
        testableWidget(
          SectionChip(label: 'Sports', isActive: true, onTap: () {}),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SectionChip),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, AppColors.accentGreen);
      expect(decoration.border, isNull);
    });

    testWidgets('applies inactive style when isActive is false',
        (tester) async {
      await tester.pumpWidget(
        testableWidget(
          SectionChip(label: 'Sports', isActive: false, onTap: () {}),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SectionChip),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, testColors.bgCard);
      expect(decoration.border, isNotNull);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        testableWidget(
          SectionChip(label: 'Sports', isActive: false, onTap: () => tapped = true),
        ),
      );

      await tester.tap(find.text('Sports'));
      expect(tapped, isTrue);
    });

    testWidgets('active chip text is white', (tester) async {
      await tester.pumpWidget(
        testableWidget(
          SectionChip(label: 'Active', isActive: true, onTap: () {}),
        ),
      );

      final text = tester.widget<Text>(find.text('Active'));
      expect(text.style?.color, AppColors.white);
    });

    testWidgets('inactive chip text uses secondary color', (tester) async {
      await tester.pumpWidget(
        testableWidget(
          SectionChip(label: 'Inactive', isActive: false, onTap: () {}),
        ),
      );

      final text = tester.widget<Text>(find.text('Inactive'));
      expect(text.style?.color, testColors.textSecondary);
    });
  });
}
