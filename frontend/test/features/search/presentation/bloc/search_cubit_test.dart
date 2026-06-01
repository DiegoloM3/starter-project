import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/categories/domain/entities/category_entity.dart';
import 'package:tortutip/features/search/domain/params/search_articles_params.dart';
import 'package:tortutip/features/search/domain/use_cases/get_recent_searches_use_case.dart';
import 'package:tortutip/features/search/domain/use_cases/remove_recent_search_use_case.dart';
import 'package:tortutip/features/search/domain/use_cases/save_recent_search_use_case.dart';
import 'package:tortutip/features/search/domain/use_cases/search_articles_use_case.dart';
import 'package:tortutip/features/search/domain/use_cases/search_categories_use_case.dart';
import 'package:tortutip/features/search/domain/use_cases/search_creators_use_case.dart';
import 'package:tortutip/features/search/presentation/bloc/search_cubit.dart';
import 'package:tortutip/features/search/presentation/bloc/search_state.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';

class MockSearchArticlesUseCase extends Mock
    implements SearchArticlesUseCase {}

class MockSearchCategoriesUseCase extends Mock
    implements SearchCategoriesUseCase {}

class MockSearchCreatorsUseCase extends Mock implements SearchCreatorsUseCase {}

class MockGetRecentSearchesUseCase extends Mock
    implements GetRecentSearchesUseCase {}

class MockSaveRecentSearchUseCase extends Mock
    implements SaveRecentSearchUseCase {}

class MockRemoveRecentSearchUseCase extends Mock
    implements RemoveRecentSearchUseCase {}

