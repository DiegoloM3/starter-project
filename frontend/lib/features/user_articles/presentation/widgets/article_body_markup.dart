import 'dart:math';

import 'package:flutter/services.dart';

// The only formats the content editor produces, stored inline in the
// article's plain `content` string, so neither Firestore nor the domain
// layer has to know formatting exists.
const _boldMarker = '**';
const _headingPrefix = '## ';
const _bulletPrefix = '- ';
const _quotePrefix = '> ';
// dotAll: bolding a selection that crosses a line break wraps it in one
// pair, and that pair still has to render as bold.
final _boldPattern = RegExp(r'\*\*(.+?)\*\*', dotAll: true);
// A numbered line's own digits are part of its marker (unlike the other
// prefixes, which are always the same literal string) -- "1. ", "2. ",
// however many items came before it when the line was created.
//
// No leading `^`: every use matches via matchAsPrefix(text, start), which
// already anchors the match to begin exactly at `start` -- adding `^` on
// top doesn't reinforce that, it silently changes it, since `^` without
// the multiline flag anchors to the start of the whole string regardless
// of `start`. With it, a line's own numbered prefix was only ever found
// when that line happened to sit at the very beginning of the document
// (index 0) -- true for the first numbered item, never for the second
// line of the document onward, which is why every item past the very
// first pair silently reset the count back to 1 instead of continuing it.
final _numberedLinePattern = RegExp(r'(\d+)\. ');

enum SegmentStyle { plain, bold, marker }

enum LineType { plain, heading, bullet, numbered, quote }

final class TextSegment {
  final String text;
  final SegmentStyle style;

  const TextSegment(this.text, [this.style = SegmentStyle.plain]);

  bool get isBold => style == SegmentStyle.bold;
  bool get isMarker => style == SegmentStyle.marker;
}

/// One line of the body. [segments] keep every character of it, markers
/// included, so the lines join back into exactly the typed text: the editor
/// depends on that, since its cursor is an offset into that text.
final class BodyLine {
  final LineType type;
  final List<TextSegment> segments;

  const BodyLine({required this.type, required this.segments});

  bool get isHeading => type == LineType.heading;

  /// The line as a reader sees it, without its markers -- for [bullet],
  /// [numbered] and [quote] this is the text alone, with the structure
  /// (the dot, the number, the quote bar) added back by whatever's
  /// actually rendering the line, not carried in the text itself.
  Iterable<TextSegment> get visibleSegments =>
      segments.where((segment) => !segment.isMarker);
}

List<BodyLine> parseArticleBody(String content) {
  final lines = [<TextSegment>[]];
  for (final segment in _parseBold(content)) {
    // A bold run can cross a line break; each piece keeps its style.
    final pieces = segment.text.split('\n');
    lines.last.addAll(_toSegments(pieces.first, segment.style));
    for (final piece in pieces.skip(1)) {
      lines.add(_toSegments(piece, segment.style));
    }
  }
  return lines.map(_toBodyLine).toList();
}

String articleBodyToPlainText(String content) {
  return parseArticleBody(content)
      .map((line) => line.visibleSegments.map((segment) => segment.text).join())
      .join('\n');
}

/// Wraps the selection in bold markers, or removes them if it's already
/// wrapped. With nothing selected it inserts an empty pair with the cursor
/// between them, so whatever is typed next comes out bold.
TextEditingValue toggleBold(TextEditingValue value) {
  final selection = _selectionOrEnd(value);
  final text = value.text;
  if (_isWrappedInBold(text, selection)) {
    return TextEditingValue(
      text: text
          .replaceRange(selection.end, selection.end + _boldMarker.length, '')
          .replaceRange(selection.start - _boldMarker.length, selection.start, ''),
      selection: _shiftSelection(selection, -_boldMarker.length),
    );
  }
  final wrapped =
      '$_boldMarker${selection.textInside(text)}$_boldMarker';
  return TextEditingValue(
    text: text.replaceRange(selection.start, selection.end, wrapped),
    selection: _shiftSelection(selection, _boldMarker.length),
  );
}

