import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/auth/data/models/auth_user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';

class MockUser extends Mock implements User {}

class MockUserInfo extends Mock implements UserInfo {}

void main() {
  group('AuthUserModel', () {
    test('fromRawData maps fields and infers providerId from providerData',
        () {
      final mockUser = MockUser();
      final mockProvider = MockUserInfo();
      when(() => mockUser.uid).thenReturn('uid-123');
      when(() => mockUser.email).thenReturn('user@example.com');
      when(() => mockUser.displayName).thenReturn('Test User');
      when(() => mockUser.photoURL).thenReturn(null);
      when(() => mockUser.isAnonymous).thenReturn(false);
      when(() => mockProvider.providerId).thenReturn('google.com');
      when(() => mockUser.providerData).thenReturn([mockProvider]);

      final entity = AuthUserModel.fromRawData(mockUser).toEntity();

      expect(entity, isA<AuthUserEntity>());
      expect(entity.uid, 'uid-123');
      expect(entity.email, 'user@example.com');
      expect(entity.displayName, 'Test User');
      expect(entity.providerId, 'google.com');
      expect(entity.isAnonymous, isFalse);
    });

    test('fromRawData uses "anonymous" providerId when isAnonymous is true',
        () {
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('anon-123');
      when(() => mockUser.email).thenReturn(null);
      when(() => mockUser.displayName).thenReturn(null);
      when(() => mockUser.photoURL).thenReturn(null);
      when(() => mockUser.isAnonymous).thenReturn(true);
      when(() => mockUser.providerData).thenReturn([]);

      final entity = AuthUserModel.fromRawData(mockUser).toEntity();

      expect(entity.providerId, 'anonymous');
      expect(entity.isAnonymous, isTrue);
    });
  });
}
