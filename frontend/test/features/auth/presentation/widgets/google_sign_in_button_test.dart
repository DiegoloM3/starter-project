import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/google_sign_in_button.dart';

import '../../../../test_helpers/localization_test_helper.dart';

Widget _wrap(Widget child) => wrapWithLocalizations(child);

void main() {
  group('GoogleSignInButton', () {
    testWidgets('renders the button', (tester) async {
      await tester.pumpWidget(
        _wrap(
          GoogleSignInButton(onTap: () {}),
        ),
      );

      // Button is rendered — look for ElevatedButton or GestureDetector
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('fires onTap callback when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        _wrap(
          GoogleSignInButton(onTap: () => tapped = true),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('shows Google label text', (tester) async {
      await tester.pumpWidget(
        _wrap(
          GoogleSignInButton(onTap: () {}),
        ),
      );

      // Some text mentioning Google should be present
      expect(find.textContaining('Google'), findsOneWidget);
    });
  });
}
