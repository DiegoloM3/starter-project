import 'package:flutter/material.dart';

import 'markdown_formatting.dart';

/// Shows the Markdown of an article formatted while it is written: bold text
/// in bold and subheadings bigger, with their marks hidden. The text keeps
/// the marks, so it is stored and published as Markdown.
class MarkdownEditingController extends TextEditingController {
  /// Marks keep their place in the text, so the cursor positions do not
  /// change, but take no visible space.
  static const TextStyle hiddenMarkStyle = TextStyle(color: Color(0x00000000), fontSize: 0.01);
  static const TextStyle boldStyle = TextStyle(fontWeight: FontWeight.w700);
  static const TextStyle subheadingStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.w700);

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    final lineSpans = text.split('\n').map(_buildLineSpan).toList();
    final children = <InlineSpan>[];
    for (final lineSpan in lineSpans) {
      if (children.isNotEmpty) children.add(const TextSpan(text: '\n'));
      children.add(lineSpan);
    }
    return TextSpan(style: style, children: children);
  }

  TextSpan _buildLineSpan(String line) {
    final subheadingMarks = MarkdownFormatting.subheadingPattern.matchAsPrefix(line)?[0];
    if (subheadingMarks == null) {
      return TextSpan(children: _buildInlineSpans(line));
    }
    return TextSpan(
      style: subheadingStyle,
      children: [
        TextSpan(text: subheadingMarks, style: hiddenMarkStyle),
        ..._buildInlineSpans(line.substring(subheadingMarks.length)),
      ],
    );
  }

  List<InlineSpan> _buildInlineSpans(String text) {
    final spans = <InlineSpan>[];
    var plainTextStart = 0;
    for (final boldSpan in MarkdownFormatting.boldPattern.allMatches(text)) {
      spans.addAll([
        TextSpan(text: text.substring(plainTextStart, boldSpan.start)),
        const TextSpan(text: MarkdownFormatting.boldMark, style: hiddenMarkStyle),
        TextSpan(text: boldSpan[1], style: boldStyle),
        const TextSpan(text: MarkdownFormatting.boldMark, style: hiddenMarkStyle),
      ]);
      plainTextStart = boldSpan.end;
    }
    spans.add(TextSpan(text: text.substring(plainTextStart)));
    return spans;
  }
}
