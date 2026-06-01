import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/categories/domain/entities/category_entity.dart';
import 'package:tortutip/features/categories/domain/use_cases/get_all_categories_use_case.dart';
import 'package:tortutip/features/categories/presentation/bloc/category_cubit.dart';
import 'package:tortutip/features/categories/presentation/bloc/category_state.dart';

class MockGetAllCategoriesUseCase extends Mock
    implements GetAllCategoriesUseCase {}

void main() {
  late CategoryCubit cubit;
  late MockGetAllCategoriesUseCase mockGetAllCategories;

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    mockGetAllCategories = MockGetAllCategoriesUseCase();
    cubit = CategoryCubit(mockGetAllCategories);
  });

  tearDown(() => cubit.close());

  group('CategoryCubit.loadCategories', () {
    final categories = [
      const CategoryEntity(
        id: 'cat_1',
        name: 'Fitness',
        description: 'Fitness tips',
        iconUrl: 'https://example.com/icon.png',
      ),
    ];

    blocTest<CategoryCubit, CategoryState>(
      'should_emit_Loading_then_Loaded_when_use_case_succeeds',
      build: () {
        when(() => mockGetAllCategories(any()))
            .thenAnswer((_) async => DataSuccess(categories));
        return cubit;
      },
      act: (c) => c.loadCategories(),
      expect: () => [
        isA<CategoryLoading>(),
        isA<CategoryLoaded>(),
      ],
    );

    blocTest<CategoryCubit, CategoryState>(
      'should_emit_Loading_then_Error_when_use_case_fails',
      build: () {
        when(() => mockGetAllCategories(any()))
            .thenAnswer((_) async => DataFailed(Exception('error')));
        return cubit;
      },
      act: (c) => c.loadCategories(),
      expect: () => [
        isA<CategoryLoading>(),
        isA<CategoryError>(),
      ],
    );
  });
}
