import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/auth/data/models/user.model.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.entity.dart';

void main() {
  const tUserModel = UserModel(
    id: 'uid-123',
    email: 'test@example.com',
    displayName: 'Test User',
    photoUrl: 'https://example.com/avatar.jpg',
    isAnonymous: false,
  );

  group('UserModel', () {
    test('fromJson should map all fields correctly', () {
      final json = {
        'id': 'uid-123',
        'email': 'test@example.com',
        'displayName': 'Test User',
        'photoUrl': 'https://example.com/avatar.jpg',
        'isAnonymous': false,
      };

      final result = UserModel.fromJson(json);

      expect(result.id, 'uid-123');
      expect(result.email, 'test@example.com');
      expect(result.displayName, 'Test User');
      expect(result.photoUrl, 'https://example.com/avatar.jpg');
      expect(result.isAnonymous, false);
    });

    test('toJson should serialize UserModel correctly', () {
      final json = tUserModel.toJson();

      expect(json['id'], 'uid-123');
      expect(json['email'], 'test@example.com');
      expect(json['displayName'], 'Test User');
      expect(json['photoUrl'], 'https://example.com/avatar.jpg');
      expect(json['isAnonymous'], false);
    });

    test('fromEntity should convert UserEntity to UserModel', () {
      const entity = UserEntity(
        id: 'uid-456',
        email: 'entity@example.com',
        displayName: 'Entity User',
        photoUrl: 'https://example.com/entity.jpg',
        isAnonymous: true,
      );

      final result = UserModel.fromEntity(entity);

      expect(result.id, entity.id);
      expect(result.email, entity.email);
      expect(result.displayName, entity.displayName);
      expect(result.photoUrl, entity.photoUrl);
      expect(result.isAnonymous, entity.isAnonymous);
    });

    test('equality should consider models with identical fields equal', () {
      const model1 = UserModel(id: '1', email: 'a@b.com');
      const model2 = UserModel(id: '1', email: 'a@b.com');

      expect(model1, equals(model2));
    });

    test('fromAuth should map Firebase field values without provider types',
        () {
      final result = UserModel.fromAuth(
        uid: 'uid-123',
        email: 'test@example.com',
        displayName: 'Test User',
        photoUrl: 'https://example.com/avatar.jpg',
        isAnonymous: false,
      );

      expect(result.id, 'uid-123');
      expect(result.email, 'test@example.com');
      expect(result.displayName, 'Test User');
      expect(result.photoUrl, 'https://example.com/avatar.jpg');
      expect(result.isAnonymous, false);
    });
  });
}
