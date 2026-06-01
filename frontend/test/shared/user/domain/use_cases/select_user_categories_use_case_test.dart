import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/shared/user/domain/repository/user_repository.dart';
import 'package:tortutip/shared/user/domain/use_cases/select_user_categories_use_case.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late SelectUserCategoriesUseCase useCase;
  late MockUserRepository mockRepository;

  const params = SelectUserCategoriesParams(
    userId: 'user_1',
    categoryIds: ['cat_1', 'cat_2'],
  );

  setUp(() {
    mockRepository = MockUserRepository();
    useCase = SelectUserCategoriesUseCase(mockRepository);
    registerFallbackValue(params);
  });

  group('SelectUserCategoriesUseCase', () {
    test('should_return_DataSuccess_when_selection_succeeds', () async {
      when(() => mockRepository.selectUserCategories(any(), any()))
          .thenAnswer((_) async => const DataSuccess(true));

      final result = await useCase(params);

      expect(result, isA<DataSuccess<bool>>());
      expect(result.data, isTrue);
    });

    test('should_return_DataFailed_when_selection_fails', () async {
      when(() => mockRepository.selectUserCategories(any(), any()))
          .thenAnswer((_) async => DataFailed(Exception('error')));

      final result = await useCase(params);

      expect(result, isA<DataFailed<bool>>());
    });
  });
}
