import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_up.dart';

import '../../../../fixtures/test_fixtures.dart';
import '../../../../mocks/mocks.dart';

void main() {
  late SignUpUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = SignUpUseCase(mockAuthRepository);
  });

  group('SignUpUseCase', () {
    const testEmail = 'newuser@example.com';
    const testPassword = 'password123';
    const testDisplayName = 'New User';
    final testUser = TestFixtures.testUser;

    test('should return DataSuccess with user when sign up is successful',
        () async {
      // Arrange
      when(mockAuthRepository.signUp(
        email: testEmail,
        password: testPassword,
        displayName: testDisplayName,
      )).thenAnswer((_) async => DataSuccess(testUser));

      // Act
      final result = await useCase(
        params: const SignUpParams(
          email: testEmail,
          password: testPassword,
          displayName: testDisplayName,
        ),
      );

      // Assert
      expect(result, isA<DataSuccess>());
      expect((result as DataSuccess).data, testUser);
      verify(mockAuthRepository.signUp(
        email: testEmail,
        password: testPassword,
        displayName: testDisplayName,
      )).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return DataFailed when sign up fails', () async {
      // Arrange
      final exception = Exception('Email already exists');
      when(mockAuthRepository.signUp(
        email: testEmail,
        password: testPassword,
        displayName: testDisplayName,
      )).thenAnswer((_) async => DataFailed(exception));

      // Act
      final result = await useCase(
        params: const SignUpParams(
          email: testEmail,
          password: testPassword,
          displayName: testDisplayName,
        ),
      );

      // Assert
      expect(result, isA<DataFailed>());
      verify(mockAuthRepository.signUp(
        email: testEmail,
        password: testPassword,
        displayName: testDisplayName,
      )).called(1);
    });

    test('should return DataFailed when params is null', () async {
      // Act
      final result = await useCase(params: null);

      // Assert
      expect(result, isA<DataFailed>());
      verifyZeroInteractions(mockAuthRepository);
    });

    test('should pass all parameters correctly to repository', () async {
      // Arrange
      const email = 'custom@email.com';
      const password = 'customPassword';
      const displayName = 'Custom Name';

      when(mockAuthRepository.signUp(
        email: email,
        password: password,
        displayName: displayName,
      )).thenAnswer((_) async => DataSuccess(testUser));

      // Act
      await useCase(
        params: const SignUpParams(
          email: email,
          password: password,
          displayName: displayName,
        ),
      );

      // Assert - verify was called once
      verify(mockAuthRepository.signUp(
        email: email,
        password: password,
        displayName: displayName,
      )).called(1);
    });
  });
}
