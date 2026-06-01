import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';
import 'package:tortutip/shared/user/domain/repository/user_repository.dart';
import 'package:tortutip/shared/user/domain/use_cases/get_current_user_use_case.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late GetCurrentUserUseCase useCase;
  late MockUserRepository mockRepository;

  final user = UserEntity(
    id: 'user_1',
    name: 'Test',
    email: 'test@test.com',
    avatarUrl: '',
    bio: '',
    role: 'reader',
    gender: '',
    ageRange: '',
    createdAt: DateTime(2024),
  );

  setUp(() {
    mockRepository = MockUserRepository();
    useCase = GetCurrentUserUseCase(mockRepository);
  });

  group('GetCurrentUserUseCase', () {
    test('should_return_DataSuccess_with_user_when_session_exists', () async {
      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => DataSuccess(user));

      final result = await useCase(const NoParams());

      expect(result, isA<DataSuccess<UserEntity>>());
      expect(result.data, equals(user));
    });

    test('should_return_DataFailed_when_no_active_session', () async {
      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => DataFailed(Exception('No active session')));

      final result = await useCase(const NoParams());

      expect(result, isA<DataFailed<UserEntity>>());
    });
  });
}
