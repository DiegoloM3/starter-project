import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/shared/presentation/formatters/initials_formatter.dart';

void main() {
  test('takes the first letter of the first two words, upper-cased', () {
    expect(InitialsFormatter.of('miriam hale'), 'MH');
    expect(InitialsFormatter.of('Ada Lovelace King'), 'AL');
  });

  test('a single word gives one letter', () {
    expect(InitialsFormatter.of('Ada'), 'A');
  });

  test('ignores extra whitespace and falls back on empty names', () {
    expect(InitialsFormatter.of('  Ada   Lovelace  '), 'AL');
    expect(InitialsFormatter.of('   '), '?');
  });
}
