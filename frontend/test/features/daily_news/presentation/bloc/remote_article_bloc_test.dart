import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_page.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_query.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

ArticleEntity _story(String url) => ArticleEntity(url: url, title: url);

/// Answers each query from [pages] (keyed by section and page number) and
/// remembers every query it was asked.
class _FakeGetArticles implements GetArticleUseCase {
  final Map<(NewsCategory, int), NewsPage> pages;
  final queries = <NewsQuery>[];
  bool offline = false;

  _FakeGetArticles(this.pages);

  @override
  Future<DataState<NewsPage>> call({NewsQuery? params}) async {
    final query = params!;
    queries.add(query);
    if (offline) return DataFailed(Exception('offline'));
    return DataSuccess(pages[(query.category, query.page)] ??
        const NewsPage(articles: [], hasMore: false));
  }
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  test('loads the first page of the top stories', () async {
    final bloc = RemoteArticlesBloc(_FakeGetArticles({
      (NewsCategory.top, 1): NewsPage(articles: [_story('a')], hasMore: true),
    }));
    addTearDown(bloc.close);

    bloc.add(const GetArticles());
    await _settle();

    final state = bloc.state as RemoteArticlesDone;
    expect(state.articles.map((a) => a.url), ['a']);
    expect(state.hasReachedEnd, isFalse);
  });

  test('appends the next page, skipping stories it already shows', () async {
    final bloc = RemoteArticlesBloc(_FakeGetArticles({
      (NewsCategory.top, 1):
          NewsPage(articles: [_story('a'), _story('b')], hasMore: true),
      (NewsCategory.top, 2):
          NewsPage(articles: [_story('b'), _story('c')], hasMore: false),
    }));
    addTearDown(bloc.close);

    bloc.add(const GetArticles());
    await _settle();
    bloc.add(const LoadMoreArticles());
    await _settle();

    final state = bloc.state as RemoteArticlesDone;
    expect(state.articles.map((a) => a.url), ['a', 'b', 'c']);
    expect(state.hasReachedEnd, isTrue);
  });

  test('stops asking once the section has no more pages', () async {
    final useCase = _FakeGetArticles({
      (NewsCategory.top, 1): NewsPage(articles: [_story('a')], hasMore: false),
    });
    final bloc = RemoteArticlesBloc(useCase);
    addTearDown(bloc.close);

    bloc.add(const GetArticles());
    await _settle();
    bloc.add(const LoadMoreArticles());
    await _settle();

    expect(useCase.queries, hasLength(1));
  });

  test('going back to a loaded section costs no request', () async {
    final useCase = _FakeGetArticles({
      (NewsCategory.top, 1): NewsPage(articles: [_story('a')], hasMore: true),
      (NewsCategory.sports, 1):
          NewsPage(articles: [_story('s')], hasMore: true),
    });
    final bloc = RemoteArticlesBloc(useCase);
    addTearDown(bloc.close);

    bloc.add(const GetArticles());
    await _settle();
    bloc.add(const GetArticles(category: NewsCategory.sports));
    await _settle();
    bloc.add(const GetArticles());
    await _settle();

    expect(useCase.queries, hasLength(2));
    expect((bloc.state as RemoteArticlesDone).articles.single.url, 'a');
  });

  Future<RefreshOutcome> refresh(RemoteArticlesBloc bloc) {
    final done = Completer<RefreshOutcome>();
    bloc.add(GetArticles(refresh: true, completer: done));
    return done.future;
  }

  test('a refresh with the same stories says nothing is new', () async {
    final useCase = _FakeGetArticles({
      (NewsCategory.top, 1): NewsPage(articles: [_story('a')], hasMore: true),
    });
    final bloc = RemoteArticlesBloc(useCase);
    addTearDown(bloc.close);
    bloc.add(const GetArticles());
    await _settle();

    expect(await refresh(bloc), RefreshOutcome.nothingNew);
    expect(useCase.queries, hasLength(2));
  });

  test('a refresh that brings a new story says so', () async {
    final useCase = _FakeGetArticles({
      (NewsCategory.top, 1): NewsPage(articles: [_story('a')], hasMore: true),
    });
    final bloc = RemoteArticlesBloc(useCase);
    addTearDown(bloc.close);
    bloc.add(const GetArticles());
    await _settle();
    useCase.pages[(NewsCategory.top, 1)] =
        NewsPage(articles: [_story('new'), _story('a')], hasMore: true);

    expect(await refresh(bloc), RefreshOutcome.newStories);
  });

  test('a failed refresh keeps the stories and reports the failure', () async {
    final useCase = _FakeGetArticles({
      (NewsCategory.top, 1): NewsPage(articles: [_story('a')], hasMore: true),
    });
    final bloc = RemoteArticlesBloc(useCase);
    addTearDown(bloc.close);
    bloc.add(const GetArticles());
    await _settle();
    useCase.offline = true;

    expect(await refresh(bloc), RefreshOutcome.failed);
    expect((bloc.state as RemoteArticlesDone).articles.single.url, 'a');
  });

  test('offline with a saved copy, shows it and says when it is from',
      () async {
    final savedAt = DateTime(2026, 9, 24, 10, 42);
    final bloc = RemoteArticlesBloc(_FakeGetArticles({
      (NewsCategory.top, 1):
          NewsPage(articles: [_story('a')], hasMore: false, savedAt: savedAt),
    }));
    addTearDown(bloc.close);

    bloc.add(const GetArticles());
    await _settle();

    expect((bloc.state as RemoteArticlesDone).savedAt, savedAt);
  });

  test(
      'offline on the very first load, from NewsAPI\'s rate limit '
      'specifically', () async {
    final savedAt = DateTime(2026, 9, 24, 10, 42);
    final bloc = RemoteArticlesBloc(_FakeGetArticles({
      (NewsCategory.top, 1): NewsPage(
        articles: [_story('a')],
        hasMore: false,
        savedAt: savedAt,
        isRateLimited: true,
      ),
    }));
    addTearDown(bloc.close);

    bloc.add(const GetArticles());
    await _settle();

    final state = bloc.state as RemoteArticlesDone;
    expect(state.savedAt, savedAt);
    expect(state.isRateLimited, isTrue);
  });

  test('a refresh blocked by the rate limit says so, not just "offline"',
      () async {
    final useCase = _FakeGetArticles({
      (NewsCategory.top, 1):
          NewsPage(articles: [_story('a'), _story('b')], hasMore: true),
    });
    final bloc = RemoteArticlesBloc(useCase);
    addTearDown(bloc.close);
    bloc.add(const GetArticles());
    await _settle();
    useCase.pages[(NewsCategory.top, 1)] = NewsPage(
      articles: [_story('a')],
      hasMore: false,
      savedAt: DateTime(2026),
      isRateLimited: true,
    );

    expect(await refresh(bloc), RefreshOutcome.rateLimited);
  });

  test('a refresh offline keeps what is on screen and says so', () async {
    final useCase = _FakeGetArticles({
      (NewsCategory.top, 1):
          NewsPage(articles: [_story('a'), _story('b')], hasMore: true),
    });
    final bloc = RemoteArticlesBloc(useCase);
    addTearDown(bloc.close);
    bloc.add(const GetArticles());
    await _settle();
    useCase.pages[(NewsCategory.top, 1)] = NewsPage(
      articles: [_story('a')],
      hasMore: false,
      savedAt: DateTime(2026),
    );

    expect(await refresh(bloc), RefreshOutcome.offline);
    final state = bloc.state as RemoteArticlesDone;
    expect(state.articles, hasLength(2));
    expect(state.savedAt, isNull);
  });
}
