import 'package:flutter/services.dart';

/// The result of a formatting action: the new text, and where the cursor
/// should end up.
class MarkdownEdit {
  final String text;
  final TextSelection selection;

  const MarkdownEdit({required this.text, required this.selection});
}

/// Turns a formatting button into an edit of the text.
///
/// This exists so that a journalist never has to know Markdown: they select a
/// few words, press **B**, and the syntax is written for them. Every action
/// toggles, so pressing the same button again takes the formatting back off —
/// the behaviour anybody already expects from a word processor.
abstract final class MarkdownEditing {
  /// Wraps the selection in [marker] — `**` for bold, `*` for italic — or
  /// unwraps it when it is already wrapped.
  ///
  /// With nothing selected it writes the pair and puts the cursor between
  /// them, so typing carries straight on inside the formatting.
  static MarkdownEdit toggleWrap(
    String text,
    TextSelection selection,
    String marker,
  ) {
    final start = selection.start;
    final end = selection.end;

    if (start < 0 || end > text.length) {
      return MarkdownEdit(text: text, selection: selection);
    }

    final markerLength = marker.length;
    final selected = text.substring(start, end);

    final alreadyWrappedInside = selected.length >= markerLength * 2 &&
        selected.startsWith(marker) &&
        selected.endsWith(marker);

    if (alreadyWrappedInside) {
      final bare = selected.substring(
        markerLength,
        selected.length - markerLength,
      );

      return MarkdownEdit(
        text: text.replaceRange(start, end, bare),
        selection: TextSelection(
          baseOffset: start,
          extentOffset: start + bare.length,
        ),
      );
    }

    final wrappedOutside = start >= markerLength &&
        end + markerLength <= text.length &&
        text.substring(start - markerLength, start) == marker &&
        text.substring(end, end + markerLength) == marker;

    if (wrappedOutside) {
      return MarkdownEdit(
        text: text.replaceRange(end, end + markerLength, '').replaceRange(
              start - markerLength,
              start,
              '',
            ),
        selection: TextSelection(
          baseOffset: start - markerLength,
          extentOffset: end - markerLength,
        ),
      );
    }

    return MarkdownEdit(
      text: text.replaceRange(start, end, '$marker$selected$marker'),
      selection: TextSelection(
        baseOffset: start + markerLength,
        extentOffset: start + markerLength + selected.length,
      ),
    );
  }

  /// Puts [prefix] — `## `, `- `, `> ` — at the start of the line the cursor
  /// is on, or takes it away when it is already there.
  static MarkdownEdit toggleLinePrefix(
    String text,
    TextSelection selection,
    String prefix,
  ) {
    final cursor = selection.start.clamp(0, text.length);
    final lineStart = text.lastIndexOf('\n', cursor > 0 ? cursor - 1 : 0) + 1;
    final line = text.substring(lineStart);
    final existing = _existingPrefixOf(line);

    if (existing == prefix) {
      return MarkdownEdit(
        text: text.replaceRange(lineStart, lineStart + prefix.length, ''),
        selection: _cursorAt(cursor - prefix.length, text.length),
      );
    }

    // A line already marked as something else is changed rather than stacked:
    // a heading that is also a bullet is not something anybody asked for.
    final offset = prefix.length - existing.length;

    return MarkdownEdit(
      text: text.replaceRange(lineStart, lineStart + existing.length, prefix),
      selection: _cursorAt(cursor + offset, text.length + offset),
    );
  }

  static const List<String> _knownPrefixes = ['### ', '## ', '# ', '- ', '> '];

  static String _existingPrefixOf(String line) {
    for (final prefix in _knownPrefixes) {
      if (line.startsWith(prefix)) {
        return prefix;
      }
    }

    return '';
  }

  static TextSelection _cursorAt(int offset, int length) {
    return TextSelection.collapsed(offset: offset.clamp(0, length));
  }
}
