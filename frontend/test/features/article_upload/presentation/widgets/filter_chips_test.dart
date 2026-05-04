import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/feed/feed_state.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/widgets/feed_filter_chips.dart';

import '../../../../test_helpers/localization_test_helper.dart';

Widget _wrap(Widget child) => wrapWithLocalizations(child);

void main() {
  group('FeedFilterChips', () {
    testWidgets('renders all provided filters', (tester) async {
      await tester.pumpWidget(_wrap(FeedFilterChips(
        filters: FeedFilter.values,
        selected: FeedFilter.all,
        onSelected: (_) {},
      )));

      expect(find.byType(ChoiceChip), findsNWidgets(FeedFilter.values.length));
    });

    testWidgets('tapping a chip calls onSelected with the correct filter', (tester) async {
      FeedFilter? received;
      await tester.pumpWidget(_wrap(FeedFilterChips(
        filters: FeedFilter.values,
        selected: FeedFilter.all,
        onSelected: (f) => received = f,
      )));

      await tester.tap(find.text('News'));
      await tester.pump();

      expect(received, FeedFilter.news);
    });

    testWidgets('selected chip is visually selected', (tester) async {
      await tester.pumpWidget(_wrap(FeedFilterChips(
        filters: FeedFilter.values,
        selected: FeedFilter.community,
        onSelected: (_) {},
      )));

      final chips = tester.widgetList<ChoiceChip>(find.byType(ChoiceChip)).toList();
      final communityChip = chips.firstWhere((c) {
        final label = c.label as Text;
        return label.data == 'Community';
      });
      expect(communityChip.selected, isTrue);
    });
  });
}
