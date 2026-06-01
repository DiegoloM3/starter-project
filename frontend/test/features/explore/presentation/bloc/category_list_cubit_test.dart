import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/articles/domain/use_cases/get_saved_article_ids_use_case.dart';
import 'package:tortutip/features/articles/domain/use_cases/save_article_use_case.dart';
import 'package:tortutip/features/articles/domain/use_cases/unsave_article_use_case.dart';
import 'package:tortutip/features/categories/domain/entities/category_entity.dart';
import 'package:tortutip/features/explore/domain/use_cases/get_articles_by_category_use_case.dart';
import 'package:tortutip/features/explore/presentation/bloc/category_list_cubit.dart';
import 'package:tortutip/features/explore/presentation/bloc/category_list_state.dart';

class MockGetArticlesByCategoryUseCase extends Mock
    implements GetArticlesByCategoryUseCase {}

class MockGetSavedArticleIdsUseCase extends Mock
    implements GetSavedArticleIdsUseCase {}

class MockSaveArticleUseCase extends Mock implements SaveArticleUseCase {}

class MockUnsaveArticleUseCase extends Mock implements UnsaveArticleUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(const GetArticlesByCategoryParams(categoryId: 'x'));
    registerFallbackValue(const GetSavedArticleIdsParams(userId: 'x'));
    registerFallbackValue(
        const SaveArticleParams(userId: 'x', articleId: 'x'));
    registerFallbackValue(
        const UnsaveArticleParams(userId: 'x', articleId: 'x'));
  });

  late CategoryListCubit cubit;
  late MockGetArticlesByCategoryUseCase mockGetArticlesByCategory;
  late MockGetSavedArticleIdsUseCase mockGetSavedArticleIds;
  late MockSaveArticleUseCase mockSaveArticle;
  late MockUnsaveArticleUseCase mockUnsaveArticle;

  const category = CategoryEntity(
    id: 'cat_1',
    name: 'Fitness',
    description: 'Get fit',
    iconUrl: 'https://example.com/fitness.jpg',
  );

  const userId = 'user_1';

  final articles = <ArticleEntity>[
    ArticleEntity(
      id: 'art_1',
      authorId: 'author_1',
      categoryId: 'cat_1',
      title: 'Test Article',
      body: 'Test body',
      coverVerticalUrl: '',
      coverHorizontalUrl: '',
      status: 'published',
      readTimeMinutes: 5,
      saveCount: 0,
      createdAt: DateTime(2024),
    ),
  ];

  setUp(() {
    mockGetArticlesByCategory = MockGetArticlesByCategoryUseCase();
    mockGetSavedArticleIds = MockGetSavedArticleIdsUseCase();
    mockSaveArticle = MockSaveArticleUseCase();
    mockUnsaveArticle = MockUnsaveArticleUseCase();

    cubit = CategoryListCubit(
      mockGetArticlesByCategory,
      mockGetSavedArticleIds,
      mockSaveArticle,
      mockUnsaveArticle,
    );
  });

  tearDown(() => cubit.close());

  group('CategoryListCubit.loadCategory', () {
    blocTest<CategoryListCubit, CategoryListState>(
      'should_emit_loading_then_loaded_when_load_category_succeeds',
      build: () {
        when(() => mockGetArticlesByCategory(any()))
            .thenAnswer((_) async => DataSuccess(articles));
        when(() => mockGetSavedArticleIds(any()))
            .thenAnswer((_) async => const DataSuccess(<String>[]));
        return cubit;
      },
      act: (c) => c.loadCategory(category, userId),
      expect: () => [
        isA<CategoryListLoading>(),
        isA<CategoryListLoaded>(),
      ],
    );

    blocTest<CategoryListCubit, CategoryListState>(
      'should_emit_loading_then_empty_when_articles_list_is_empty',
      build: () {
        when(() => mockGetArticlesByCategory(any()))
            .thenAnswer((_) async => const DataSuccess(<ArticleEntity>[]));
        when(() => mockGetSavedArticleIds(any()))
            .thenAnswer((_) async => const DataSuccess(<String>[]));
        return cubit;
      },
      act: (c) => c.loadCategory(category, userId),
      expect: () => [
        isA<CategoryListLoading>(),
        isA<CategoryListEmpty>(),
      ],
    );

    blocTest<CategoryListCubit, CategoryListState>(
      'should_emit_loading_then_error_when_get_articles_fails',
      build: () {
        when(() => mockGetArticlesByCategory(any()))
            .thenAnswer((_) async => DataFailed(Exception('error')));
        when(() => mockGetSavedArticleIds(any()))
            .thenAnswer((_) async => const DataSuccess(<String>[]));
        return cubit;
      },
      act: (c) => c.loadCategory(category, userId),
      expect: () => [
        isA<CategoryListLoading>(),
        isA<CategoryListError>(),
      ],
    );
  });

  group('CategoryListCubit.loadMore', () {
    blocTest<CategoryListCubit, CategoryListState>(
      'should_emit_loaded_with_more_articles_when_load_more_succeeds',
      build: () {
        when(() => mockGetArticlesByCategory(any()))
            .thenAnswer((_) async => DataSuccess(articles));
        when(() => mockGetSavedArticleIds(any()))
            .thenAnswer((_) async => const DataSuccess(<String>[]));
        return cubit;
      },
      seed: () => CategoryListLoaded(
        category: category,
        articles: articles,
        hasMore: true,
        savedArticleIds: const {},
      ),
      act: (c) => c.loadMore(userId),
      expect: () => [
        isA<CategoryListLoadingMore>(),
        isA<CategoryListLoaded>(),
      ],
    );
  });

  group('CategoryListCubit.toggleBookmark', () {
    blocTest<CategoryListCubit, CategoryListState>(
      'should_toggle_bookmark_optimistically_and_revert_on_failure',
      build: () {
        when(() => mockSaveArticle(any()))
            .thenAnswer((_) async => DataFailed(Exception('error')));
        return cubit;
      },
      seed: () => CategoryListLoaded(
        category: category,
        articles: articles,
        hasMore: false,
        savedArticleIds: const {},
      ),
      act: (c) => c.toggleBookmark('art_1', userId),
      expect: () => [
        // Optimistic: article added to saved
        isA<CategoryListLoaded>().having(
          (s) => s.savedArticleIds.contains('art_1'),
          'optimistically saved',
          true,
        ),
        // Reverted: article removed from saved after failure
        isA<CategoryListLoaded>().having(
          (s) => s.savedArticleIds.contains('art_1'),
          'reverted',
          false,
        ),
      ],
    );

    blocTest<CategoryListCubit, CategoryListState>(
      'should_call_unsave_when_article_is_already_saved',
      build: () {
        when(() => mockUnsaveArticle(any()))
            .thenAnswer((_) async => const DataSuccess(true));
        return cubit;
      },
      seed: () => CategoryListLoaded(
        category: category,
        articles: articles,
        hasMore: false,
        savedArticleIds: const {'art_1'},
      ),
      act: (c) => c.toggleBookmark('art_1', userId),
      verify: (_) {
        verify(() => mockUnsaveArticle(any())).called(1);
        verifyNever(() => mockSaveArticle(any()));
      },
    );
  });
}