/// Starts a subheading, bullet or quote line, or turns one back into plain
/// text:
/// - on a line that's already that kind, removes its prefix;
/// - with words selected on one line, moves them onto a line of their own
///   and makes that line the given kind;
/// - otherwise opens an empty line of that kind below the current paragraph
///   (or uses the current line, if it's blank), so nothing already written
///   changes kind by surprise.
TextEditingValue toggleSubheading(TextEditingValue value) =>
    _togglePrefix(value, _headingPrefix);

TextEditingValue toggleBulletList(TextEditingValue value) =>
    _togglePrefix(value, _bulletPrefix);

TextEditingValue toggleQuote(TextEditingValue value) =>
    _togglePrefix(value, _quotePrefix);

/// Same idea as [toggleSubheading], except the prefix isn't a fixed string:
/// a new numbered line takes the number after whatever the line right
/// above it was numbered, or 1 if it's the first (or the line above isn't
/// numbered). That number is written into the text once, at the moment the
/// line is created -- like the rest of this file, nothing here maintains a
/// live document model, so deleting an earlier item won't renumber the
/// ones after it. Good enough for a short news piece; the number is plain
/// text either way, so it's a one-second fix by hand if it ever matters.
TextEditingValue toggleNumberedList(TextEditingValue value) {
  final current = value.copyWith(selection: _selectionOrEnd(value));
  final line = _lineAround(current.text, current.selection.start);
  final existingLength = _numberedPrefixLength(current.text, line.start);
  if (existingLength > 0) {
    return _removePrefix(current, line, existingLength);
  }
  return _insertPrefixedLine(
    current,
    line,
    '${_nextListNumber(current.text, line.start)}. ',
  );
}

TextEditingValue _togglePrefix(TextEditingValue value, String prefix) {
  final current = value.copyWith(selection: _selectionOrEnd(value));
  final line = _lineAround(current.text, current.selection.start);
  if (current.text.startsWith(prefix, line.start)) {
    return _removePrefix(current, line, prefix.length);
  }
  return _insertPrefixedLine(current, line, prefix);
}

TextEditingValue _insertPrefixedLine(
  TextEditingValue value,
  TextRange line,
  String prefix,
) {
  final selectedWords = value.selection.textInside(value.text).trim();
  if (selectedWords.isNotEmpty && value.selection.end <= line.end) {
    return _moveToOwnPrefixedLine(value, line, prefix);
  }
  return _openPrefixedLine(value, line, prefix);
}

List<TextSegment> _parseBold(String content) {
  final segments = <TextSegment>[];
  var cursor = 0;
  for (final match in _boldPattern.allMatches(content)) {
    if (match.start > cursor) {
      segments.add(TextSegment(content.substring(cursor, match.start)));
    }
    segments.addAll([
      const TextSegment(_boldMarker, SegmentStyle.marker),
      TextSegment(match.group(1)!, SegmentStyle.bold),
      const TextSegment(_boldMarker, SegmentStyle.marker),
    ]);
    cursor = match.end;
  }
  if (cursor < content.length) {
    segments.add(TextSegment(content.substring(cursor)));
  }
  return segments;
}

List<TextSegment> _toSegments(String text, SegmentStyle style) {
  return [if (text.isNotEmpty) TextSegment(text, style)];
}

BodyLine _toBodyLine(List<TextSegment> segments) {
  final isPlainStart =
      segments.isNotEmpty && segments.first.style == SegmentStyle.plain;
  final text = isPlainStart ? segments.first.text : '';
  final numberedMatch = isPlainStart ? _numberedLinePattern.matchAsPrefix(text) : null;
  if (numberedMatch != null) {
    return _splitFirstSegment(segments, numberedMatch.group(0)!.length, LineType.numbered);
  }
  if (isPlainStart) {
    for (final (prefix, type) in const [
      (_headingPrefix, LineType.heading),
      (_bulletPrefix, LineType.bullet),
      (_quotePrefix, LineType.quote),
    ]) {
      if (text.startsWith(prefix)) {
        return _splitFirstSegment(segments, prefix.length, type);
      }
    }
  }
  return BodyLine(type: LineType.plain, segments: segments);
}

