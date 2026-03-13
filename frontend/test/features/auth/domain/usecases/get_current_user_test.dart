import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_current_user.dart';

import '../../../../fixtures/test_fixtures.dart';
import '../../../../mocks/mocks.dart';

void main() {
  late GetCurrentUserUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = GetCurrentUserUseCase(mockAuthRepository);
  });

  group('GetCurrentUserUseCase', () {
    final testUser = TestFixtures.testUser;

    test('should return UserEntity when user is authenticated', () async {
      // Arrange
      when(mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => testUser);

      // Act
      final result = await useCase();

      // Assert
      expect(result, isA<UserEntity>());
      expect(result, testUser);
      expect(result?.email, testUser.email);
      verify(mockAuthRepository.getCurrentUser()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return null when no user is authenticated', () async {
      // Arrange
      when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => null);

      // Act
      final result = await useCase();

      // Assert
      expect(result, isNull);
      verify(mockAuthRepository.getCurrentUser()).called(1);
    });

    test('should propagate exception when repository throws', () async {
      // Arrange
      when(mockAuthRepository.getCurrentUser())
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(() => useCase(), throwsException);
    });
  });
}
