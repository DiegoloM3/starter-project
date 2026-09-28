import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/features/news/domain/entities/article.entity.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/get_saved_article.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/remove_article.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/save_article.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/local/local_article_state.dart';

import 'local_article_bloc_test.mocks.dart';

@GenerateMocks([GetSavedArticleUseCase, SaveArticleUseCase, RemoveArticleUseCase])
void main() {
  late MockGetSavedArticleUseCase mockGetSavedArticleUseCase;
  late MockSaveArticleUseCase mockSaveArticleUseCase;
  late MockRemoveArticleUseCase mockRemoveArticleUseCase;

  // Shared fixtures
  const tArticle = ArticleEntity(
    id: "1",
    authorDisplayName: 'John Doe',
    title: 'Test Title',
    urlToImage: 'https://example.com/image.jpg',
    publishedAt: '2024-01-01T00:00:00Z',
    content: 'Test Content',
  );
  final tArticleList = [tArticle];

  setUp(() {
    mockGetSavedArticleUseCase = MockGetSavedArticleUseCase();
    mockSaveArticleUseCase = MockSaveArticleUseCase();
    mockRemoveArticleUseCase = MockRemoveArticleUseCase();
  });

  LocalArticleBloc buildBloc() => LocalArticleBloc(
        mockGetSavedArticleUseCase,
        mockSaveArticleUseCase,
        mockRemoveArticleUseCase,
      );

  test('initial state is LocalArticlesLoading', () {
    expect(buildBloc().state, isA<LocalArticlesLoading>());
  });

  // ---------------------------------------------------------------------------
  group('GetSavedArticles event', () {
    blocTest<LocalArticleBloc, LocalArticlesState>(
      'emits [LocalArticlesDone] with article list when articles exist',
      build: () {
        when(mockGetSavedArticleUseCase())
            .thenAnswer((_) async => tArticleList);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const GetSavedArticles()),
      expect: () => [LocalArticlesDone(tArticleList)],
    );

    blocTest<LocalArticleBloc, LocalArticlesState>(
      'emits [LocalArticlesDone] with empty list when no articles are saved',
      build: () {
        when(mockGetSavedArticleUseCase()).thenAnswer((_) async => []);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const GetSavedArticles()),
      expect: () => [const LocalArticlesDone([])],
    );
  });

  // ---------------------------------------------------------------------------
  group('SaveArticle event', () {
    blocTest<LocalArticleBloc, LocalArticlesState>(
      'saves the article then emits [LocalArticlesDone] with updated list',
      build: () {
        when(mockSaveArticleUseCase(params: tArticle))
            .thenAnswer((_) async {});
        when(mockGetSavedArticleUseCase())
            .thenAnswer((_) async => tArticleList);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SaveArticle(tArticle)),
      expect: () => [LocalArticlesDone(tArticleList)],
      verify: (_) {
        verify(mockSaveArticleUseCase(params: tArticle)).called(1);
        verify(mockGetSavedArticleUseCase()).called(1);
      },
    );
  });

  // ---------------------------------------------------------------------------
  group('failure paths (regression: offline save must surface errors, '
      'never report success while the write failed)', () {
    blocTest<LocalArticleBloc, LocalArticlesState>(
      'emits [LocalArticlesError] when the save write throws',
      build: () {
        when(mockSaveArticleUseCase(params: tArticle))
            .thenThrow(Exception('disk full'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SaveArticle(tArticle)),
      expect: () => [isA<LocalArticlesError>()],
      verify: (_) {
        verify(mockSaveArticleUseCase(params: tArticle)).called(1);
        verifyNever(mockGetSavedArticleUseCase());
      },
    );

    blocTest<LocalArticleBloc, LocalArticlesState>(
      'emits [LocalArticlesError] when reloading the saved list throws',
      build: () {
        when(mockGetSavedArticleUseCase()).thenThrow(Exception('db locked'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const GetSavedArticles()),
      expect: () => [isA<LocalArticlesError>()],
    );
  });

  // ---------------------------------------------------------------------------
  group('RemoveArticle event', () {
    blocTest<LocalArticleBloc, LocalArticlesState>(
      'removes the article then emits [LocalArticlesDone] with updated list',
      build: () {
        when(mockRemoveArticleUseCase(params: tArticle))
            .thenAnswer((_) async {});
        when(mockGetSavedArticleUseCase()).thenAnswer((_) async => []);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const RemoveArticle(tArticle)),
      expect: () => [const LocalArticlesDone([])],
      verify: (_) {
        verify(mockRemoveArticleUseCase(params: tArticle)).called(1);
        verify(mockGetSavedArticleUseCase()).called(1);
      },
    );
  });
}
