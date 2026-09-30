import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/widgets/limited_text_field.dart';

import '../../../../helpers/localized_app.dart';

void main() {
  late TextEditingController controller;
  late List<String> changes;

  setUp(() {
    controller = TextEditingController();
    changes = [];
  });
  tearDown(() => controller.dispose());

  Future<void> showField(WidgetTester tester, {String? errorText, bool enabled = true}) {
    return tester.pumpWidget(localizedApp(
      home: Scaffold(
        body: LimitedTextField(
          controller: controller,
          label: 'Title',
          hintText: 'Write your title here…',
          maxLength: 100,
          errorText: errorText,
          enabled: enabled,
          onChanged: changes.add,
        ),
      ),
    ));
  }

  testWidgets('shows its label, hint and counter', (tester) async {
    await showField(tester);

    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Write your title here…'), findsOneWidget);
    expect(find.text('0/100'), findsOneWidget);
  });

  testWidgets('reports what is typed and counts it', (tester) async {
    await showField(tester);

    await tester.enterText(find.byType(TextField), 'Breaking');
    await tester.pump();

    expect(changes, ['Breaking']);
    expect(find.text('8/100'), findsOneWidget);
  });

  testWidgets('shows the error message', (tester) async {
    await showField(tester, errorText: 'Add a title for your article.');

    expect(find.text('Add a title for your article.'), findsOneWidget);
  });

  testWidgets('can be disabled while publishing', (tester) async {
    await showField(tester, enabled: false);

    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
  });
}
