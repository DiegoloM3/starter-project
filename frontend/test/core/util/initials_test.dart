import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/util/initials.dart';

void main() {
  test('takes the first letters of the first and last names', () {
    expect(initialsOf('Jane Doe'), 'JD');
    expect(initialsOf('María José García López'), 'ML');
  });

  test('takes a single letter of a single name', () {
    expect(initialsOf('Jane'), 'J');
  });

  test('is upper case and ignores extra spaces', () {
    expect(initialsOf('  jane   doe '), 'JD');
  });

  test('is empty for a blank name', () {
    expect(initialsOf(''), '');
    expect(initialsOf('   '), '');
  });
}
