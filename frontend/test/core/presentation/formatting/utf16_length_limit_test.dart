import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/presentation/formatting/utf16_length_limit.dart';

TextEditingValue _value(String text) => TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );

String _edit(int maxLength, String from, String to) {
  return Utf16LengthLimitingTextInputFormatter(maxLength)
      .formatEditUpdate(_value(from), _value(to))
      .text;
}

void main() {
  test('an emoji counts as 2, the unit firestore.rules measures in', () {
    // 'ab' + an emoji is 4 units: one over a limit of 3, so it's dropped.
    expect(_edit(3, 'ab', 'ab\u{1F600}'), 'ab');
    expect(_edit(4, 'ab', 'ab\u{1F600}'), 'ab\u{1F600}');
  });

  test('an over-long paste keeps the whole characters that fit, never half '
      'an emoji', () {
    expect(_edit(5, '', 'abc\u{1F600}de'), 'abc\u{1F600}');
    expect(_edit(4, '', 'abc\u{1F600}de'), 'abc');
  });

  test('at the limit, typing more is refused', () {
    expect(_edit(3, 'abc', 'abcd'), 'abc');
  });

  test('text already over the limit can still be edited back down', () {
    expect(_edit(3, 'abcdef', 'abcde'), 'abcde');
  });

  test('accented letters count as 1, like plain ones', () {
    expect(_edit(3, '', 'áéí'), 'áéí');
  });
}
