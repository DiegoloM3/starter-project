import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';

void main() {
  UserEntity userNamed(String name) => UserEntity(id: 'uid', name: name, email: 'jane@example.com');

  group('initials', () {
    test('are the first letters of the first and last names', () {
      expect(userNamed('Jane Doe').initials, 'JD');
      expect(userNamed('María José García López').initials, 'ML');
    });

    test('are a single letter for a single name', () {
      expect(userNamed('Jane').initials, 'J');
    });

    test('are upper case and ignore extra spaces', () {
      expect(userNamed('  jane   doe ').initials, 'JD');
    });

    test('use the first letter of the email when the account has no name', () {
      expect(userNamed('').initials, 'J');
    });
  });
}
