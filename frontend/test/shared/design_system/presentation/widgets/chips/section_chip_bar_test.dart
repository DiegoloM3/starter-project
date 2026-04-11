import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/chips/section_chip.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/chips/section_chip_bar.dart';

import '../../../../../helpers/test_wrapper.dart';

enum _TestSection { all, sports, arts }

void main() {
  group('SectionChipBar', () {
    testWidgets('renders all items as chips', (tester) async {
      await tester.pumpWidget(
        testableWidget(
          SectionChipBar<_TestSection>(
            items: _TestSection.values,
            selectedItem: _TestSection.all,
            onItemChanged: (_) {},
            labelBuilder: (s) => s.name,
          ),
        ),
      );

      expect(find.byType(SectionChip), findsNWidgets(3));
      expect(find.text('all'), findsOneWidget);
      expect(find.text('sports'), findsOneWidget);
      expect(find.text('arts'), findsOneWidget);
    });

    testWidgets('marks selected item as active', (tester) async {
      await tester.pumpWidget(
        testableWidget(
          SectionChipBar<_TestSection>(
            items: _TestSection.values,
            selectedItem: _TestSection.sports,
            onItemChanged: (_) {},
            labelBuilder: (s) => s.name,
          ),
        ),
      );

      final chips = tester.widgetList<SectionChip>(find.byType(SectionChip));
      final chipList = chips.toList();
      expect(chipList[0].isActive, isFalse);
      expect(chipList[1].isActive, isTrue);
      expect(chipList[2].isActive, isFalse);
    });

    testWidgets('calls onItemChanged with correct item when tapped',
        (tester) async {
      _TestSection? selected;

      await tester.pumpWidget(
        testableWidget(
          SectionChipBar<_TestSection>(
            items: _TestSection.values,
            selectedItem: _TestSection.all,
            onItemChanged: (s) => selected = s,
            labelBuilder: (s) => s.name,
          ),
        ),
      );

      await tester.tap(find.text('arts'));
      expect(selected, _TestSection.arts);
    });

    testWidgets('uses labelBuilder for chip labels', (tester) async {
      await tester.pumpWidget(
        testableWidget(
          SectionChipBar<_TestSection>(
            items: _TestSection.values,
            selectedItem: _TestSection.all,
            onItemChanged: (_) {},
            labelBuilder: (s) => s.name.toUpperCase(),
          ),
        ),
      );

      expect(find.text('ALL'), findsOneWidget);
      expect(find.text('SPORTS'), findsOneWidget);
      expect(find.text('ARTS'), findsOneWidget);
    });

    testWidgets('is horizontally scrollable', (tester) async {
      await tester.pumpWidget(
        testableWidget(
          SectionChipBar<_TestSection>(
            items: _TestSection.values,
            selectedItem: _TestSection.all,
            onItemChanged: (_) {},
            labelBuilder: (s) => s.name,
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
