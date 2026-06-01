import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/categories/domain/entities/category_entity.dart';
import 'package:tortutip/features/categories/domain/repository/category_repository.dart';
import 'package:tortutip/features/categories/domain/use_cases/get_all_categories_use_case.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late GetAllCategoriesUseCase useCase;
  late MockCategoryRepository mockRepository;

  setUp(() {
    mockRepository = MockCategoryRepository();
    useCase = GetAllCategoriesUseCase(mockRepository);
  });

  group('GetAllCategoriesUseCase', () {
    final categories = [
      const CategoryEntity(
        id: 'cat_1',
        name: 'Fitness',
        description: 'Fitness tips',
        iconUrl: 'https://example.com/icon.png',
      ),
    ];

    test('should_return_DataSuccess_when_repository_succeeds', () async {
      when(() => mockRepository.getAllCategories())
          .thenAnswer((_) async => DataSuccess(categories));

      final result = await useCase(const NoParams());

      expect(result, isA<DataSuccess<List<CategoryEntity>>>());
      expect(result.data, equals(categories));
      verify(() => mockRepository.getAllCategories()).called(1);
    });

    test('should_return_DataFailed_when_repository_fails', () async {
      final exception = Exception('Firestore error');
      when(() => mockRepository.getAllCategories())
          .thenAnswer((_) async => DataFailed(exception));

      final result = await useCase(const NoParams());

      expect(result, isA<DataFailed<List<CategoryEntity>>>());
      expect(result.error, equals(exception));
    });
  });
}
