import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/articles/domain/use_cases/get_feed_articles_paged_use_case.dart';
import 'package:tortutip/features/articles/domain/use_cases/get_saved_article_ids_use_case.dart';
import 'package:tortutip/features/articles/domain/use_cases/save_article_use_case.dart';
import 'package:tortutip/features/articles/domain/use_cases/unsave_article_use_case.dart';
import 'package:tortutip/features/articles/presentation/bloc/feed/feed_cubit.dart';
import 'package:tortutip/features/articles/presentation/bloc/feed/feed_state.dart';
import 'package:tortutip/features/categories/domain/use_cases/get_all_categories_use_case.dart';
import 'package:tortutip/core/usecase/usecase.dart';

class MockGetFeedArticlesPagedUseCase extends Mock
    implements GetFeedArticlesPagedUseCase {}

class MockGetSavedArticleIdsUseCase extends Mock
    implements GetSavedArticleIdsUseCase {}

class MockSaveArticleUseCase extends Mock implements SaveArticleUseCase {}

class MockUnsaveArticleUseCase extends Mock implements UnsaveArticleUseCase {}

class MockGetAllCategoriesUseCase extends Mock
    implements GetAllCategoriesUseCase {}

void main() {
  late FeedCubit cubit;
  late MockGetFeedArticlesPagedUseCase mockGetFeedArticlesPaged;
  late MockGetSavedArticleIdsUseCase mockGetSavedArticleIds;
  late MockSaveArticleUseCase mockSaveArticle;
  late MockUnsaveArticleUseCase mockUnsaveArticle;
  late MockGetAllCategoriesUseCase mockGetAllCategories;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(
        const GetFeedArticlesPagedParams(categoryIds: [], page: 0, pageSize: 10));
    registerFallbackValue(const GetSavedArticleIdsParams(userId: ''));
    registerFallbackValue(const SaveArticleParams(userId: '', articleId: ''));
    registerFallbackValue(const UnsaveArticleParams(userId: '', articleId: ''));
  });

  const userId = 'user_1';
  final articles = <ArticleEntity>[
    ArticleEntity(
      id: 'art_1',
      authorId: userId,
      categoryId: 'cat_1',
      title: 'Title',
      body: 'Body',
      coverVerticalUrl: '',
      coverHorizontalUrl: '',
      status: 'published',
      readTimeMinutes: 5,
      saveCount: 0,
      createdAt: DateTime(2024),
    ),
  ];

  setUp(() {
    mockGetFeedArticlesPaged = MockGetFeedArticlesPagedUseCase();
    mockGetSavedArticleIds = MockGetSavedArticleIdsUseCase();
    mockSaveArticle = MockSaveArticleUseCase();
    mockUnsaveArticle = MockUnsaveArticleUseCase();
    mockGetAllCategories = MockGetAllCategoriesUseCase();

    when(() => mockGetAllCategories(any()))
        .thenAnswer((_) async => const DataSuccess([]));

    cubit = FeedCubit(
      mockGetFeedArticlesPaged,
      mockGetSavedArticleIds,
      mockSaveArticle,
      mockUnsaveArticle,
      mockGetAllCategories,
    );

  });

  tearDown(() => cubit.close());

  void stubSuccess() {
    when(() => mockGetFeedArticlesPaged(any()))
        .thenAnswer((_) async => DataSuccess(articles));
    when(() => mockGetSavedArticleIds(any()))
        .thenAnswer((_) async => const DataSuccess(<String>[]));
  }

  group('FeedCubit.loadFeed', () {
    blocTest<FeedCubit, FeedState>(
      'should_emit_loading_then_loaded_when_loadFeed_succeeds',
      build: () {
        stubSuccess();
        return cubit;
      },
      act: (c) => c.loadFeed(userId),
      expect: () => [
        isA<FeedLoading>(),
        isA<FeedLoaded>(),
      ],
    );

    blocTest<FeedCubit, FeedState>(
      'should_emit_loading_then_error_when_loadFeed_fails_articles',
      build: () {
        when(() => mockGetFeedArticlesPaged(any()))
            .thenAnswer((_) async => DataFailed(Exception('error')));
        when(() => mockGetSavedArticleIds(any()))
            .thenAnswer((_) async => const DataSuccess(<String>[]));
        return cubit;
      },
      act: (c) => c.loadFeed(userId),
      expect: () => [
        isA<FeedLoading>(),
        isA<FeedError>(),
      ],
    );
  });

  group('FeedCubit.onSwipe', () {
    blocTest<FeedCubit, FeedState>(
      'should_update_currentIndex_when_onSwipe_called',
      build: () {
        stubSuccess();
        return cubit;
      },
      act: (c) async {
        await c.loadFeed(userId);
        c.onSwipe();
      },
      expect: () => [
        isA<FeedLoading>(),
        isA<FeedLoaded>(),
        isA<FeedLoaded>(),
      ],
    );
  });

  group('FeedCubit.toggleBookmark', () {
    blocTest<FeedCubit, FeedState>(
      'should_add_articleId_to_savedArticleIds_when_toggleBookmark_on_unsaved',
      build: () {
        stubSuccess();
        when(() => mockSaveArticle(any()))
            .thenAnswer((_) async => const DataSuccess(true));
        return cubit;
      },
      act: (c) async {
        await c.loadFeed(userId);
        await c.toggleBookmark('art_1');
      },
      expect: () => [
        isA<FeedLoading>(),
        isA<FeedLoaded>(),
        isA<FeedLoaded>(),
      ],
      verify: (_) {
        verify(() => mockSaveArticle(any())).called(1);
      },
    );

    blocTest<FeedCubit, FeedState>(
      'should_remove_articleId_from_savedArticleIds_when_toggleBookmark_on_saved',
      build: () {
        when(() => mockGetFeedArticlesPaged(any()))
            .thenAnswer((_) async => DataSuccess(articles));
        when(() => mockGetSavedArticleIds(any()))
            .thenAnswer((_) async => const DataSuccess(['art_1']));
        when(() => mockUnsaveArticle(any()))
            .thenAnswer((_) async => const DataSuccess(true));
        return cubit;
      },
      act: (c) async {
        await c.loadFeed(userId);
        await c.toggleBookmark('art_1');
      },
      expect: () => [
        isA<FeedLoading>(),
        isA<FeedLoaded>(),
        isA<FeedLoaded>(),
      ],
      verify: (_) {
        verify(() => mockUnsaveArticle(any())).called(1);
      },
    );

    blocTest<FeedCubit, FeedState>(
      'should_revert_savedArticleIds_when_SaveArticleUseCase_fails',
      build: () {
        stubSuccess();
        when(() => mockSaveArticle(any()))
            .thenAnswer((_) async => DataFailed(Exception('error')));
        return cubit;
      },
      act: (c) async {
        await c.loadFeed(userId);
        await c.toggleBookmark('art_1');
      },
      expect: () => [
        isA<FeedLoading>(),
        isA<FeedLoaded>(),
        isA<FeedLoaded>(),
        isA<FeedLoaded>(),
      ],
    );
  });
}
