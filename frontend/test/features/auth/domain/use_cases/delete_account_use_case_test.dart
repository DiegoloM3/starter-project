import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/auth/domain/repository/auth_repository.dart';
import 'package:tortutip/features/auth/domain/use_cases/delete_account_use_case.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class FakeNoParams extends Fake implements NoParams {}

void main() {
  late DeleteAccountUseCase useCase;
  late MockAuthRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeNoParams());
  });

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = DeleteAccountUseCase(mockRepository);
  });

  group('DeleteAccountUseCase', () {
    test('should_return_true_when_repository_succeeds', () async {
      when(() => mockRepository.deleteAccount())
          .thenAnswer((_) async => const DataSuccess(true));

      final result = await useCase(const NoParams());

      expect(result, isA<DataSuccess<bool>>());
      expect(result.data, isTrue);
      verify(() => mockRepository.deleteAccount()).called(1);
    });

    test('should_return_failure_when_repository_fails', () async {
      final exception = Exception('Delete account error');
      when(() => mockRepository.deleteAccount())
          .thenAnswer((_) async => DataFailed(exception));

      final result = await useCase(const NoParams());

      expect(result, isA<DataFailed<bool>>());
      expect(result.error, equals(exception));
    });
  });
}
