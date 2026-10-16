import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/markdown_formatting.dart';

void main() {
  TextEditingValue buildValue(String text, {required int start, int? end}) {
    return TextEditingValue(text: text, selection: TextSelection(baseOffset: start, extentOffset: end ?? start));
  }

  group('MarkdownFormatting.toggleBold', () {
    test('wraps the selected text in bold marks', () {
      final value = MarkdownFormatting.toggleBold(buildValue('Breaking news today', start: 9, end: 13));

      expect(value.text, 'Breaking **news** today');
      expect(value.selection, const TextSelection.collapsed(offset: 15));
    });

    test('starts an empty bold span at the cursor', () {
      final value = MarkdownFormatting.toggleBold(buildValue('Breaking ', start: 9));

      expect(value.text, 'Breaking ****');
      expect(value.selection, const TextSelection.collapsed(offset: 11));
    });

    test('adds the marks at the end when the field has no cursor', () {
      const value = TextEditingValue(text: 'Text');

      expect(MarkdownFormatting.toggleBold(value).text, 'Text****');
    });

    test('moves the cursor after the bold span when it is at the end of its text', () {
      final value = MarkdownFormatting.toggleBold(buildValue('The **new** park', start: 9));

      expect(value.text, 'The **new** park');
      expect(value.selection, const TextSelection.collapsed(offset: 11));
    });

    test('removes the marks of the bold span that contains the cursor', () {
      final value = MarkdownFormatting.toggleBold(buildValue('The **new** park', start: 7));

      expect(value.text, 'The new park');
      expect(value.selection, const TextSelection.collapsed(offset: 5));
    });

    test('removes an empty bold span', () {
      final value = MarkdownFormatting.toggleBold(buildValue('Breaking ****', start: 11));

      expect(value.text, 'Breaking ');
      expect(value.selection, const TextSelection.collapsed(offset: 9));
    });
  });

  group('MarkdownFormatting.toggleSubheading', () {
    test('turns the line of the cursor into a subheading', () {
      final value = MarkdownFormatting.toggleSubheading(buildValue('Intro\nKey facts\nEnd', start: 9));

      expect(value.text, 'Intro\n## Key facts\nEnd');
      expect(value.selection, const TextSelection.collapsed(offset: 12));
    });

    test('works on the first line', () {
      expect(MarkdownFormatting.toggleSubheading(buildValue('Key facts', start: 0)).text, '## Key facts');
    });

    test('turns a subheading back into normal text', () {
      final value = MarkdownFormatting.toggleSubheading(buildValue('Intro\n## Key facts', start: 14));

      expect(value.text, 'Intro\nKey facts');
      expect(value.selection, const TextSelection.collapsed(offset: 11));
    });

    test('turns a heading of any level back into normal text', () {
      expect(MarkdownFormatting.toggleSubheading(buildValue('# Key facts', start: 5)).text, 'Key facts');
    });
  });

  group('MarkdownFormatting.isBold', () {
    test('is true when the cursor is inside a bold span', () {
      expect(MarkdownFormatting.isBold(buildValue('The **new** park', start: 7)), isTrue);
    });

    test('is false when the cursor is outside any bold span', () {
      expect(MarkdownFormatting.isBold(buildValue('The **new** park', start: 13)), isFalse);
    });
  });

  group('MarkdownFormatting.isSubheading', () {
    test('is true when the cursor is on a subheading line', () {
      expect(MarkdownFormatting.isSubheading(buildValue('Intro\n## Key facts', start: 12)), isTrue);
    });

    test('is false when the cursor is on a normal line', () {
      expect(MarkdownFormatting.isSubheading(buildValue('## Key facts\nIntro', start: 15)), isFalse);
    });
  });
}
