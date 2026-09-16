import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';

/// Text with every case-insensitive occurrence of [query] marked in the
/// lilac container, like a `<mark>`.
class HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle style;
  final int? maxLines;

  const HighlightedText({
    super.key,
    required this.text,
    required this.query,
    required this.style,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) {
      return Text(text, style: style, maxLines: maxLines, overflow: maxLines == null ? null : TextOverflow.ellipsis);
    }

    final palette = context.palette;
    final lower = text.toLowerCase();
    final spans = <TextSpan>[];
    var start = 0;
    while (true) {
      final at = lower.indexOf(needle, start);
      if (at < 0) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (at > start) spans.add(TextSpan(text: text.substring(start, at)));
      spans.add(TextSpan(
        text: text.substring(at, at + needle.length),
        style: TextStyle(backgroundColor: palette.primaryContainer),
      ));
      start = at + needle.length;
    }

    return Text.rich(
      TextSpan(style: style, children: spans),
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
    );
  }
}
