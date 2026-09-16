import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/fields/labeled_text_field.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows the label, the required mark and the optional hint', (tester) async {
    await pumpApp(
      tester,
      const Column(
        children: [
          LabeledTextField(label: 'Title', required: true),
          LabeledTextField(label: 'Photo', optional: true),
        ],
      ),
    );

    expect(find.textContaining('Title'), findsOneWidget);
    expect(find.textContaining('*'), findsOneWidget);
    expect(find.textContaining('(optional)'), findsOneWidget);
  });

  testWidgets('the counter follows the text and turns red at the limit', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await pumpApp(
      tester,
      LabeledTextField(label: 'Title', controller: controller, maxLength: 5),
    );

    expect(find.text('0 / 5'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'abcdefgh');
    await tester.pump();

    expect(controller.text, 'abcde');
    final counter = tester.widget<Text>(find.text('5 / 5'));
    expect(counter.style?.color, AppPalette.light.error);
  });

  testWidgets('an error text renders as a sentence with an icon', (tester) async {
    await pumpApp(
      tester,
      const LabeledTextField(label: 'Email', errorText: 'Enter your email.'),
    );

    expect(find.byType(FieldErrorMessage), findsOneWidget);
    expect(find.text('Enter your email.'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
  });

  testWidgets('obscured fields stay single-line', (tester) async {
    await pumpApp(
      tester,
      const LabeledTextField(label: 'Password', obscureText: true, minLines: 3, maxLines: 6),
    );

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.maxLines, 1);
    expect(field.obscureText, isTrue);
  });
}
