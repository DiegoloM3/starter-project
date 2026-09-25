import 'package:flutter/material.dart';

import 'article_body_markup.dart';

class ArticleBodyText extends StatelessWidget {
  final String content;

  const ArticleBodyText({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bodyStyle =
        theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface);
    final headingStyle =
        theme.textTheme.headlineMedium?.copyWith(color: colorScheme.onSurface);
    final lines = parseArticleBody(content);
    // Every numbered line was given its number back when it was written
    // (see toggleNumberedList), which goes stale the moment an earlier
    // item is deleted. Recount from scratch here instead of trusting it,
    // so the published piece always reads 1, 2, 3 -- a run of consecutive
    // numbered lines shares one count, and anything else resets it.
    var numberedRun = 0;
    final children = <Widget>[];
    for (final line in lines) {
      if (line.type == LineType.numbered) {
        children.add(_NumberedLine(
          number: ++numberedRun,
          text: _text(line),
          style: bodyStyle,
        ));
        continue;
      }
      numberedRun = 0;
      children.add(switch (line.type) {
        LineType.heading => Padding(
            // Air above a subheading sets it apart from the text before it.
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Text.rich(_span(line, headingStyle)),
          ),
        LineType.bullet => _BulletLine(text: _text(line), style: bodyStyle),
        LineType.quote => _QuoteLine(
            text: _text(line),
            style: bodyStyle,
            color: colorScheme.primary,
          ),
        LineType.plain || LineType.numbered => Text.rich(_span(line, bodyStyle)),
      });
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }

  // The rich TextSpan (keeps inline bold), for lines rendered as plain
  // running text rather than one of the structured kinds below.
  TextSpan _span(BodyLine line, TextStyle? style) {
    return TextSpan(
      style: style,
      children: [
        for (final segment in line.visibleSegments)
          TextSpan(
            text: segment.text,
            style: segment.isBold
                ? const TextStyle(fontWeight: FontWeight.w700)
                : null,
          ),
      ],
    );
  }

  String _text(BodyLine line) =>
      line.visibleSegments.map((segment) => segment.text).join();
}

class _BulletLine extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const _BulletLine({required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 20, child: Text('•', style: style)),
          Expanded(child: Text(text, style: style)),
        ],
      ),
    );
  }
}

class _NumberedLine extends StatelessWidget {
  final int number;
  final String text;
  final TextStyle? style;

  const _NumberedLine({
    required this.number,
    required this.text,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 24, child: Text('$number.', style: style)),
          Expanded(child: Text(text, style: style)),
        ],
      ),
    );
  }
}

class _QuoteLine extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color color;

  const _QuoteLine({required this.text, required this.style, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.only(left: 12),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: color, width: 3)),
        ),
        child: Text(text, style: style?.copyWith(fontStyle: FontStyle.italic)),
      ),
    );
  }
}
