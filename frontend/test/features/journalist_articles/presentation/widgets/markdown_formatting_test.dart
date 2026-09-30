import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/widgets/markdown_formatting.dart';

TextEditingValue textWithSelection(String text, int start, [int? end]) {
  return TextEditingValue(text: text, selection: TextSelection(baseOffset: start, extentOffset: end ?? start));
}

void main() {
  group('wrapSelection', () {
    test('wraps the selected text and keeps it selected', () {
      final result = wrapSelection(textWithSelection('make this bold', 5, 9), '**');

      expect(result.text, 'make **this** bold');
      expect(result.selection, const TextSelection(baseOffset: 7, extentOffset: 11));
    });

    test('inserts empty markers and puts the cursor between them', () {
      final result = wrapSelection(textWithSelection('Hello ', 6), '*');

      expect(result.text, 'Hello **');
      expect(result.selection, const TextSelection.collapsed(offset: 7));
    });

    test('appends at the end when the field was never focused', () {
      const unfocused = TextEditingValue(text: 'Hello', selection: TextSelection.collapsed(offset: -1));

      expect(wrapSelection(unfocused, '**').text, 'Hello****');
    });
  });

  group('prefixSelectedLines', () {
    test('turns the line under the cursor into a heading', () {
      final result = prefixSelectedLines(textWithSelection('Intro\nSubtitle\nBody', 9), '## ');

      expect(result.text, 'Intro\n## Subtitle\nBody');
      expect(result.selection, const TextSelection.collapsed(offset: 12));
    });

    test('prefixes every selected line', () {
      final result = prefixSelectedLines(textWithSelection('one\ntwo\nthree', 0, 7), '- ');

      expect(result.text, '- one\n- two\nthree');
    });

    test('works on the first line', () {
      expect(prefixSelectedLines(textWithSelection('Title', 0), '## ').text, '## Title');
    });

    test('adds a new line at the end when the field was never focused', () {
      const unfocused = TextEditingValue(text: 'Body', selection: TextSelection.collapsed(offset: -1));

      expect(prefixSelectedLines(unfocused, '- ').text, 'Body\n- ');
    });
  });
}
