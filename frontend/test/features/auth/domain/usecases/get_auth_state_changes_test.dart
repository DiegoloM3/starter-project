import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_auth_state_changes.dart';

import '../../../../fixtures/test_fixtures.dart';
import '../../../../mocks/mocks.dart';

void main() {
  late GetAuthStateChangesUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = GetAuthStateChangesUseCase(mockAuthRepository);
  });

  group('GetAuthStateChangesUseCase', () {
    final testUser = TestFixtures.testUser;

    test('should return stream of auth state changes from repository', () {
      // Arrange
      final authStream =
          Stream<UserEntity?>.fromIterable([testUser, null, testUser]);
      when(mockAuthRepository.authStateChanges).thenAnswer((_) => authStream);

      // Act
      final result = useCase();

      // Assert
      expect(result, isA<Stream<UserEntity?>>());
      verify(mockAuthRepository.authStateChanges).called(1);
    });

    test('should emit user when authenticated', () async {
      // Arrange
      when(mockAuthRepository.authStateChanges)
          .thenAnswer((_) => Stream.value(testUser));

      // Act
      final result = useCase();

      // Assert
      await expectLater(result, emits(testUser));
    });

    test('should emit null when user signs out', () async {
      // Arrange
      when(mockAuthRepository.authStateChanges)
          .thenAnswer((_) => Stream.value(null));

      // Act
      final result = useCase();

      // Assert
      await expectLater(result, emits(null));
    });

    test('should emit sequence of auth state changes', () async {
      // Arrange
      when(mockAuthRepository.authStateChanges).thenAnswer(
        (_) => Stream.fromIterable([null, testUser, null]),
      );

      // Act
      final result = useCase();

      // Assert
      await expectLater(
        result,
        emitsInOrder([null, testUser, null]),
      );
    });

    test('should handle stream errors', () async {
      // Arrange
      when(mockAuthRepository.authStateChanges).thenAnswer(
        (_) => Stream.error(Exception('Stream error')),
      );

      // Act
      final result = useCase();

      // Assert
      await expectLater(result, emitsError(isA<Exception>()));
    });
  });
}
