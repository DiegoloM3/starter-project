import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/form/form_section_selector.dart';

import '../../../../../helpers/test_wrapper.dart';

enum _TestSection { sports, arts, weather }

void main() {
  group('FormSectionSelector', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        testableWidget(
          FormSectionSelector<_TestSection>(
            label: 'Section',
            items: _TestSection.values,
            selectedItem: null,
            onChanged: (_) {},
            labelBuilder: (s) => s.name,
          ),
        ),
      );

      expect(find.text('SECTION'), findsOneWidget);
    });

    testWidgets('renders all items as chips', (tester) async {
      await tester.pumpWidget(
        testableWidget(
          FormSectionSelector<_TestSection>(
            label: 'Section',
            items: _TestSection.values,
            selectedItem: null,
            onChanged: (_) {},
            labelBuilder: (s) => s.name,
          ),
        ),
      );

      expect(find.text('sports'), findsOneWidget);
      expect(find.text('arts'), findsOneWidget);
      expect(find.text('weather'), findsOneWidget);
    });

    testWidgets('calls onChanged when chip tapped', (tester) async {
      _TestSection? selected;
      await tester.pumpWidget(
        testableWidget(
          FormSectionSelector<_TestSection>(
            label: 'Section',
            items: _TestSection.values,
            selectedItem: null,
            onChanged: (s) => selected = s,
            labelBuilder: (s) => s.name,
          ),
        ),
      );

      await tester.tap(find.text('arts'));
      expect(selected, _TestSection.arts);
    });

    testWidgets('marks selected item as active', (tester) async {
      await tester.pumpWidget(
        testableWidget(
          FormSectionSelector<_TestSection>(
            label: 'Section',
            items: _TestSection.values,
            selectedItem: _TestSection.sports,
            onChanged: (_) {},
            labelBuilder: (s) => s.name,
          ),
        ),
      );

      final sportsText = tester.widget<Text>(find.text('sports'));
      expect(sportsText.style?.fontWeight, FontWeight.w600);
    });
  });
}
