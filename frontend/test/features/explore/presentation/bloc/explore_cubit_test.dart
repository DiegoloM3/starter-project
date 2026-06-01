import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/categories/domain/entities/category_entity.dart';
import 'package:tortutip/features/categories/domain/use_cases/get_all_categories_use_case.dart';
import 'package:tortutip/features/explore/presentation/bloc/explore_cubit.dart';
import 'package:tortutip/features/explore/presentation/bloc/explore_state.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';

class MockGetAllCategoriesUseCase extends Mock
    implements GetAllCategoriesUseCase {}

void main() {
  late ExploreCubit cubit;
  late MockGetAllCategoriesUseCase mockGetAllCategories;

  setUp(() {
    mockGetAllCategories = MockGetAllCategoriesUseCase();
    cubit = ExploreCubit(mockGetAllCategories);
  });

  tearDown(() => cubit.close());

  final categories = [
    const CategoryEntity(
      id: 'cat_1',
      name: 'Fitness',
      description: 'Get fit',
      iconUrl: 'https://example.com/fitness.jpg',
    ),
  ];

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
    streakDays: 5,
    lastFeedDate: '2024-01-01',
    overallProgress: 0.07,
  );

  group('ExploreCubit', () {
    blocTest<ExploreCubit, ExploreState>(
      'should_emit_loading_then_loaded_when_categories_succeed',
      build: () {
        when(() => mockGetAllCategories(const NoParams()))
            .thenAnswer((_) async => DataSuccess(categories));
        return cubit;
      },
      act: (c) => c.loadExplore(),
      expect: () => [isA<ExploreLoading>(), isA<ExploreLoaded>()],
    );

    blocTest<ExploreCubit, ExploreState>(
      'should_emit_loaded_with_streak_and_progress_when_user_provided',
      build: () {
        when(() => mockGetAllCategories(const NoParams()))
            .thenAnswer((_) async => DataSuccess(categories));
        return cubit;
      },
      act: (c) => c.loadExplore(user: user),
      expect: () => [
        isA<ExploreLoading>(),
        isA<ExploreLoaded>()
            .having((s) => s.streakDays, 'streakDays', 5)
            .having((s) => s.categoryProgress, 'categoryProgress', 0.07),
      ],
    );

    blocTest<ExploreCubit, ExploreState>(
      'should_emit_loaded_with_zero_values_when_no_user_provided',
      build: () {
        when(() => mockGetAllCategories(const NoParams()))
            .thenAnswer((_) async => DataSuccess(categories));
        return cubit;
      },
      act: (c) => c.loadExplore(),
      expect: () => [
        isA<ExploreLoading>(),
        isA<ExploreLoaded>()
            .having((s) => s.streakDays, 'streakDays', 0)
            .having((s) => s.categoryProgress, 'categoryProgress', 0.0),
      ],
    );

    blocTest<ExploreCubit, ExploreState>(
      'should_emit_loading_then_error_when_categories_fail',
      build: () {
        when(() => mockGetAllCategories(const NoParams()))
            .thenAnswer((_) async => DataFailed(Exception('error')));
        return cubit;
      },
      act: (c) => c.loadExplore(),
      expect: () => [isA<ExploreLoading>(), isA<ExploreError>()],
    );
  });
}