BodyLine _splitFirstSegment(
  List<TextSegment> segments,
  int prefixLength,
  LineType type,
) {
  final text = segments.first.text;
  return BodyLine(
    type: type,
    segments: [
      TextSegment(text.substring(0, prefixLength), SegmentStyle.marker),
      ..._toSegments(text.substring(prefixLength), SegmentStyle.plain),
      ...segments.skip(1),
    ],
  );
}

// A field that was never focused has no selection yet; format at the end.
TextSelection _selectionOrEnd(TextEditingValue value) {
  return value.selection.isValid
      ? value.selection
      : TextSelection.collapsed(offset: value.text.length);
}

bool _isWrappedInBold(String text, TextSelection selection) {
  return selection.start >= _boldMarker.length &&
      text.startsWith(_boldMarker, selection.start - _boldMarker.length) &&
      text.startsWith(_boldMarker, selection.end);
}

TextSelection _shiftSelection(TextSelection selection, int offset) {
  return TextSelection(
    baseOffset: selection.baseOffset + offset,
    extentOffset: selection.extentOffset + offset,
  );
}

TextRange _lineAround(String text, int offset) {
  final start = offset == 0 ? 0 : text.lastIndexOf('\n', offset - 1) + 1;
  final end = text.indexOf('\n', offset);
  return TextRange(start: start, end: end == -1 ? text.length : end);
}

int _numberedPrefixLength(String text, int lineStart) {
  final match = _numberedLinePattern.matchAsPrefix(text, lineStart);
  return match == null ? 0 : match.group(0)!.length;
}

int _nextListNumber(String text, int lineStart) {
  if (lineStart == 0) return 1;
  final previousLine = _lineAround(text, lineStart - 1);
  final match = _numberedLinePattern.matchAsPrefix(text, previousLine.start);
  return match == null ? 1 : int.parse(match.group(1)!) + 1;
}

TextEditingValue _removePrefix(
  TextEditingValue value,
  TextRange line,
  int prefixLength,
) {
  int shift(int offset) => max(line.start, offset - prefixLength);
  return TextEditingValue(
    text: value.text.replaceRange(line.start, line.start + prefixLength, ''),
    selection: TextSelection(
      baseOffset: shift(value.selection.baseOffset),
      extentOffset: shift(value.selection.extentOffset),
    ),
  );
}

/// Puts the selected words on a line of their own, prefixed as the given
/// kind, with the rest of the paragraph left on either side of it.
TextEditingValue _moveToOwnPrefixedLine(
  TextEditingValue value,
  TextRange line,
  String prefix,
) {
  final text = value.text;
  final before = text.substring(line.start, value.selection.start).trimRight();
  final content = value.selection.textInside(text).trim();
  final after = text.substring(value.selection.end, line.end).trimLeft();
  final contentStart =
      line.start + (before.isEmpty ? 0 : before.length + 1) + prefix.length;
  final replacement = [
    if (before.isNotEmpty) before,
    '$prefix$content',
    if (after.isNotEmpty) after,
  ].join('\n');
  return TextEditingValue(
    text: text.replaceRange(line.start, line.end, replacement),
    selection: TextSelection(
      baseOffset: contentStart,
      extentOffset: contentStart + content.length,
    ),
  );
}

TextEditingValue _openPrefixedLine(
  TextEditingValue value,
  TextRange line,
  String prefix,
) {
  // A blank line becomes the new kind; otherwise it goes on a new line
  // below this paragraph.
  final isBlank = line.textInside(value.text).trim().isEmpty;
  final range = isBlank ? line : TextRange.collapsed(line.end);
  final insertion = isBlank ? prefix : '\n$prefix';
  return TextEditingValue(
    text: value.text.replaceRange(range.start, range.end, insertion),
    selection: TextSelection.collapsed(offset: range.start + insertion.length),
  );
}
