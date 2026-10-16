import 'package:flutter/services.dart';

/// Markdown marks that journalists can add while writing an article
/// (Figma annotation #3: subheadings and bold text).
class MarkdownFormatting {
  static const String boldMark = '**';
  static const String subheadingMark = '## ';

  /// Text between bold marks, within a single line.
  static final RegExp boldPattern = RegExp(r'\*\*(.*?)\*\*');

  /// Marks at the start of a line that turn it into a heading.
  static final RegExp subheadingPattern = RegExp(r'^#{1,6} +');

  /// Works like the bold button of a text editor:
  /// - wraps the selected text in bold marks, or starts an empty bold span at
  ///   the cursor;
  /// - at the end of a bold span, moves the cursor after it, so the next
  ///   words are not bold;
  /// - anywhere else inside a bold span, removes its marks.
  static TextEditingValue toggleBold(TextEditingValue value) {
    final selection = _readSelection(value);
    final boldSpan = _findBoldSpanAt(value.text, selection);
    if (boldSpan == null) {
      return _wrapInBold(value.text, selection);
    }
    final isAtEndOfBoldText = selection.start == boldSpan.end - boldMark.length && boldSpan[1]!.isNotEmpty;
    if (isAtEndOfBoldText) {
      return TextEditingValue(text: value.text, selection: TextSelection.collapsed(offset: boldSpan.end));
    }
    return _removeBold(value.text, boldSpan, selection.start);
  }

  /// Turns the line of the cursor into a subheading, or back into normal
  /// text when it already is one.
  static TextEditingValue toggleSubheading(TextEditingValue value) {
    final selection = _readSelection(value);
    final lineStart = _findLineStart(value.text, selection.start);
    final textBeforeLine = value.text.substring(0, lineStart);
    final textFromLine = value.text.substring(lineStart);
    final currentMarks = subheadingPattern.matchAsPrefix(textFromLine)?[0] ?? '';
    final newMarks = currentMarks.isEmpty ? subheadingMark : '';
    final formattedText = textBeforeLine + newMarks + textFromLine.substring(currentMarks.length);
    final cursorOffset = (selection.end - currentMarks.length + newMarks.length).clamp(lineStart, formattedText.length);
    return TextEditingValue(text: formattedText, selection: TextSelection.collapsed(offset: cursorOffset));
  }

  /// Whether the cursor is inside a bold span.
  static bool isBold(TextEditingValue value) {
    return _findBoldSpanAt(value.text, _readSelection(value)) != null;
  }

  /// Whether the cursor is on a subheading line.
  static bool isSubheading(TextEditingValue value) {
    final lineStart = _findLineStart(value.text, _readSelection(value).start);
    return subheadingPattern.matchAsPrefix(value.text.substring(lineStart)) != null;
  }

  static TextEditingValue _wrapInBold(String text, TextSelection selection) {
    final selectedText = selection.textInside(text);
    final formattedText =
        selection.textBefore(text) + boldMark + selectedText + boldMark + selection.textAfter(text);
    final cursorOffset = selection.start + boldMark.length + selectedText.length;
    return TextEditingValue(text: formattedText, selection: TextSelection.collapsed(offset: cursorOffset));
  }

  static TextEditingValue _removeBold(String text, RegExpMatch boldSpan, int cursorOffset) {
    final boldText = boldSpan[1]!;
    final formattedText = text.replaceRange(boldSpan.start, boldSpan.end, boldText);
    final newCursorOffset =
        (cursorOffset - boldMark.length).clamp(boldSpan.start, boldSpan.start + boldText.length);
    return TextEditingValue(text: formattedText, selection: TextSelection.collapsed(offset: newCursorOffset));
  }

  /// Bold span that contains the cursor, between its marks.
  static RegExpMatch? _findBoldSpanAt(String text, TextSelection selection) {
    if (!selection.isCollapsed) return null;
    final cursorOffset = selection.start;
    for (final boldSpan in boldPattern.allMatches(text)) {
      if (boldSpan.start + boldMark.length <= cursorOffset && cursorOffset <= boldSpan.end - boldMark.length) {
        return boldSpan;
      }
    }
    return null;
  }

  static TextSelection _readSelection(TextEditingValue value) {
    if (value.selection.isValid) return value.selection;
    return TextSelection.collapsed(offset: value.text.length);
  }

  static int _findLineStart(String text, int offset) {
    if (offset == 0) return 0;
    return text.lastIndexOf('\n', offset - 1) + 1;
  }
}
