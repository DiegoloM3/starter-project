import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/auth/domain/repository/auth_repository.dart';
import 'package:tortutip/features/auth/domain/use_cases/sign_out_use_case.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignOutUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignOutUseCase(mockRepository);
  });

  group('SignOutUseCase', () {
    test('should_return_DataSuccess_when_repository_succeeds', () async {
      when(() => mockRepository.signOut())
          .thenAnswer((_) async => const DataSuccess(true));

      final result = await useCase(const NoParams());

      expect(result, isA<DataSuccess<bool>>());
      expect(result.data, isTrue);
      verify(() => mockRepository.signOut()).called(1);
    });

    test('should_return_DataFailed_when_repository_returns_failure', () async {
      final exception = Exception('Sign out failed');
      when(() => mockRepository.signOut())
          .thenAnswer((_) async => DataFailed(exception));

      final result = await useCase(const NoParams());

      expect(result, isA<DataFailed<bool>>());
      expect(result.error, equals(exception));
    });
  });
}
