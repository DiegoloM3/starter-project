import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/markdown_text.dart';

void main() {
  group('markdownToPlainText', () {
    test('removes headings, lists, quotes and inline markers, on a single line', () {
      const markdown = '## Title\n\n**Bold**, *italic*, ~~gone~~ and `code`.\n\n- one\n1. two\n> quote';

      expect(markdownToPlainText(markdown), 'Title Bold, italic, gone and code. one two quote');
    });

    test('keeps the text of links and drops images', () {
      expect(
        markdownToPlainText('See [the report](https://example.com) ![chart](https://example.com/c.png)'),
        'See the report',
      );
    });
  });

  group('markdownToPlainLines', () {
    test('tells headings, bulleted items, numbered items and paragraphs apart', () {
      final lines = markdownToPlainLines('# Heading\n\n- Bullet\n* Star\n3. Numbered\nParagraph with **bold**');

      expect(lines.map((line) => (line.text, line.kind)), [
        ('Heading', PlainLineKind.heading),
        ('Bullet', PlainLineKind.bulletedItem),
        ('Star', PlainLineKind.bulletedItem),
        ('Numbered', PlainLineKind.numberedItem),
        ('Paragraph with bold', PlainLineKind.paragraph),
      ]);
    });

    test('skips empty lines and lines that were only an image', () {
      final lines = markdownToPlainLines('One\n\n   \n![photo](https://example.com/p.jpg)\nTwo');

      expect(lines.map((line) => line.text), ['One', 'Two']);
    });

    test('does not take emphasis at the start of a line for a list item', () {
      expect(markdownToPlainLines('*Italic* start').single.kind, PlainLineKind.paragraph);
    });
  });

  group('wordCountOf', () {
    test('counts the words of the text, not the Markdown symbols', () {
      expect(wordCountOf('## Two words\n\n- **three** more words'), 5);
    });

    test('is zero for empty or blank content', () {
      expect(wordCountOf(''), 0);
      expect(wordCountOf(' \n\n '), 0);
    });
  });

  group('readingTimeInMinutesOf', () {
    test('rounds up at 200 words per minute, with a minimum of one', () {
      expect(readingTimeInMinutesOf(''), 1);
      expect(readingTimeInMinutesOf('word ' * 200), 1);
      expect(readingTimeInMinutesOf('word ' * 201), 2);
    });
  });
}
