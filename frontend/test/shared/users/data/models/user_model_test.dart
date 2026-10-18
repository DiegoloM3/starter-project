import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/shared/users/data/models/user_model.dart';
import 'package:news_app_clean_architecture/shared/users/domain/entities/user.dart';

void main() {
  test('parses a profile document', () {
    final model = UserModel.fromRawData('user-1', {
      'firstName': 'Jane',
      'lastName': 'Doe',
      'bio': 'Journalist',
      'photoURL': 'https://example.com/photo.jpg',
      'role': 'journalist',
      'createdAt': DateTime(2026, 10, 16),
    });

    expect(
      model.toEntity(),
      const UserEntity(
        uid: 'user-1',
        firstName: 'Jane',
        lastName: 'Doe',
        bio: 'Journalist',
        photoURL: 'https://example.com/photo.jpg',
        role: UserRole.journalist,
      ),
    );
  });

  test('uses safe defaults for missing fields', () {
    final model = UserModel.fromRawData('user-1', {'firstName': 'Jane', 'lastName': 'Doe'});

    expect(model.bio, '');
    expect(model.photoURL, isNull);
    expect(model.role, UserRole.reader);
  });

  test('converts to a plain entity', () {
    final entity = UserModel.fromRawData('user-1', {'firstName': 'Jane', 'lastName': 'Doe'}).toEntity();

    expect(entity.runtimeType, UserEntity);
  });
}
