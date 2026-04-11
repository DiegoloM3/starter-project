import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/ui_elements/section_badge.dart';

import '../../../../../helpers/test_wrapper.dart';

void main() {
  group('SectionBadge', () {
    const backgroundColor = Color(0xFFE3F2FD);
    const textColor = Color(0xFF1976D2);

    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        testableWidget(
          const SectionBadge(
            label: 'Weather',
            backgroundColor: backgroundColor,
            textColor: textColor,
          ),
        ),
      );

      expect(find.text('Weather'), findsOneWidget);
    });

    testWidgets('applies background color', (tester) async {
      await tester.pumpWidget(
        testableWidget(
          const SectionBadge(
            label: 'Weather',
            backgroundColor: backgroundColor,
            textColor: textColor,
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SectionBadge),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, backgroundColor);
    });

    testWidgets('applies text color', (tester) async {
      await tester.pumpWidget(
        testableWidget(
          const SectionBadge(
            label: 'Weather',
            backgroundColor: backgroundColor,
            textColor: textColor,
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Weather'));
      expect(text.style?.color, textColor);
    });

    testWidgets('has pill shape (full border radius)', (tester) async {
      await tester.pumpWidget(
        testableWidget(
          const SectionBadge(
            label: 'Sports',
            backgroundColor: backgroundColor,
            textColor: textColor,
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SectionBadge),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.borderRadius, isNotNull);
    });
  });
}
