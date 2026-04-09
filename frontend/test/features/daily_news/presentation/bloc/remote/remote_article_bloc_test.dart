import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/errors/network_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/create_article_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/page.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/page_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/create_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_status.dart';

class MockGetArticleUseCase extends Mock implements GetArticlesUseCase {}

class MockCreateArticleUseCase extends Mock implements CreateArticleUseCase {}

class MockFile extends Mock implements File {}

class FakePageParams extends Fake implements PageParams {}

class FakeCreateArticleParams extends Fake implements CreateArticleParams {}

void main() {
  late MockGetArticleUseCase mockGetArticleUseCase;
  late MockCreateArticleUseCase mockCreateArticleUseCase;
  late RemoteArticlesBloc remoteArticlesBloc;

  setUpAll(() {
    registerFallbackValue(FakePageParams());
    registerFallbackValue(FakeCreateArticleParams());
  });

  setUp(() {
    mockGetArticleUseCase = MockGetArticleUseCase();
    mockCreateArticleUseCase = MockCreateArticleUseCase();
    remoteArticlesBloc = RemoteArticlesBloc(
      mockGetArticleUseCase,
      mockCreateArticleUseCase,
    );
  });

  tearDown(() {
    remoteArticlesBloc.close();
  });

  const article = ArticleEntity(
    id: '1',
    author: 'John Doe',
    title: 'Test Title',
    description: 'Test Description',
    url: 'http://example.com/image.jpg',
    publishedAt: '2024-01-01',
    content: 'Test content',
  );

  const articlesList = [article];

  group('RemoteArticlesBloc', () {
    test('initial state should be RemoteArticlesLoading', () {
      expect(remoteArticlesBloc.state, const RemoteArticlesLoading());
    });

    group('GetArticles', () {
      blocTest<RemoteArticlesBloc, RemoteArticlesState>(
        'emits [RemoteArticlesLoading, RemoteArticlesDone] when GetArticles is added and usecase returns DataSuccess with articles',
        build: () {
          when(() => mockGetArticleUseCase.call(any())).thenAnswer((_) async =>
              const DataSuccess(PageEntity(
                  content: articlesList, page: 0, totalPages: 1, total: 1)));
          return remoteArticlesBloc;
        },
        act: (bloc) => bloc.add(const GetArticles()),
        expect: () => [
          const RemoteArticlesLoading(),
          const RemoteArticlesDone(
              articles: articlesList, totalPages: 1, total: 1),
        ],
        verify: (bloc) {
          verify(() => mockGetArticleUseCase.call(any())).called(1);
        },
      );

      blocTest<RemoteArticlesBloc, RemoteArticlesState>(
        'emits [RemoteArticlesLoading, RemoteArticleEmpty] when GetArticles is added and usecase returns DataSuccess with empty list',
        build: () {
          when(() => mockGetArticleUseCase.call(any())).thenAnswer((_) async =>
              const DataSuccess(
                  PageEntity(content: [], page: 0, totalPages: 0, total: 0)));
          return remoteArticlesBloc;
        },
        act: (bloc) => bloc.add(const GetArticles()),
        expect: () => [
          const RemoteArticlesLoading(),
          const RemoteArticleEmpty(),
        ],
        verify: (bloc) {
          verify(() => mockGetArticleUseCase.call(any())).called(1);
        },
      );

      blocTest<RemoteArticlesBloc, RemoteArticlesState>(
        'emits [RemoteArticlesLoading, RemoteArticlesError] when GetArticles is added and usecase returns DataFailed',
        build: () {
          when(() => mockGetArticleUseCase.call(any())).thenAnswer(
              (_) async => const DataFailed(NetworkCancelException()));
          return remoteArticlesBloc;
        },
        act: (bloc) => bloc.add(const GetArticles()),
        expect: () => const [
          RemoteArticlesLoading(),
          RemoteArticlesError(NetworkCancelException()),
        ],
        verify: (bloc) {
          verify(() => mockGetArticleUseCase.call(any())).called(1);
        },
      );
    });

    group('CreateArticle', () {
      final mockFile = MockFile();

      blocTest<RemoteArticlesBloc, RemoteArticlesState>(
        'emits [RemoteArticlesDone(createdArticleSuccess), RemoteArticlesDone(none)] when CreateArticle is successful',
        build: () {
          when(() => mockCreateArticleUseCase.call(any()))
              .thenAnswer((_) async => const DataSuccess(null));
          return remoteArticlesBloc;
        },
        seed: () => const RemoteArticlesDone(articles: articlesList),
        act: (bloc) => bloc.add(CreateArticle(article: article, image: mockFile)),
        expect: () => [
          const RemoteArticlesDone(
            articles: articlesList,
            status: RemoteArticleStatus.createdArticleSuccess,
          ),
          const RemoteArticlesDone(
            articles: articlesList,
            status: RemoteArticleStatus.none,
          ),
        ],
      );

      blocTest<RemoteArticlesBloc, RemoteArticlesState>(
        'emits [RemoteArticlesDone(genericError), RemoteArticlesDone(none)] when CreateArticle fails and articles are not empty',
        build: () {
          when(() => mockCreateArticleUseCase.call(any())).thenAnswer(
              (_) async => const DataFailed(NetworkCancelException()));
          return remoteArticlesBloc;
        },
        seed: () => const RemoteArticlesDone(articles: articlesList),
        act: (bloc) => bloc.add(CreateArticle(article: article, image: mockFile)),
        expect: () => [
          const RemoteArticlesDone(
            articles: articlesList,
            status: RemoteArticleStatus.genericError,
          ),
          const RemoteArticlesDone(
            articles: articlesList,
            status: RemoteArticleStatus.none,
          ),
        ],
      );
    });

    group('NextPage', () {
      blocTest<RemoteArticlesBloc, RemoteArticlesState>(
        'emits states with incremented page and then combined articles when NextPage is added and there are more pages',
        build: () {
          when(() => mockGetArticleUseCase.call(any())).thenAnswer((_) async =>
              const DataSuccess(PageEntity(
                  content: articlesList, page: 1, totalPages: 2, total: 2)));
          return remoteArticlesBloc;
        },
        seed: () => const RemoteArticlesDone(
          articles: articlesList,
          page: 0,
          totalPages: 2,
          total: 2,
        ),
        act: (bloc) => bloc.add(const NextPage()),
        expect: () => [
          const RemoteArticlesDone(
            articles: articlesList,
            page: 1,
            totalPages: 2,
            total: 2,
          ),
          const RemoteArticlesDone(
            articles: [...articlesList, ...articlesList],
            page: 1,
            totalPages: 2,
            total: 2,
          ),
        ],
      );

      blocTest<RemoteArticlesBloc, RemoteArticlesState>(
        'emits nothing when NextPage is added and it is already the last page',
        build: () => remoteArticlesBloc,
        seed: () => const RemoteArticlesDone(
          articles: articlesList,
          page: 0,
          totalPages: 1,
          total: 1,
        ),
        act: (bloc) => bloc.add(const NextPage()),
        expect: () => [],
      );
    });
  });
}
