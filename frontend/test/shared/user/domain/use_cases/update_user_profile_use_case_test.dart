import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';
import 'package:tortutip/shared/user/domain/repository/user_repository.dart';
import 'package:tortutip/shared/user/domain/use_cases/update_user_profile_use_case.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late UpdateUserProfileUseCase useCase;
  late MockUserRepository mockRepository;

  final user = UserEntity(
    id: 'user_1',
    name: 'Updated Name',
    email: 'test@test.com',
    avatarUrl: '',
    bio: 'Updated bio',
    role: 'reader',
    gender: '',
    ageRange: '',
    createdAt: DateTime(2024),
  );

  setUp(() {
    mockRepository = MockUserRepository();
    useCase = UpdateUserProfileUseCase(mockRepository);
    registerFallbackValue(user);
    registerFallbackValue(UpdateUserProfileParams(user: user));
  });

  group('UpdateUserProfileUseCase', () {
    test('should_return_DataSuccess_with_updated_user_when_update_succeeds',
        () async {
      when(() => mockRepository.updateUserProfile(any()))
          .thenAnswer((_) async => DataSuccess(user));

      final result = await useCase(UpdateUserProfileParams(user: user));

      expect(result, isA<DataSuccess<UserEntity>>());
      expect(result.data, equals(user));
    });

    test('should_return_DataFailed_when_update_fails', () async {
      when(() => mockRepository.updateUserProfile(any()))
          .thenAnswer((_) async => DataFailed(Exception('error')));

      final result = await useCase(UpdateUserProfileParams(user: user));

      expect(result, isA<DataFailed<UserEntity>>());
    });
  });
}
