import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/markdown_editing_controller.dart';

void main() {
  late BuildContext context;

  Future<TextSpan> buildTextSpan(WidgetTester tester, String text) async {
    await tester.pumpWidget(Builder(builder: (builderContext) {
      context = builderContext;
      return const SizedBox();
    }));
    final controller = MarkdownEditingController()..text = text;
    return controller.buildTextSpan(context: context, style: const TextStyle(fontSize: 16), withComposing: false);
  }

  /// Text of every leaf span with the style it is drawn with.
  List<MapEntry<String, TextStyle>> readStyledTexts(TextSpan span, [TextStyle inheritedStyle = const TextStyle()]) {
    final style = inheritedStyle.merge(span.style);
    return [
      if (span.text != null && span.text!.isNotEmpty) MapEntry(span.text!, style),
      for (final child in span.children ?? const <InlineSpan>[]) ...readStyledTexts(child as TextSpan, style),
    ];
  }

  TextStyle findStyleOf(List<MapEntry<String, TextStyle>> styledTexts, String text) {
    return styledTexts.firstWhere((styledText) => styledText.key == text).value;
  }

  group('MarkdownEditingController', () {
    testWidgets('keeps the whole text, marks included', (tester) async {
      const text = '## Key facts\nThe **new** park.';

      final span = await buildTextSpan(tester, text);

      expect(span.toPlainText(), text);
    });

    testWidgets('shows bold text in bold and hides its marks', (tester) async {
      final styledTexts = readStyledTexts(await buildTextSpan(tester, 'The **new** park.'));

      expect(findStyleOf(styledTexts, 'new').fontWeight, FontWeight.w700);
      expect(findStyleOf(styledTexts, '**').color, MarkdownEditingController.hiddenMarkStyle.color);
      expect(findStyleOf(styledTexts, 'The ').fontWeight, isNull);
    });

    testWidgets('shows subheadings bigger and hides their marks', (tester) async {
      final styledTexts = readStyledTexts(await buildTextSpan(tester, '## Key facts\nThe park.'));

      expect(findStyleOf(styledTexts, 'Key facts').fontSize, MarkdownEditingController.subheadingStyle.fontSize);
      expect(findStyleOf(styledTexts, '## ').color, MarkdownEditingController.hiddenMarkStyle.color);
      expect(findStyleOf(styledTexts, 'The park.').fontSize, 16);
    });

    testWidgets('leaves the marks of an unclosed bold span visible', (tester) async {
      final styledTexts = readStyledTexts(await buildTextSpan(tester, 'The **new park.'));

      expect(findStyleOf(styledTexts, 'The **new park.').color, isNull);
    });
  });
}
