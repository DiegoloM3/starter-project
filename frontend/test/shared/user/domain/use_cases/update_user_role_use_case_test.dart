import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/shared/user/domain/repository/user_repository.dart';
import 'package:tortutip/shared/user/domain/use_cases/update_user_role_use_case.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late UpdateUserRoleUseCase useCase;
  late MockUserRepository mockRepository;

  const params = UpdateUserRoleParams(userId: 'user_1', role: 'writer');

  setUp(() {
    mockRepository = MockUserRepository();
    useCase = UpdateUserRoleUseCase(mockRepository);
    registerFallbackValue(params);
  });

  group('UpdateUserRoleUseCase', () {
    test('should_return_DataSuccess_when_update_succeeds', () async {
      when(() => mockRepository.updateUserRole(any(), any()))
          .thenAnswer((_) async => const DataSuccess(true));

      final result = await useCase(params);

      expect(result, isA<DataSuccess<bool>>());
      expect(result.data, isTrue);
    });

    test('should_return_DataFailed_when_update_fails', () async {
      when(() => mockRepository.updateUserRole(any(), any()))
          .thenAnswer((_) async => DataFailed(Exception('permission denied')));

      final result = await useCase(params);

      expect(result, isA<DataFailed<bool>>());
    });
  });
}
