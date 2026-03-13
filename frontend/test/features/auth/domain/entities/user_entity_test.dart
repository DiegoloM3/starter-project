import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';

void main() {
  group('UserEntity', () {
    final testUser = UserEntity(
      id: 'test-id',
      email: 'test@example.com',
      displayName: 'Test User',
      photoUrl: 'https://example.com/photo.jpg',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 2),
    );

    test('should create UserEntity with all properties', () {
      expect(testUser.id, 'test-id');
      expect(testUser.email, 'test@example.com');
      expect(testUser.displayName, 'Test User');
      expect(testUser.photoUrl, 'https://example.com/photo.jpg');
      expect(testUser.createdAt, DateTime(2024, 1, 1));
      expect(testUser.updatedAt, DateTime(2024, 1, 2));
    });

    test('should create UserEntity with nullable properties', () {
      const user = UserEntity();

      expect(user.id, isNull);
      expect(user.email, isNull);
      expect(user.displayName, isNull);
      expect(user.photoUrl, isNull);
      expect(user.createdAt, isNull);
      expect(user.updatedAt, isNull);
    });

    test('props should return all properties for Equatable', () {
      expect(testUser.props, [
        'test-id',
        'test@example.com',
        'Test User',
        'https://example.com/photo.jpg',
        DateTime(2024, 1, 1),
        DateTime(2024, 1, 2),
      ]);
    });

    test('two entities with same properties should be equal', () {
      final user1 = UserEntity(
        id: 'same-id',
        email: 'same@email.com',
      );
      final user2 = UserEntity(
        id: 'same-id',
        email: 'same@email.com',
      );

      expect(user1, equals(user2));
    });

    test('two entities with different properties should not be equal', () {
      final user1 = UserEntity(id: 'id-1');
      final user2 = UserEntity(id: 'id-2');

      expect(user1, isNot(equals(user2)));
    });
  });
}
