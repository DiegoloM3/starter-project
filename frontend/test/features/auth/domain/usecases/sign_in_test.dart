import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in.dart';

import '../../../../fixtures/test_fixtures.dart';
import '../../../../mocks/mocks.dart';

void main() {
  late SignInUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = SignInUseCase(mockAuthRepository);
  });

  group('SignInUseCase', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';
    final testUser = TestFixtures.testUser;

    test('should return DataSuccess with user when sign in is successful',
        () async {
      // Arrange
      when(mockAuthRepository.signIn(
        email: testEmail,
        password: testPassword,
      )).thenAnswer((_) async => DataSuccess(testUser));

      // Act
      final result = await useCase(
        params: const SignInParams(email: testEmail, password: testPassword),
      );

      // Assert
      expect(result, isA<DataSuccess>());
      expect((result as DataSuccess).data, testUser);
      verify(mockAuthRepository.signIn(
        email: testEmail,
        password: testPassword,
      )).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return DataFailed when sign in fails', () async {
      // Arrange
      final exception = Exception('Invalid credentials');
      when(mockAuthRepository.signIn(
        email: testEmail,
        password: testPassword,
      )).thenAnswer((_) async => DataFailed(exception));

      // Act
      final result = await useCase(
        params: const SignInParams(email: testEmail, password: testPassword),
      );

      // Assert
      expect(result, isA<DataFailed>());
      verify(mockAuthRepository.signIn(
        email: testEmail,
        password: testPassword,
      )).called(1);
    });

    test('should return DataFailed when params is null', () async {
      // Act
      final result = await useCase(params: null);

      // Assert
      expect(result, isA<DataFailed>());
      verifyZeroInteractions(mockAuthRepository);
    });

    test('should pass correct parameters to repository', () async {
      // Arrange
      const email = 'specific@email.com';
      const password = 'specificPassword';
      when(mockAuthRepository.signIn(
        email: email,
        password: password,
      )).thenAnswer((_) async => DataSuccess(testUser));

      // Act
      await useCase(
          params: const SignInParams(email: email, password: password));

      // Assert - verify was called once
      verify(mockAuthRepository.signIn(
        email: email,
        password: password,
      )).called(1);
    });
  });
}
