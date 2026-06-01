import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/auth/domain/repository/auth_repository.dart';
import 'package:tortutip/features/auth/domain/use_cases/sign_in_with_google_use_case.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignInWithGoogleUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInWithGoogleUseCase(mockRepository);
  });

  final tUser = UserEntity(
    id: 'user_1',
    name: 'Test User',
    email: 'test@example.com',
    avatarUrl: '',
    bio: '',
    role: 'reader',
    gender: '',
    ageRange: '',
    createdAt: DateTime(2024),
  );

  group('SignInWithGoogleUseCase', () {
    test('should_return_DataSuccess_with_UserEntity_when_repository_succeeds',
        () async {
      when(() => mockRepository.signInWithGoogle())
          .thenAnswer((_) async => DataSuccess(tUser));

      final result = await useCase(const NoParams());

      expect(result, isA<DataSuccess<UserEntity>>());
      expect(result.data, equals(tUser));
      verify(() => mockRepository.signInWithGoogle()).called(1);
    });

    test('should_return_DataFailed_when_repository_returns_failure', () async {
      final exception = Exception('Sign in failed');
      when(() => mockRepository.signInWithGoogle())
          .thenAnswer((_) async => DataFailed(exception));

      final result = await useCase(const NoParams());

      expect(result, isA<DataFailed<UserEntity>>());
      expect(result.error, equals(exception));
    });
  });
}
