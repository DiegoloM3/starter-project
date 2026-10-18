import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/shared/users/domain/entities/user.dart';

UserEntity buildUser({UserRole role = UserRole.reader}) {
  return UserEntity(uid: 'user-1', firstName: 'Jane', lastName: 'Doe', bio: '', role: role);
}

void main() {
  test('the full name joins the first and last name', () {
    expect(buildUser().fullName, 'Jane Doe');
  });

  test('a journalist can publish articles', () {
    expect(buildUser(role: UserRole.journalist).canPublishArticles, isTrue);
  });

  test('a reader cannot publish articles', () {
    expect(buildUser().canPublishArticles, isFalse);
  });

  group('UserRole.fromId', () {
    test('finds the role by its id', () {
      expect(UserRole.fromId('journalist'), UserRole.journalist);
    });

    test('defaults to reader for an unknown id', () {
      expect(UserRole.fromId('admin'), UserRole.reader);
    });
  });
}
