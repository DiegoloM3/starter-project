import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/auth_text_field.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: child),
    );

void main() {
  group('AuthTextField', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AuthTextField(
            label: 'Email',
            controller: TextEditingController(),
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('obscures text when obscureText is true', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AuthTextField(
            label: 'Password',
            controller: TextEditingController(),
            obscureText: true,
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isTrue);
    });

    testWidgets('shows error text when errorText is provided', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AuthTextField(
            label: 'Email',
            controller: TextEditingController(),
            errorText: 'Invalid email',
          ),
        ),
      );

      expect(find.text('Invalid email'), findsOneWidget);
    });

    testWidgets('is not obscured by default', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AuthTextField(
            label: 'Email',
            controller: TextEditingController(),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isFalse);
    });
  });
}
