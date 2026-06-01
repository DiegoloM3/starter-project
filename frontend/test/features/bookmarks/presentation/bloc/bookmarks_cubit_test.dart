import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/articles/domain/use_cases/unsave_article_use_case.dart';
import 'package:tortutip/features/bookmarks/presentation/bloc/bookmarks_cubit.dart';
import 'package:tortutip/features/bookmarks/presentation/bloc/bookmarks_state.dart';
import 'package:tortutip/features/profile/domain/use_cases/get_saved_articles_use_case.dart';

class MockGetSavedArticlesUseCase extends Mock
    implements GetSavedArticlesUseCase {}

class MockUnsaveArticleUseCase extends Mock implements UnsaveArticleUseCase {}

ArticleEntity _makeArticle(String id) => ArticleEntity(
      id: id,
      authorId: 'author_1',
      categoryId: 'cat_1',
      title: 'Article $id',
      body: '{}',
      coverVerticalUrl: '',
      coverHorizontalUrl: '',
      status: 'published',
      readTimeMinutes: 3,
      saveCount: 0,
      publishedAt: DateTime(2024),
      createdAt: DateTime(2024),
    );

void main() {
  setUpAll(() {
    registerFallbackValue(
      const GetSavedArticlesParams(userId: 'fallback', limit: 10),
    );
    registerFallbackValue(
      const UnsaveArticleParams(userId: 'fallback', articleId: 'fallback'),
    );
  });

  late BookmarksCubit cubit;
  late MockGetSavedArticlesUseCase mockGetSaved;
  late MockUnsaveArticleUseCase mockUnsave;

  const userId = 'user_1';

  setUp(() {
    mockGetSaved = MockGetSavedArticlesUseCase();
    mockUnsave = MockUnsaveArticleUseCase();
    cubit = BookmarksCubit(mockGetSaved, mockUnsave);
  });

  tearDown(() => cubit.close());

  group('BookmarksCubit.loadBookmarks', () {
    blocTest<BookmarksCubit, BookmarksState>(
      'should_emit_Loading_then_Empty_when_use_case_returns_empty_list',
      build: () {
        when(() => mockGetSaved(any()))
            .thenAnswer((_) async => const DataSuccess([]));
        return cubit;
      },
      act: (c) => c.loadBookmarks(userId),
      expect: () => [
        isA<BookmarksLoading>(),
        isA<BookmarksEmpty>(),
      ],
    );

    blocTest<BookmarksCubit, BookmarksState>(
      'should_emit_Loading_then_Loaded_when_use_case_returns_articles',
      build: () {
        final articles = [_makeArticle('a1'), _makeArticle('a2')];
        when(() => mockGetSaved(any()))
            .thenAnswer((_) async => DataSuccess(articles));
        return cubit;
      },
      act: (c) => c.loadBookmarks(userId),
      expect: () => [
        isA<BookmarksLoading>(),
        isA<BookmarksLoaded>(),
      ],
    );

    blocTest<BookmarksCubit, BookmarksState>(
      'should_emit_Loading_then_Error_when_use_case_fails',
      build: () {
        when(() => mockGetSaved(any()))
            .thenAnswer((_) async => DataFailed(Exception('error')));
        return cubit;
      },
      act: (c) => c.loadBookmarks(userId),
      expect: () => [
        isA<BookmarksLoading>(),
        isA<BookmarksError>(),
      ],
    );
  });

  group('BookmarksCubit.unsaveArticle', () {
    blocTest<BookmarksCubit, BookmarksState>(
      'should_optimistically_remove_article_when_unsave_called',
      build: () {
        when(() => mockUnsave(any()))
            .thenAnswer((_) async => const DataSuccess(true));
        return cubit;
      },
      seed: () => BookmarksLoaded(
        articles: [_makeArticle('a1'), _makeArticle('a2')],
        hasMore: false,
      ),
      act: (c) => c.unsaveArticle(userId, 'a1'),
      expect: () => [
        isA<BookmarksLoaded>().having(
          (s) => s.articles.length,
          'articles length',
          1,
        ),
      ],
    );

    blocTest<BookmarksCubit, BookmarksState>(
      'should_revert_state_when_unsave_fails',
      build: () {
        when(() => mockUnsave(any()))
            .thenAnswer((_) async => DataFailed(Exception('network error')));
        return cubit;
      },
      seed: () => BookmarksLoaded(
        articles: [_makeArticle('a1'), _makeArticle('a2')],
        hasMore: false,
      ),
      act: (c) => c.unsaveArticle(userId, 'a1'),
      expect: () => [
        // Optimistic remove — one article left
        isA<BookmarksLoaded>().having(
          (s) => s.articles.length,
          'articles length after optimistic remove',
          1,
        ),
        // Revert — both articles back
        isA<BookmarksLoaded>().having(
          (s) => s.articles.length,
          'articles length after revert',
          2,
        ),
      ],
    );
  });
}
