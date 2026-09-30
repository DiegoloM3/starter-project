/// Plain-text views of an article's Markdown content, shared by the entities.
///
/// Keep in sync with deriveDescription() in backend/scripts/seed.mjs.

final _markdownImage = RegExp(r'!\[[^\]]*\]\([^)]*\)');
final _markdownLink = RegExp(r'\[([^\]]*)\]\([^)]*\)');
final _markdownLinePrefix = RegExp(r'^\s{0,3}(#{1,6}|>|[-*+]|\d+\.)\s+', multiLine: true);
final _markdownHeading = RegExp(r'^\s{0,3}#{1,6}\s+');
final _markdownBulletedItem = RegExp(r'^\s{0,3}[-*+]\s+');
final _markdownNumberedItem = RegExp(r'^\s{0,3}\d+\.\s+');
final _markdownInlineMarker = RegExp(r'(\*\*|__|\*|_|~~|`)');
final _whitespace = RegExp(r'\s+');

// Average silent reading speed of adults.
const int _wordsReadPerMinute = 200;

/// Words of the content, without Markdown syntax.
int wordCountOf(String markdown) {
  return markdownToPlainText(markdown).split(' ').where((word) => word.isNotEmpty).length;
}

/// Estimated minutes needed to read the content, at least 1.
int readingTimeInMinutesOf(String markdown) {
  final minutes = (wordCountOf(markdown) / _wordsReadPerMinute).ceil();
  return minutes < 1 ? 1 : minutes;
}

/// The content without Markdown syntax, on a single line.
String markdownToPlainText(String markdown) {
  return _stripMarkdown(markdown).replaceAll(_whitespace, ' ').trim();
}

enum PlainLineKind { heading, bulletedItem, numberedItem, paragraph }

class PlainTextLine {
  final String text;
  final PlainLineKind kind;

  const PlainTextLine(this.text, this.kind);
}

/// Every non-empty line of the content (heading, list item or paragraph) without Markdown syntax.
List<PlainTextLine> markdownToPlainLines(String markdown) {
  return markdown.split('\n').map(_toPlainLine).where((line) => line.text.isNotEmpty).toList();
}

PlainTextLine _toPlainLine(String line) {
  return PlainTextLine(_stripMarkdown(line).replaceAll(_whitespace, ' ').trim(), _kindOf(line));
}

PlainLineKind _kindOf(String line) {
  if (_markdownHeading.hasMatch(line)) return PlainLineKind.heading;
  if (_markdownBulletedItem.hasMatch(line)) return PlainLineKind.bulletedItem;
  if (_markdownNumberedItem.hasMatch(line)) return PlainLineKind.numberedItem;
  return PlainLineKind.paragraph;
}

String _stripMarkdown(String markdown) {
  return markdown
      .replaceAll(_markdownImage, '')
      .replaceAllMapped(_markdownLink, (match) => match[1]!)
      .replaceAll(_markdownLinePrefix, '')
      .replaceAll(_markdownInlineMarker, '');
}
