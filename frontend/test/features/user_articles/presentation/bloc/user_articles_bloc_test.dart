import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/bloc/user_articles/user_articles_bloc.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/bloc/user_articles/user_articles_event.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/bloc/user_articles/user_articles_state.dart';

import '../../../../mocks/mocks.dart';
import '../../../../fixtures/test_fixtures.dart';

void main() {
  late UserArticlesBloc bloc;
  late MockGetUserArticlesUseCase mockGetUserArticlesUseCase;
  late MockGetPublishedArticlesUseCase mockGetPublishedArticlesUseCase;
  late MockGetArticlesByCategoryUseCase mockGetArticlesByCategoryUseCase;
  late MockDeleteArticleUseCase mockDeleteArticleUseCase;
  late MockPublishArticleUseCase mockPublishArticleUseCase;

  setUp(() {
    mockGetUserArticlesUseCase = MockGetUserArticlesUseCase();
    mockGetPublishedArticlesUseCase = MockGetPublishedArticlesUseCase();
    mockGetArticlesByCategoryUseCase = MockGetArticlesByCategoryUseCase();
    mockDeleteArticleUseCase = MockDeleteArticleUseCase();
    mockPublishArticleUseCase = MockPublishArticleUseCase();

    bloc = UserArticlesBloc(
      getUserArticlesUseCase: mockGetUserArticlesUseCase,
      getPublishedArticlesUseCase: mockGetPublishedArticlesUseCase,
      getArticlesByCategoryUseCase: mockGetArticlesByCategoryUseCase,
      deleteArticleUseCase: mockDeleteArticleUseCase,
      publishArticleUseCase: mockPublishArticleUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  final testArticle = TestFixtures.testArticle;
  final testDraftArticle = TestFixtures.testDraftArticle;
  final testArticles = [testArticle, testDraftArticle];

  group('UserArticlesBloc', () {
    test('initial state is UserArticlesInitial', () {
      expect(bloc.state, isA<UserArticlesInitial>());
    });

    group('LoadUserArticles', () {
      blocTest<UserArticlesBloc, UserArticlesState>(
        'emits [UserArticlesLoading, UserArticlesLoaded] when loading succeeds',
        build: () {
          when(mockGetUserArticlesUseCase.call(params: anyNamed('params')))
              .thenAnswer((_) async => DataSuccess(testArticles));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadUserArticles(userId: 'user123')),
        expect: () => [
          isA<UserArticlesLoading>(),
          isA<UserArticlesLoaded>(),
        ],
        verify: (_) {
          verify(mockGetUserArticlesUseCase.call(params: 'user123')).called(1);
        },
      );

      blocTest<UserArticlesBloc, UserArticlesState>(
        'emits [UserArticlesLoading, UserArticlesError] when loading fails',
        build: () {
          when(mockGetUserArticlesUseCase.call(params: anyNamed('params')))
              .thenAnswer((_) async => DataFailed(Exception('Load failed')));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadUserArticles(userId: 'user123')),
        expect: () => [
          isA<UserArticlesLoading>(),
          isA<UserArticlesError>(),
        ],
      );

      blocTest<UserArticlesBloc, UserArticlesState>(
        'correctly counts published and draft articles',
        build: () {
          when(mockGetUserArticlesUseCase.call(params: anyNamed('params')))
              .thenAnswer((_) async => DataSuccess(testArticles));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadUserArticles(userId: 'user123')),
        verify: (bloc) {
          final state = bloc.state;
          expect(state, isA<UserArticlesLoaded>());
          final loadedState = state as UserArticlesLoaded;
          expect(loadedState.publishedCount, 1); // testArticle
          expect(loadedState.draftsCount, 1); // testDraftArticle
        },
      );
    });

    group('LoadPublishedArticles', () {
      blocTest<UserArticlesBloc, UserArticlesState>(
        'emits [UserArticlesLoading, UserArticlesLoaded] with published articles',
        build: () {
          when(mockGetPublishedArticlesUseCase.call())
              .thenAnswer((_) async => DataSuccess([testArticle]));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadPublishedArticles()),
        expect: () => [
          isA<UserArticlesLoading>(),
          isA<UserArticlesLoaded>(),
        ],
        verify: (bloc) {
          final state = bloc.state as UserArticlesLoaded;
          expect(state.publishedCount, 1);
          expect(state.draftsCount, 0);
        },
      );

      blocTest<UserArticlesBloc, UserArticlesState>(
        'emits [UserArticlesLoading, UserArticlesError] when loading fails',
        build: () {
          when(mockGetPublishedArticlesUseCase.call())
              .thenAnswer((_) async => DataFailed(Exception('Load failed')));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadPublishedArticles()),
        expect: () => [
          isA<UserArticlesLoading>(),
          isA<UserArticlesError>(),
        ],
      );
    });

    group('LoadArticlesByCategory', () {
      blocTest<UserArticlesBloc, UserArticlesState>(
        'emits [UserArticlesLoading, UserArticlesLoaded] with filtered articles',
        build: () {
          when(mockGetArticlesByCategoryUseCase.call(
                  params: anyNamed('params')))
              .thenAnswer((_) async => DataSuccess([testArticle]));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadArticlesByCategory(category: 'tech')),
        expect: () => [
          isA<UserArticlesLoading>(),
          isA<UserArticlesLoaded>(),
        ],
        verify: (_) {
          verify(mockGetArticlesByCategoryUseCase.call(params: 'tech'))
              .called(1);
        },
      );
    });

    group('DeleteArticle', () {
      blocTest<UserArticlesBloc, UserArticlesState>(
        'emits [UserArticlesActionInProgress, UserArticlesActionSuccess, UserArticlesLoaded] when delete succeeds',
        build: () {
          when(mockDeleteArticleUseCase.call(params: anyNamed('params')))
              .thenAnswer((_) async => const DataSuccess(null));
          return bloc;
        },
        seed: () => UserArticlesLoaded(
          articles: testArticles,
          publishedCount: 1,
          draftsCount: 1,
        ),
        act: (bloc) => bloc.add(const DeleteArticle(articleId: 'article123')),
        expect: () => [
          isA<UserArticlesActionInProgress>(),
          isA<UserArticlesActionSuccess>(),
          isA<UserArticlesLoaded>(),
        ],
        verify: (_) {
          verify(mockDeleteArticleUseCase.call(params: 'article123')).called(1);
        },
      );

      blocTest<UserArticlesBloc, UserArticlesState>(
        'emits [UserArticlesActionInProgress, UserArticlesError] when delete fails',
        build: () {
          when(mockDeleteArticleUseCase.call(params: anyNamed('params')))
              .thenAnswer((_) async => DataFailed(Exception('Delete failed')));
          return bloc;
        },
        seed: () => UserArticlesLoaded(
          articles: testArticles,
          publishedCount: 1,
          draftsCount: 1,
        ),
        act: (bloc) => bloc.add(const DeleteArticle(articleId: 'article123')),
        expect: () => [
          isA<UserArticlesActionInProgress>(),
          isA<UserArticlesError>(),
        ],
      );
    });

    group('PublishArticle', () {
      final publishedArticle = UserArticleEntity(
        id: 'draft123',
        title: 'Draft Article',
        content: 'Draft content',
        authorId: 'user123',
        isDraft: false,
        publishedAt: DateTime.now(),
      );

      blocTest<UserArticlesBloc, UserArticlesState>(
        'emits [UserArticlesActionInProgress, UserArticlesActionSuccess, UserArticlesLoaded] when publish succeeds',
        build: () {
          when(mockPublishArticleUseCase.call(params: anyNamed('params')))
              .thenAnswer((_) async => DataSuccess(publishedArticle));
          return bloc;
        },
        seed: () => UserArticlesLoaded(
          articles: [testDraftArticle],
          publishedCount: 0,
          draftsCount: 1,
        ),
        act: (bloc) => bloc.add(const PublishArticle(articleId: 'draft123')),
        expect: () => [
          isA<UserArticlesActionInProgress>(),
          isA<UserArticlesActionSuccess>(),
          isA<UserArticlesLoaded>(),
        ],
        verify: (_) {
          verify(mockPublishArticleUseCase.call(params: 'draft123')).called(1);
        },
      );
    });

    group('FilterArticles', () {
      blocTest<UserArticlesBloc, UserArticlesState>(
        'filters to show only published articles',
        build: () => bloc,
        seed: () => UserArticlesLoaded(
          articles: testArticles,
          publishedCount: 1,
          draftsCount: 1,
        ),
        act: (bloc) =>
            bloc.add(const FilterArticles(filter: ArticleFilter.published)),
        verify: (bloc) {
          final state = bloc.state as UserArticlesLoaded;
          expect(state.currentFilter, ArticleFilter.published);
          expect(state.filteredArticles!.every((a) => !a.isDraft), true);
        },
      );

      blocTest<UserArticlesBloc, UserArticlesState>(
        'filters to show only draft articles',
        build: () => bloc,
        seed: () => UserArticlesLoaded(
          articles: testArticles,
          publishedCount: 1,
          draftsCount: 1,
        ),
        act: (bloc) =>
            bloc.add(const FilterArticles(filter: ArticleFilter.drafts)),
        verify: (bloc) {
          final state = bloc.state as UserArticlesLoaded;
          expect(state.currentFilter, ArticleFilter.drafts);
          expect(state.filteredArticles!.every((a) => a.isDraft), true);
        },
      );

      blocTest<UserArticlesBloc, UserArticlesState>(
        'shows all articles when filter is all',
        build: () => bloc,
        seed: () => UserArticlesLoaded(
          articles: testArticles,
          filteredArticles: [testArticle], // pre-filtered
          currentFilter: ArticleFilter.published,
          publishedCount: 1,
          draftsCount: 1,
        ),
        act: (bloc) =>
            bloc.add(const FilterArticles(filter: ArticleFilter.all)),
        verify: (bloc) {
          final state = bloc.state as UserArticlesLoaded;
          expect(state.currentFilter, ArticleFilter.all);
          expect(state.filteredArticles!.length, testArticles.length);
        },
      );
    });
  });
}
