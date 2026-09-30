import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/widgets/markdown_editor.dart';

import '../../../../helpers/localized_app.dart';

void main() {
  late TextEditingController controller;
  late List<String> changes;

  setUp(() {
    controller = TextEditingController();
    changes = [];
  });
  tearDown(() => controller.dispose());

  Future<void> showEditor(WidgetTester tester, {bool enabled = true, String? helperText}) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(localizedApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: MarkdownEditor(
            controller: controller,
            maxLength: 10000,
            enabled: enabled,
            helperText: helperText,
            onChanged: changes.add,
          ),
        ),
      ),
    ));
  }

  testWidgets('makes the selected text bold from the toolbar', (tester) async {
    controller.value = const TextEditingValue(
      text: 'Big news',
      selection: TextSelection(baseOffset: 0, extentOffset: 3),
    );
    await showEditor(tester);

    await tester.tap(find.byTooltip('Bold'));

    expect(controller.text, '**Big** news');
    expect(changes, ['**Big** news']);
  });

  testWidgets('turns the selected lines into a list from the toolbar', (tester) async {
    controller.value = const TextEditingValue(
      text: 'One\nTwo',
      selection: TextSelection(baseOffset: 0, extentOffset: 7),
    );
    await showEditor(tester);

    await tester.tap(find.byTooltip('Bulleted list'));

    expect(controller.text, '- One\n- Two');
  });

  testWidgets('previews the Markdown as it will be published', (tester) async {
    controller.text = '## Subtitle';
    await showEditor(tester);

    await tester.tap(find.text('Preview'));
    await tester.pump();

    expect(find.byType(MarkdownBody), findsOneWidget);
    expect(find.byTooltip('Bold'), findsNothing);
    expect(find.textContaining('Subtitle', findRichText: true), findsOneWidget);
  });

  testWidgets('says when there is nothing to preview', (tester) async {
    await showEditor(tester);

    await tester.tap(find.text('Preview'));
    await tester.pump();

    expect(find.textContaining('Nothing to preview yet.', findRichText: true), findsOneWidget);
  });

  testWidgets('disables the toolbar while publishing', (tester) async {
    await showEditor(tester, enabled: false);

    expect(tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.format_bold)).onPressed, isNull);
  });

  testWidgets('shows the writing statistics under the text', (tester) async {
    await showEditor(tester, helperText: '4 words · 1 min read');

    expect(find.text('4 words · 1 min read'), findsOneWidget);
  });
}
