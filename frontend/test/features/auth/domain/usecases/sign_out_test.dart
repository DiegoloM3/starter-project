import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_out.dart';

import '../../../../mocks/mocks.dart';

void main() {
  late SignOutUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = SignOutUseCase(mockAuthRepository);
  });

  group('SignOutUseCase', () {
    test('should call repository signOut when executed', () async {
      // Arrange
      when(mockAuthRepository.signOut()).thenAnswer((_) async {});

      // Act
      await useCase();

      // Assert
      verify(mockAuthRepository.signOut()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should propagate exception when sign out fails', () async {
      // Arrange
      when(mockAuthRepository.signOut())
          .thenThrow(Exception('Sign out failed'));

      // Act & Assert
      expect(() => useCase(), throwsException);
      verify(mockAuthRepository.signOut()).called(1);
    });

    test('should complete successfully when repository succeeds', () async {
      // Arrange
      when(mockAuthRepository.signOut()).thenAnswer((_) async {});

      // Act & Assert
      await expectLater(useCase(), completes);
    });
  });
}
