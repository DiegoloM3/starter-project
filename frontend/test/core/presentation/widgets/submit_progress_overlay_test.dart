import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/presentation/widgets/submit_progress_overlay.dart';

void main() {
  testWidgets('loading, then success, then dismisses itself', (tester) async {
    final overlay = SubmitProgressOverlay();
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => overlay.showLoading(context),
          child: const Text('show'),
        ),
      ),
    ));

    await tester.tap(find.text('show'));
    await tester.pump();

    expect(find.byKey(const Key('submitProgressOverlay')), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsNothing);

    // Not awaited here, same as the real caller (a BlocListener never
    // awaits it directly either) -- it flips to the checkmark synchronously
    // before its internal delay, so a pump sees that part right away.
    unawaited(overlay.showSuccess());
    await tester.pump();

    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 800));

    expect(find.byKey(const Key('submitProgressOverlay')), findsNothing);
  });
}
