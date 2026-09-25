import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/widgets/article_body_editing_controller.dart';

void main() {
  testWidgets('draws exactly the typed text, markers included', (tester) async {
    const body = '## What happens next\nPower is **back**.\n\nEnd';

    final (span, _) = await _buildSpan(tester, body);

    expect(span.toPlainText(), body);
  });

  testWidgets('draws bold text bold and the markers faded', (tester) async {
    final (span, colorScheme) = await _buildSpan(tester, 'Power is **back**');
    final leaves = _textLeaves(span);

    expect(
      leaves.firstWhere((leaf) => leaf.text == 'back').style?.fontWeight,
      FontWeight.w700,
    );
    expect(
      leaves.where((leaf) => leaf.text == '**').map((leaf) => leaf.style?.color),
      everyElement(colorScheme.outline),
    );
  });

  testWidgets('draws a subheading larger than the body text', (tester) async {
    final (span, _) = await _buildSpan(tester, 'Intro\n## Next');

    final headingLine = span.children!
        .whereType<TextSpan>()
        .firstWhere((line) => line.toPlainText() == '## Next');

    expect(headingLine.style?.fontSize, greaterThan(16));
  });

  testWidgets('draws a quote line in italics', (tester) async {
    final (span, _) = await _buildSpan(tester, '> Stay calm');

    final quoteLine = span.children!
        .whereType<TextSpan>()
        .firstWhere((line) => line.toPlainText() == '> Stay calm');

    expect(quoteLine.style?.fontStyle, FontStyle.italic);
  });
}

Future<(TextSpan, ColorScheme)> _buildSpan(
  WidgetTester tester,
  String body,
) async {
  final controller = ArticleBodyEditingController(text: body);
  addTearDown(controller.dispose);
  late TextSpan span;
  late ColorScheme colorScheme;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          colorScheme = Theme.of(context).colorScheme;
          span = controller.buildTextSpan(
            context: context,
            style: const TextStyle(fontSize: 16),
            withComposing: false,
          );
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return (span, colorScheme);
}

List<TextSpan> _textLeaves(InlineSpan root) {
  final leaves = <TextSpan>[];
  root.visitChildren((span) {
    if (span is TextSpan) leaves.add(span);
    return true;
  });
  return leaves;
}
