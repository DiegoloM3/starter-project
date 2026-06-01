import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/shared/user/domain/repository/user_repository.dart';
import 'package:tortutip/shared/user/domain/use_cases/get_user_category_ids_use_case.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late GetUserCategoryIdsUseCase useCase;
  late MockUserRepository mockRepository;

  setUp(() {
    mockRepository = MockUserRepository();
    useCase = GetUserCategoryIdsUseCase(mockRepository);
  });

  group('GetUserCategoryIdsUseCase', () {
    const params = GetUserCategoryIdsParams(userId: 'user_1');
    final categoryIds = ['cat_1', 'cat_2'];

    test('should_return_category_ids_when_repository_succeeds', () async {
      when(() => mockRepository.getUserCategoryIds('user_1'))
          .thenAnswer((_) async => DataSuccess(categoryIds));

      final result = await useCase(params);

      expect(result, isA<DataSuccess<List<String>>>());
      expect(result.data, equals(categoryIds));
      verify(() => mockRepository.getUserCategoryIds('user_1')).called(1);
    });

    test('should_return_failure_when_repository_fails', () async {
      final exception = Exception('Firestore error');
      when(() => mockRepository.getUserCategoryIds('user_1'))
          .thenAnswer((_) async => DataFailed(exception));

      final result = await useCase(params);

      expect(result, isA<DataFailed<List<String>>>());
    });
  });
}
