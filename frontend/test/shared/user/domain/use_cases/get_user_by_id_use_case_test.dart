import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';
import 'package:tortutip/shared/user/domain/repository/user_repository.dart';
import 'package:tortutip/shared/user/domain/use_cases/get_user_by_id_use_case.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late GetUserByIdUseCase useCase;
  late MockUserRepository mockRepository;

  setUp(() {
    mockRepository = MockUserRepository();
    useCase = GetUserByIdUseCase(mockRepository);
  });

  final user = UserEntity(
    id: 'user_1',
    name: 'Author',
    email: 'author@test.com',
    avatarUrl: '',
    bio: 'Bio',
    role: 'writer',
    gender: '',
    ageRange: '',
    createdAt: DateTime(2024),
  );

  group('GetUserByIdUseCase', () {
    test('should_return_DataSuccess_with_user_when_repository_succeeds',
        () async {
      when(() => mockRepository.getUserById('user_1'))
          .thenAnswer((_) async => DataSuccess(user));

      final result = await useCase(const GetUserByIdParams(userId: 'user_1'));

      expect(result, isA<DataSuccess<UserEntity>>());
      expect(result.data, equals(user));
      verify(() => mockRepository.getUserById('user_1')).called(1);
    });

    test('should_return_DataFailed_when_repository_throws', () async {
      final exception = Exception('not found');
      when(() => mockRepository.getUserById('user_1'))
          .thenAnswer((_) async => DataFailed(exception));

      final result = await useCase(const GetUserByIdParams(userId: 'user_1'));

      expect(result, isA<DataFailed<UserEntity>>());
      expect(result.error, equals(exception));
    });
  });
}
