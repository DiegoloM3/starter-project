import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/ui_elements/form_field_label.dart';
import 'package:flutter/material.dart';

import '../../../../../helpers/test_wrapper.dart';

void main() {
  group('FormFieldLabel', () {
    testWidgets('renders label in uppercase', (tester) async {
      await tester.pumpWidget(
        testableWidget(const FormFieldLabel(label: 'Title')),
      );

      expect(find.text('TITLE'), findsOneWidget);
    });

    testWidgets('uses accent green color', (tester) async {
      await tester.pumpWidget(
        testableWidget(const FormFieldLabel(label: 'Section')),
      );

      final text = tester.widget<Text>(find.text('SECTION'));
      expect(text.style?.color, AppColors.accentGreen);
    });

    testWidgets('uses field label font size', (tester) async {
      await tester.pumpWidget(
        testableWidget(const FormFieldLabel(label: 'Images')),
      );

      final text = tester.widget<Text>(find.text('IMAGES'));
      expect(text.style?.fontSize, 12);
      expect(text.style?.fontWeight, FontWeight.w600);
    });
  });
}
