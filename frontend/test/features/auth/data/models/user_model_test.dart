import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/auth/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    final testCreatedAt = DateTime(2024, 1, 1, 12, 0, 0);
    final testUpdatedAt = DateTime(2024, 1, 2, 12, 0, 0);

    final testUserModel = UserModel(
      id: 'user123',
      email: 'test@example.com',
      displayName: 'Test User',
      photoUrl: 'https://example.com/photo.jpg',
      createdAt: testCreatedAt,
      updatedAt: testUpdatedAt,
    );

    final testJson = {
      'id': 'user123',
      'email': 'test@example.com',
      'displayName': 'Test User',
      'photoUrl': 'https://example.com/photo.jpg',
      'createdAt': Timestamp.fromDate(testCreatedAt),
      'updatedAt': Timestamp.fromDate(testUpdatedAt),
    };

    group('fromJson', () {
      test('should create UserModel from JSON with Timestamp dates', () {
        // Act
        final result = UserModel.fromJson(testJson);

        // Assert
        expect(result.id, 'user123');
        expect(result.email, 'test@example.com');
        expect(result.displayName, 'Test User');
        expect(result.photoUrl, 'https://example.com/photo.jpg');
        expect(result.createdAt, testCreatedAt);
        expect(result.updatedAt, testUpdatedAt);
      });

      test('should create UserModel from JSON with String dates', () {
        // Arrange
        final jsonWithStringDates = {
          'id': 'user123',
          'email': 'test@example.com',
          'displayName': 'Test User',
          'photoUrl': 'https://example.com/photo.jpg',
          'createdAt': testCreatedAt.toIso8601String(),
          'updatedAt': testUpdatedAt.toIso8601String(),
        };

        // Act
        final result = UserModel.fromJson(jsonWithStringDates);

        // Assert
        expect(result.id, 'user123');
        expect(result.email, 'test@example.com');
        expect(result.createdAt, testCreatedAt);
        expect(result.updatedAt, testUpdatedAt);
      });

      test('should handle null optional fields', () {
        // Arrange
        final minimalJson = {
          'id': 'user123',
          'email': 'test@example.com',
        };

        // Act
        final result = UserModel.fromJson(minimalJson);

        // Assert
        expect(result.id, 'user123');
        expect(result.email, 'test@example.com');
        expect(result.displayName, isNull);
        expect(result.photoUrl, isNull);
        expect(result.createdAt, isNull);
        expect(result.updatedAt, isNull);
      });
    });

    group('toJson', () {
      test('should convert UserModel to JSON', () {
        // Act
        final result = testUserModel.toJson();

        // Assert
        expect(result['id'], 'user123');
        expect(result['email'], 'test@example.com');
        expect(result['displayName'], 'Test User');
        expect(result['photoUrl'], 'https://example.com/photo.jpg');
        expect(result['createdAt'], isA<Timestamp>());
        expect(result['updatedAt'], isA<Timestamp>());
      });

      test('should handle null dates in toJson', () {
        // Arrange
        const modelWithNullDates = UserModel(
          id: 'user123',
          email: 'test@example.com',
          displayName: 'Test User',
        );

        // Act
        final result = modelWithNullDates.toJson();

        // Assert
        expect(result['id'], 'user123');
        expect(result['email'], 'test@example.com');
        expect(result['createdAt'], isNull);
        expect(result['updatedAt'], isNull);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        // Act
        final result = testUserModel.copyWith(
          displayName: 'New Name',
          photoUrl: 'https://new.com/photo.jpg',
        );

        // Assert
        expect(result.id, 'user123');
        expect(result.email, 'test@example.com');
        expect(result.displayName, 'New Name');
        expect(result.photoUrl, 'https://new.com/photo.jpg');
        expect(result.createdAt, testCreatedAt);
      });

      test('should create exact copy when no arguments provided', () {
        // Act
        final result = testUserModel.copyWith();

        // Assert
        expect(result.id, testUserModel.id);
        expect(result.email, testUserModel.email);
        expect(result.displayName, testUserModel.displayName);
        expect(result.photoUrl, testUserModel.photoUrl);
        expect(result.createdAt, testUserModel.createdAt);
        expect(result.updatedAt, testUserModel.updatedAt);
      });

      test('should update all fields when all arguments provided', () {
        // Arrange
        final newCreatedAt = DateTime(2024, 6, 1);
        final newUpdatedAt = DateTime(2024, 6, 2);

        // Act
        final result = testUserModel.copyWith(
          id: 'newId',
          email: 'new@example.com',
          displayName: 'New Name',
          photoUrl: 'https://new.com/photo.jpg',
          createdAt: newCreatedAt,
          updatedAt: newUpdatedAt,
        );

        // Assert
        expect(result.id, 'newId');
        expect(result.email, 'new@example.com');
        expect(result.displayName, 'New Name');
        expect(result.photoUrl, 'https://new.com/photo.jpg');
        expect(result.createdAt, newCreatedAt);
        expect(result.updatedAt, newUpdatedAt);
      });
    });

    group('equality', () {
      test('two UserModels with same values should be equal', () {
        // Arrange
        final model1 = UserModel(
          id: 'user123',
          email: 'test@example.com',
          displayName: 'Test User',
          createdAt: testCreatedAt,
        );
        final model2 = UserModel(
          id: 'user123',
          email: 'test@example.com',
          displayName: 'Test User',
          createdAt: testCreatedAt,
        );

        // Assert
        expect(model1, equals(model2));
      });

      test('two UserModels with different values should not be equal', () {
        // Arrange
        const model1 = UserModel(
          id: 'user123',
          email: 'test@example.com',
        );
        const model2 = UserModel(
          id: 'user456',
          email: 'test@example.com',
        );

        // Assert
        expect(model1, isNot(equals(model2)));
      });
    });

    group('inheritance', () {
      test('UserModel should extend UserEntity', () {
        // Assert
        expect(testUserModel, isA<UserModel>());
        // Verify it has all UserEntity properties
        expect(testUserModel.id, isNotNull);
        expect(testUserModel.email, isNotNull);
      });
    });
  });
}
