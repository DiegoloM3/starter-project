import 'package:flutter/services.dart';

/// Text transformations behind the Markdown toolbar of the article editor.

/// Wraps the selection in [marker] (`**` for bold, `*` for italics), keeping it selected.
/// Without a selection it inserts both markers and leaves the cursor between them.
TextEditingValue wrapSelection(TextEditingValue value, String marker) {
  final selection = _selectionOrEndOf(value);
  final text = value.text;
  final selectedText = selection.textInside(text);
  final start = selection.start + marker.length;
  return TextEditingValue(
    text: '${selection.textBefore(text)}$marker$selectedText$marker${selection.textAfter(text)}',
    selection: TextSelection(baseOffset: start, extentOffset: start + selectedText.length),
  );
}

/// Adds [prefix] (`## ` for a subtitle, `- ` for a list) to every line touched by the selection.
/// When the field was never focused, starts a new line at the end.
TextEditingValue prefixSelectedLines(TextEditingValue value, String prefix) {
  if (!value.selection.isValid && value.text.isNotEmpty) {
    return _appendLine(value, prefix);
  }
  final selection = _selectionOrEndOf(value);
  final text = value.text;
  final firstLineStart = selection.start == 0 ? 0 : text.lastIndexOf('\n', selection.start - 1) + 1;
  final touchedLines = text.substring(firstLineStart, selection.end);
  final prefixedLines = touchedLines.split('\n').map((line) => '$prefix$line').join('\n');
  final addedLength = prefixedLines.length - touchedLines.length;
  return TextEditingValue(
    text: '${text.substring(0, firstLineStart)}$prefixedLines${text.substring(selection.end)}',
    selection: selection.isCollapsed
        ? TextSelection.collapsed(offset: selection.end + addedLength)
        : TextSelection(baseOffset: selection.start + prefix.length, extentOffset: selection.end + addedLength),
  );
}

TextEditingValue _appendLine(TextEditingValue value, String prefix) {
  final text = '${value.text}\n$prefix';
  return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
}

TextSelection _selectionOrEndOf(TextEditingValue value) {
  return value.selection.isValid ? value.selection : TextSelection.collapsed(offset: value.text.length);
}
