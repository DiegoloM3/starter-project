import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/shared/ui/presentation/markdown_editing.dart';

void main() {
  TextSelection select(int start, int end) =>
      TextSelection(baseOffset: start, extentOffset: end);

  TextSelection cursorAt(int offset) => TextSelection.collapsed(offset: offset);

  group('toggleWrap', () {
    test('wraps what is selected', () {
      final edit = MarkdownEditing.toggleWrap(
        'the night bus',
        select(4, 9),
        '**',
      );

      expect(edit.text, 'the **night** bus');
      // The same words stay selected, so pressing bold then italic works.
      expect(edit.text.substring(edit.selection.start, edit.selection.end),
          'night');
    });

    test('pressing the same button again takes the formatting off', () {
      final bold =
          MarkdownEditing.toggleWrap('the night bus', select(4, 9), '**');
      final plain = MarkdownEditing.toggleWrap(
        bold.text,
        bold.selection,
        '**',
      );

      expect(plain.text, 'the night bus');
      expect(plain.selection.start, 4);
    });

    test('unwraps when the markers sit just outside the selection', () {
      // What happens when somebody double-taps a bold word: the selection
      // covers the word, not its markers.
      final edit = MarkdownEditing.toggleWrap(
        'the **night** bus',
        select(6, 11),
        '**',
      );

      expect(edit.text, 'the night bus');
    });

    test('with nothing selected it opens the pair and waits inside', () {
      final edit = MarkdownEditing.toggleWrap('the ', cursorAt(4), '**');

      expect(edit.text, 'the ****');
      expect(edit.selection.start, 6);
      expect(edit.selection.isCollapsed, isTrue);
    });

    test('italic uses a single marker without disturbing bold', () {
      final edit = MarkdownEditing.toggleWrap('night', select(0, 5), '*');

      expect(edit.text, '*night*');
    });
  });

  group('toggleLinePrefix', () {
    test('marks the line the cursor is on', () {
      final edit = MarkdownEditing.toggleLinePrefix(
        'Intro\nThe depot opens',
        cursorAt(10),
        '## ',
      );

      expect(edit.text, 'Intro\n## The depot opens');
    });

    test('pressing again removes it', () {
      final edit = MarkdownEditing.toggleLinePrefix(
        '## The depot opens',
        cursorAt(5),
        '## ',
      );

      expect(edit.text, 'The depot opens');
    });

    test('replaces one kind of line with another instead of stacking them', () {
      // A heading that is also a bullet is not something anybody asked for.
      final edit = MarkdownEditing.toggleLinePrefix(
        '## The depot opens',
        cursorAt(5),
        '- ',
      );

      expect(edit.text, '- The depot opens');
    });

    test('works on the first line of the article', () {
      final edit = MarkdownEditing.toggleLinePrefix(
        'The depot opens',
        cursorAt(0),
        '> ',
      );

      expect(edit.text, '> The depot opens');
    });

    test('keeps the cursor on the same word it was on', () {
      final edit = MarkdownEditing.toggleLinePrefix(
        'The depot opens',
        cursorAt(4),
        '- ',
      );

      expect(edit.text, '- The depot opens');
      expect(edit.text[edit.selection.start], 'd');
    });
  });
}
