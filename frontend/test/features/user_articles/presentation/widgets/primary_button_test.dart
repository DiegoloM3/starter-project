import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/widgets/primary_button.dart';

void main() {
  Widget host(Widget child) {
    return MaterialApp(
      theme: lightTheme(),
      home: Scaffold(body: child),
    );
  }

  testWidgets('renders label and triggers onPressed', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      host(
        PrimaryButton(label: 'Publish', onPressed: () => taps++),
      ),
    );

    expect(find.text('Publish'), findsOneWidget);

    await tester.tap(find.byType(PrimaryButton));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('is disabled when onPressed is null', (tester) async {
    await tester.pumpWidget(
      host(const PrimaryButton(label: 'Publish', onPressed: null)),
    );

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('shows spinner when isLoading=true', (tester) async {
    await tester.pumpWidget(
      host(
        PrimaryButton(label: 'Publish', onPressed: () {}, isLoading: true),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Publish'), findsNothing);
  });
}
