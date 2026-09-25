import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/widgets/article_body_markup.dart';

void main() {
  group('parseArticleBody', () {
    test('turns a "## " line into a subheading', () {
      final lines = parseArticleBody('## The storm\nHeavy rain');

      expect(lines[0].isHeading, isTrue);
      expect(_visibleText(lines[0]), 'The storm');
      expect(lines[1].isHeading, isFalse);
    });

    test('splits **bold** runs into bold segments', () {
      final line = parseArticleBody('Rain **this morning**, then sun').single;

      expect(
        line.visibleSegments.map((segment) => (segment.text, segment.isBold)),
        [('Rain ', false), ('this morning', true), (', then sun', false)],
      );
    });

    test('leaves an unclosed marker as literal text', () {
      final segment =
          parseArticleBody('5 ** 2 is not closed').single.segments.single;

      expect(segment.text, '5 ** 2 is not closed');
      expect(segment.isBold, isFalse);
    });

    test('keeps a bold run that crosses a line break bold on both lines', () {
      final lines = parseArticleBody('**One\nTwo**');

      expect(
        lines.map((line) => line.visibleSegments.single.isBold),
        [true, true],
      );
    });

    test('shows bold inside a subheading without its markers', () {
      final line = parseArticleBody('## A **big** day').single;

      expect(line.isHeading, isTrue);
      expect(_visibleText(line), 'A big day');
    });

    test('keeps every character, so the lines join back into the text', () {
      const bodies = [
        '## A **b** c\n\nplain **x',
        '',
        '## ',
        '**One\nTwo**',
        'a\n',
      ];

      for (final body in bodies) {
        final rejoined = parseArticleBody(body)
            .map((line) => line.segments.map((segment) => segment.text).join())
            .join('\n');
        expect(rejoined, body);
      }
    });
  });

  test('articleBodyToPlainText strips every marker and keeps line breaks', () {
    expect(
      articleBodyToPlainText('## Title\nA **bold** word\n\nEnd'),
      'Title\nA bold word\n\nEnd',
    );
  });

  group('toggleBold', () {
    test('wraps the selection and keeps the same words selected', () {
      const value = TextEditingValue(
        text: 'a word here',
        selection: TextSelection(baseOffset: 2, extentOffset: 6),
      );

      final result = toggleBold(value);

      expect(result.text, 'a **word** here');
      expect(result.selection.textInside(result.text), 'word');
    });

    test('unwraps a selection that is already bold', () {
      const value = TextEditingValue(
        text: 'a **word** here',
        selection: TextSelection(baseOffset: 4, extentOffset: 8),
      );

      final result = toggleBold(value);

      expect(result.text, 'a word here');
      expect(result.selection.textInside(result.text), 'word');
    });

    test('with nothing selected, inserts a pair with the cursor inside', () {
      const value = TextEditingValue(
        text: 'ab',
        selection: TextSelection.collapsed(offset: 1),
      );

      final result = toggleBold(value);

      expect(result.text, 'a****b');
      expect(result.selection, const TextSelection.collapsed(offset: 3));
    });

    test('formats at the end when the field was never focused', () {
      const value = TextEditingValue(text: 'ab');

      expect(toggleBold(value).text, 'ab****');
    });
  });

  group('toggleSubheading', () {
    test('at the end of a paragraph, opens a subheading line below it', () {
      const value = TextEditingValue(
        text: 'Storm hits.',
        selection: TextSelection.collapsed(offset: 11),
      );

      final result = toggleSubheading(value);

      expect(result.text, 'Storm hits.\n## ');
      expect(result.selection, const TextSelection.collapsed(offset: 15));
    });

    test('in the middle of a paragraph, leaves the paragraph as it was', () {
      const value = TextEditingValue(
        text: 'Storm hits.\nMore',
        selection: TextSelection.collapsed(offset: 3),
      );

      expect(toggleSubheading(value).text, 'Storm hits.\n## \nMore');
    });

    test('on an empty line, makes that line the subheading', () {
      const value = TextEditingValue(
        text: 'Storm hits.\n',
        selection: TextSelection.collapsed(offset: 12),
      );

      final result = toggleSubheading(value);

      expect(result.text, 'Storm hits.\n## ');
      expect(result.selection, const TextSelection.collapsed(offset: 15));
    });

    test('moves the selected words onto their own subheading line', () {
      const value = TextEditingValue(
        text: 'Power is back. What happens next',
        selection: TextSelection(baseOffset: 15, extentOffset: 32),
      );

      final result = toggleSubheading(value);

      expect(result.text, 'Power is back.\n## What happens next');
      expect(result.selection.textInside(result.text), 'What happens next');
    });

    test('splits the paragraph around words selected in its middle', () {
      const value = TextEditingValue(
        text: 'The storm hit the coast',
        selection: TextSelection(baseOffset: 4, extentOffset: 9),
      );

      expect(toggleSubheading(value).text, 'The\n## storm\nhit the coast');
    });

    test('removes the prefix when the line is already a subheading', () {
      const value = TextEditingValue(
        text: '## Title',
        selection: TextSelection.collapsed(offset: 5),
      );

      final result = toggleSubheading(value);

      expect(result.text, 'Title');
      expect(result.selection, const TextSelection.collapsed(offset: 2));
    });

    test('opens the line at the end when the field was never focused', () {
      const value = TextEditingValue(text: 'ab');

      expect(toggleSubheading(value).text, 'ab\n## ');
    });
  });

  group('toggleBulletList', () {
    test('opens a bullet line below the current paragraph', () {
      const value = TextEditingValue(
        text: 'Intro.',
        selection: TextSelection.collapsed(offset: 6),
      );

      final result = toggleBulletList(value);

      expect(result.text, 'Intro.\n- ');
      expect(result.selection, const TextSelection.collapsed(offset: 9));
    });

    test('removes the prefix when the line is already a bullet', () {
      const value = TextEditingValue(
        text: '- Milk',
        selection: TextSelection.collapsed(offset: 3),
      );

      expect(toggleBulletList(value).text, 'Milk');
    });

    test('parses as a bullet line, marker excluded from the visible text',
        () {
      final line = parseArticleBody('- Milk').single;

      expect(line.type, LineType.bullet);
      expect(_visibleText(line), 'Milk');
    });
  });

  group('toggleQuote', () {
    test('opens a quote line below the current paragraph', () {
      const value = TextEditingValue(
        text: 'Intro.',
        selection: TextSelection.collapsed(offset: 6),
      );

      expect(toggleQuote(value).text, 'Intro.\n> ');
    });

    test('parses as a quote line, marker excluded from the visible text', () {
      final line = parseArticleBody('> Stay safe').single;

      expect(line.type, LineType.quote);
      expect(_visibleText(line), 'Stay safe');
    });
  });

  group('toggleNumberedList', () {
    test('the first item in a section starts at 1', () {
      const value = TextEditingValue(
        text: 'Steps:',
        selection: TextSelection.collapsed(offset: 6),
      );

      expect(toggleNumberedList(value).text, 'Steps:\n1. ');
    });

    test('a second item right after a numbered one continues the count', () {
      const value = TextEditingValue(
        text: '1. First',
        selection: TextSelection.collapsed(offset: 8),
      );
      // Opening a new line below "1. First" the same way the toolbar does:
      // press Enter, then toggle again.
      final withNewLine = TextEditingValue(
        text: '${value.text}\n',
        selection: const TextSelection.collapsed(offset: 9),
      );

      expect(toggleNumberedList(withNewLine).text, '1. First\n2. ');
    });

    test('a line right after a non-numbered one starts back at 1', () {
      const value = TextEditingValue(
        text: '1. First\nA plain line\n',
        selection: TextSelection.collapsed(offset: 22),
      );

      expect(toggleNumberedList(value).text, '1. First\nA plain line\n1. ');
    });

    test(
        'a third item keeps counting from the second, not just the first -- '
        'regression: matchAsPrefix(text, start) already anchors at start; a '
        'stray `^` in the pattern silently re-anchored it to the start of '
        'the whole text instead, so this only ever worked when the line '
        'being checked happened to sit at index 0', () {
      const value = TextEditingValue(
        text: '1. First\n2. Second',
        selection: TextSelection.collapsed(offset: 18),
      );
      final withNewLine = TextEditingValue(
        text: '${value.text}\n',
        selection: const TextSelection.collapsed(offset: 19),
      );

      expect(
        toggleNumberedList(withNewLine).text,
        '1. First\n2. Second\n3. ',
      );
    });

    test('removes the prefix (digits included) when already numbered', () {
      const value = TextEditingValue(
        text: '12. A dozen',
        selection: TextSelection.collapsed(offset: 6),
      );

      expect(toggleNumberedList(value).text, 'A dozen');
    });

    test('removes the prefix on a later line too, not just the first one',
        () {
      const value = TextEditingValue(
        text: '1. First\n2. Second',
        selection: TextSelection.collapsed(offset: 15),
      );

      expect(toggleNumberedList(value).text, '1. First\nSecond');
    });

    test('parses as a numbered line, digits excluded from the visible text',
        () {
      final line = parseArticleBody('3. Third item').single;

      expect(line.type, LineType.numbered);
      expect(_visibleText(line), 'Third item');
    });
  });
}

String _visibleText(BodyLine line) =>
    line.visibleSegments.map((segment) => segment.text).join();
