import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/news/domain/entities/article.entity.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/remote/remote_article_state.dart';

import 'remote_article_bloc_test.mocks.dart';

@GenerateMocks([GetArticleUseCase])
void main() {
  late MockGetArticleUseCase mockGetArticleUseCase;

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
    mockGetArticleUseCase = MockGetArticleUseCase();
  });

  test('initial state is RemoteArticlesLoading', () {
    final bloc = RemoteArticlesBloc(mockGetArticleUseCase);
    expect(bloc.state, isA<RemoteArticlesLoading>());
    bloc.close();
  });

  blocTest<RemoteArticlesBloc, RemoteArticlesState>(
    'emits [RemoteArticlesDone] with articles when GetArticles succeeds',
    build: () {
      when(mockGetArticleUseCase())
          .thenAnswer((_) async => DataSuccess(tArticleList));
      return RemoteArticlesBloc(mockGetArticleUseCase);
    },
    act: (bloc) => bloc.add(const GetArticles()),
    expect: () => [RemoteArticlesDone(tArticleList)],
  );

  // BUG FIX: previously the bloc stayed on RemoteArticlesLoading forever when
  // the API returned an empty list, because of the `data!.isNotEmpty` guard.
  // Now it must emit RemoteArticlesDone([]) so the UI can exit the loading state.
  blocTest<RemoteArticlesBloc, RemoteArticlesState>(
    'emits [RemoteArticlesDone([])] when API returns an empty list '
    '(regression: must NOT stay stuck on Loading)',
    build: () {
      when(mockGetArticleUseCase())
          .thenAnswer((_) async => DataSuccess([]));
      return RemoteArticlesBloc(mockGetArticleUseCase);
    },
    act: (bloc) => bloc.add(const GetArticles()),
    expect: () => [const RemoteArticlesDone([])],
  );

  blocTest<RemoteArticlesBloc, RemoteArticlesState>(
    'emits [RemoteArticlesError] when GetArticles returns DataFailed',
    build: () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/top-headlines'),
        type: DioExceptionType.connectionTimeout,
      );
      when(mockGetArticleUseCase())
          .thenAnswer((_) async => DataDioFailed(dioException));
      return RemoteArticlesBloc(mockGetArticleUseCase);
    },
    act: (bloc) => bloc.add(const GetArticles()),
    expect: () => [isA<RemoteArticlesError>()],
  );

  blocTest<RemoteArticlesBloc, RemoteArticlesState>(
    'emits [RemoteArticlesError(message)] when GetArticles returns '
    'DataGenericFailed (regression: must not cast to DioException)',
    build: () {
      when(mockGetArticleUseCase()).thenAnswer(
        (_) async => const DataGenericFailed('offline'),
      );
      return RemoteArticlesBloc(mockGetArticleUseCase);
    },
    act: (bloc) => bloc.add(const GetArticles()),
    expect: () => [const RemoteArticlesError('offline')],
  );

  blocTest<RemoteArticlesBloc, RemoteArticlesState>(
    'calls the usecase exactly once per GetArticles event',
    build: () {
      when(mockGetArticleUseCase())
          .thenAnswer((_) async => DataSuccess(tArticleList));
      return RemoteArticlesBloc(mockGetArticleUseCase);
    },
    act: (bloc) => bloc.add(const GetArticles()),
    verify: (_) {
      verify(mockGetArticleUseCase()).called(1);
    },
  );
}