void main() {
  late SearchCubit cubit;
  late MockSearchArticlesUseCase mockSearchArticles;
  late MockSearchCategoriesUseCase mockSearchCategories;
  late MockSearchCreatorsUseCase mockSearchCreators;
  late MockGetRecentSearchesUseCase mockGetRecentSearches;
  late MockSaveRecentSearchUseCase mockSaveRecentSearch;
  late MockRemoveRecentSearchUseCase mockRemoveRecentSearch;

  setUpAll(() {
    registerFallbackValue(
        const SearchArticlesParams(query: '', limit: 20));
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    mockSearchArticles = MockSearchArticlesUseCase();
    mockSearchCategories = MockSearchCategoriesUseCase();
    mockSearchCreators = MockSearchCreatorsUseCase();
    mockGetRecentSearches = MockGetRecentSearchesUseCase();
    mockSaveRecentSearch = MockSaveRecentSearchUseCase();
    mockRemoveRecentSearch = MockRemoveRecentSearchUseCase();

    cubit = SearchCubit(
      mockSearchArticles,
      mockSearchCategories,
      mockSearchCreators,
      mockGetRecentSearches,
      mockSaveRecentSearch,
      mockRemoveRecentSearch,
    );
  });

  tearDown(() => cubit.close());

  final categories = [
    const CategoryEntity(
        id: 'cat1', name: 'Fitness', description: '', iconUrl: ''),
  ];

  final articles = [
    ArticleEntity(
      id: 'a1',
      authorId: 'u1',
      categoryId: 'cat1',
      title: 'Nutrition tips',
      body: '',
      coverVerticalUrl: '',
      coverHorizontalUrl: '',
      status: 'published',
      readTimeMinutes: 5,
      saveCount: 0,
      createdAt: DateTime(2024),
    ),
  ];

  final creators = [
    UserEntity(
      id: 'u1',
      name: 'Jane',
      email: 'jane@test.com',
      avatarUrl: '',
      bio: '',
      role: 'writer',
      gender: '',
      ageRange: '',
      createdAt: DateTime(2024),
    ),
  ];

  group('SearchCubit', () {
    blocTest<SearchCubit, SearchState>(
      'should_emit_SearchInitial_when_loadInitial_succeeds',
      build: () {
        when(() => mockGetRecentSearches(const NoParams()))
            .thenAnswer((_) async => const DataSuccess(['nutrition']));
        when(() => mockSearchCategories('')).thenAnswer(
            (_) async => DataSuccess(categories));
        return cubit;
      },
      act: (c) => c.loadInitial(),
      expect: () => [
        isA<SearchInitial>(),
      ],
    );

    blocTest<SearchCubit, SearchState>(
      'should_emit_SearchInitial_with_empty_lists_when_loadInitial_fails',
      build: () {
        when(() => mockGetRecentSearches(const NoParams()))
            .thenAnswer((_) async => DataFailed(Exception('error')));
        when(() => mockSearchCategories('')).thenAnswer(
            (_) async => DataFailed(Exception('error')));
        return cubit;
      },
      act: (c) => c.loadInitial(),
      expect: () => [
        isA<SearchInitial>().having(
            (s) => s.recentSearches, 'recentSearches', isEmpty),
      ],
    );

    blocTest<SearchCubit, SearchState>(
      'should_emit_SearchLoading_then_SearchLoaded_when_search_succeeds_with_results',
      build: () {
        when(() => mockSearchArticles(any())).thenAnswer(
            (_) async => DataSuccess(articles));
        when(() => mockSearchCategories(any())).thenAnswer(
            (_) async => DataSuccess(categories));
        when(() => mockSearchCreators(any())).thenAnswer(
            (_) async => DataSuccess(creators));
        when(() => mockSaveRecentSearch(any()))
            .thenAnswer((_) async => const DataSuccess(true));
        return cubit;
      },
      act: (c) => c.search('nutrition'),
      expect: () => [
        isA<SearchLoading>(),
        isA<SearchLoaded>(),
      ],
    );

    blocTest<SearchCubit, SearchState>(
      'should_emit_SearchLoading_then_SearchEmpty_when_search_returns_no_results',
      build: () {
        when(() => mockSearchArticles(any())).thenAnswer(
            (_) async => DataSuccess(<ArticleEntity>[]));
        when(() => mockSearchCategories(any())).thenAnswer(
            (_) async => DataSuccess(<CategoryEntity>[]));
        when(() => mockSearchCreators(any())).thenAnswer(
            (_) async => DataSuccess(<UserEntity>[]));
        when(() => mockSaveRecentSearch(any()))
            .thenAnswer((_) async => const DataSuccess(true));
        return cubit;
      },
      act: (c) => c.search('xyz123'),
      expect: () => [
        isA<SearchLoading>(),
        isA<SearchEmpty>(),
      ],
    );

    blocTest<SearchCubit, SearchState>(
      'should_emit_SearchLoading_then_SearchError_when_all_searches_fail',
      build: () {
        when(() => mockSearchArticles(any())).thenAnswer(
            (_) async => DataFailed(Exception('error')));
        when(() => mockSearchCategories(any())).thenAnswer(
            (_) async => DataFailed(Exception('error')));
        when(() => mockSearchCreators(any())).thenAnswer(
            (_) async => DataFailed(Exception('error')));
        return cubit;
      },
      act: (c) => c.search('nutrition'),
      expect: () => [
        isA<SearchLoading>(),
        isA<SearchError>(),
      ],
    );

    blocTest<SearchCubit, SearchState>(
      'should_update_activeFilter_when_setFilter_called_on_SearchLoaded',
      build: () => cubit,
      seed: () => SearchLoaded(
        query: 'nutrition',
        articles: articles,
        categories: categories,
        creators: creators,
        activeFilter: 'all',
        activeTab: 0,
      ),
      act: (c) => c.setFilter('cat1'),
      expect: () => [
        isA<SearchLoaded>()
            .having((s) => s.activeFilter, 'activeFilter', 'cat1'),
      ],
    );

    blocTest<SearchCubit, SearchState>(
      'should_update_activeTab_when_setTab_called_on_SearchLoaded',
      build: () => cubit,
      seed: () => SearchLoaded(
        query: 'nutrition',
        articles: articles,
        categories: categories,
        creators: creators,
        activeFilter: 'all',
        activeTab: 0,
      ),
      act: (c) => c.setTab(1),
      expect: () => [
        isA<SearchLoaded>().having((s) => s.activeTab, 'activeTab', 1),
      ],
    );

    blocTest<SearchCubit, SearchState>(
      'should_update_recentSearches_after_removeRecent',
      build: () {
        when(() => mockRemoveRecentSearch(any()))
            .thenAnswer((_) async => const DataSuccess(true));
        return cubit;
      },
      seed: () => const SearchInitial(
        recentSearches: ['nutrition', 'fitness'],
        categories: [],
      ),
      act: (c) => c.removeRecent('nutrition'),
      expect: () => [
        isA<SearchInitial>().having(
          (s) => s.recentSearches,
          'recentSearches',
          ['fitness'],
        ),
      ],
    );
  });
}
