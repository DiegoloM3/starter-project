import 'package:flutter/material.dart';

import 'article_body_markup.dart';

/// Draws the body's formatting while it's being written: bold text in bold,
/// subheadings in the article's heading style, and the markers faded. Only
/// the look changes; the text stays exactly what was typed, markers
/// included, because the field's cursor and selection are offsets into it.
class ArticleBodyEditingController extends TextEditingController {
  ArticleBodyEditingController({super.text});

  // The keyboard's composing underline isn't drawn: it's cosmetic, and
  // drawing it would mean splitting segments at the composing range.
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final theme = Theme.of(context);
    final markerStyle = TextStyle(color: theme.colorScheme.outline);
    return TextSpan(
      style: style,
      children: [
        for (final (index, line) in parseArticleBody(text).indexed) ...[
          if (index > 0) const TextSpan(text: '\n'),
          TextSpan(
            style: _lineStyle(line.type, theme),
            children: [
              for (final segment in line.segments)
                TextSpan(
                  text: segment.text,
                  style: _styleFor(segment, markerStyle),
                ),
            ],
          ),
        ],
      ],
    );
  }

  static TextStyle? _lineStyle(LineType type, ThemeData theme) {
    return switch (type) {
      LineType.heading => theme.textTheme.headlineMedium,
      LineType.quote => const TextStyle(fontStyle: FontStyle.italic),
      LineType.plain || LineType.bullet || LineType.numbered => null,
    };
  }

  static TextStyle? _styleFor(TextSegment segment, TextStyle markerStyle) {
    return switch (segment.style) {
      SegmentStyle.plain => null,
      SegmentStyle.bold => const TextStyle(fontWeight: FontWeight.w700),
      SegmentStyle.marker => markerStyle,
    };
  }
}
