import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/feedback/empty_state.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders a glyph, headline, sentence and action', (tester) async {
    await pumpApp(
      tester,
      EmptyState(
        glyph: 'n',
        title: 'Nothing new',
        message: 'Try another category.',
        action: FilledButton(onPressed: () {}, child: const Text('Change category')),
      ),
    );

    expect(find.text('n'), findsOneWidget);
    expect(find.text('Nothing new'), findsOneWidget);
    expect(find.text('Try another category.'), findsOneWidget);
    expect(find.text('Change category'), findsOneWidget);
  });

  testWidgets('an icon replaces the glyph and a rich body replaces the message', (tester) async {
    await pumpApp(
      tester,
      const EmptyState(
        icon: Icons.bookmark_rounded,
        title: 'Keep stories for later',
        messageWidget: Text('rich body'),
      ),
    );

    expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
    expect(find.text('rich body'), findsOneWidget);
  });

}
