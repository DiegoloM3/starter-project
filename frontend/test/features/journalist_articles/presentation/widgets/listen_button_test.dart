import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/widgets/listen_button.dart';

import '../../../../helpers/localized_app.dart';

void main() {
  Future<void> showButton(WidgetTester tester, {required bool isReading, VoidCallback? onPressed}) {
    return tester.pumpWidget(localizedApp(
      home: Scaffold(body: ListenButton(isReading: isReading, onPressed: onPressed ?? () {})),
    ));
  }

  testWidgets('invites to listen while idle', (tester) async {
    await showButton(tester, isReading: false);

    expect(find.text('Listen to this article'), findsOneWidget);
    expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
  });

  testWidgets('offers to stop while reading', (tester) async {
    await showButton(tester, isReading: true);

    expect(find.text('Stop reading'), findsOneWidget);
    expect(find.byIcon(Icons.stop_rounded), findsOneWidget);
  });

  testWidgets('reports the tap', (tester) async {
    var presses = 0;
    await showButton(tester, isReading: false, onPressed: () => presses++);

    await tester.tap(find.byType(ListenButton));

    expect(presses, 1);
  });
}
