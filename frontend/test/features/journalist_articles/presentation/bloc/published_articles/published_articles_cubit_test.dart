import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/published_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/params/get_published_articles_params.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/get_published_articles.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/published_articles/published_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/published_articles/published_articles_state.dart';

import '../../../../../helpers/cubit_states.dart';

class MockGetPublishedArticlesUseCase extends Mock implements GetPublishedArticlesUseCase {}

const pageSize = GetPublishedArticlesParams.defaultPageSize;

PublishedArticleEntity articleNumber(int number) {
  return PublishedArticleEntity(
    id: 'article-$number',
    title: 'Article $number',
    content: 'Content',
    description: 'Content',
    author: 'Author',
    thumbnailUrl: 'https://example.com/$number.jpg',
    publishedAt: DateTime(2026, 1, 1).subtract(Duration(minutes: number)),
  );
}

List<PublishedArticleEntity> articlesNumbered(int from, int count) {
  return List.generate(count, (index) => articleNumber(from + index));
}

void main() {
  late MockGetPublishedArticlesUseCase getPublishedArticles;
  late PublishedArticlesCubit cubit;

  setUpAll(() => registerFallbackValue(const GetPublishedArticlesParams()));

  setUp(() {
    getPublishedArticles = MockGetPublishedArticlesUseCase();
    cubit = PublishedArticlesCubit(getPublishedArticles);
  });

  tearDown(() => cubit.close());

  void givenPages(List<DataState<List<PublishedArticleEntity>>> pages) {
    final remaining = [...pages];
    when(() => getPublishedArticles(params: any(named: 'params'))).thenAnswer((_) async => remaining.removeAt(0));
  }

  GetPublishedArticlesParams lastRequestedParams() {
    return verify(() => getPublishedArticles(params: captureAny(named: 'params'))).captured.last
        as GetPublishedArticlesParams;
  }

  test('starts loading', () {
    expect(cubit.state, const PublishedArticlesLoading());
  });

  group('loadArticles', () {
    test('shows the first page', () async {
      givenPages([DataSuccess(articlesNumbered(1, 3))]);

      await cubit.loadArticles();

      expect(cubit.state, PublishedArticlesLoaded(articles: articlesNumbered(1, 3), hasMore: false));
    });

    test('expects more articles when the page is full', () async {
      givenPages([DataSuccess(articlesNumbered(1, pageSize))]);

      await cubit.loadArticles();

      expect((cubit.state as PublishedArticlesLoaded).hasMore, isTrue);
    });

    test('shows an error when the first page cannot be loaded', () async {
      final error = Exception('offline');
      givenPages([DataFailed(error)]);

      await cubit.loadArticles();

      expect(cubit.state, PublishedArticlesError(error));
    });

    test('keeps showing the current list while refreshing', () async {
      givenPages([DataSuccess(articlesNumbered(1, 2)), DataSuccess(articlesNumbered(1, 3))]);
      await cubit.loadArticles();

      final states = await statesEmittedBy(cubit, cubit.loadArticles);

      expect(states, [PublishedArticlesLoaded(articles: articlesNumbered(1, 3), hasMore: false)]);
    });

    test('shows the loader again when retrying after an error', () async {
      givenPages([DataFailed(Exception('offline')), DataSuccess(articlesNumbered(1, 1))]);
      await cubit.loadArticles();

      final states = await statesEmittedBy(cubit, cubit.loadArticles);

      expect(states.first, const PublishedArticlesLoading());
    });
  });

  group('loadMoreArticles', () {
    setUp(() async {
      givenPages([DataSuccess(articlesNumbered(1, pageSize))]);
      await cubit.loadArticles();
      clearInteractions(getPublishedArticles);
    });

    test('appends the next page, starting after the last article shown', () async {
      givenPages([DataSuccess(articlesNumbered(pageSize + 1, 5))]);

      await cubit.loadMoreArticles();

      expect(lastRequestedParams().startAfter, articleNumber(pageSize));
      expect(cubit.state, PublishedArticlesLoaded(articles: articlesNumbered(1, pageSize + 5), hasMore: false));
    });

    test('shows a loader at the end of the list while loading more', () async {
      givenPages([DataSuccess(articlesNumbered(pageSize + 1, 5))]);

      final states = await statesEmittedBy(cubit, cubit.loadMoreArticles);

      expect((states.first as PublishedArticlesLoaded).isLoadingMore, isTrue);
    });

    test('does nothing when there are no more articles', () async {
      givenPages([DataSuccess(articlesNumbered(pageSize + 1, 1))]);
      await cubit.loadMoreArticles();

      await cubit.loadMoreArticles();

      verify(() => getPublishedArticles(params: any(named: 'params'))).called(1);
    });

    test('ignores new requests while a page is loading', () async {
      final pendingPage = Completer<DataState<List<PublishedArticleEntity>>>();
      when(() => getPublishedArticles(params: any(named: 'params'))).thenAnswer((_) => pendingPage.future);

      final firstRequest = cubit.loadMoreArticles();
      await cubit.loadMoreArticles();
      pendingPage.complete(DataSuccess(articlesNumbered(pageSize + 1, 1)));
      await firstRequest;

      verify(() => getPublishedArticles(params: any(named: 'params'))).called(1);
    });

    test('keeps the loaded articles when the next page fails', () async {
      givenPages([DataFailed(Exception('offline'))]);

      await cubit.loadMoreArticles();

      expect(cubit.state, PublishedArticlesLoaded(articles: articlesNumbered(1, pageSize), hasMore: true));
    });
  });
}
