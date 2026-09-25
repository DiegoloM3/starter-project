import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_page.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_query.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/search_history_entity.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/search_history_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_recent_searches.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/remove_search.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/save_search.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/search_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/search/search_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/search/search_state.dart';

ArticleEntity _story(String url) => ArticleEntity(url: url, title: url);

/// Answers from [answers] by search text and page; a text mapped to a
/// Completer answers only when the test completes it.
class _FakeSearch implements SearchArticlesUseCase {
  final Map<(String, int), Object> answers;
  final queries = <SearchQuery>[];

  _FakeSearch(this.answers);

  @override
  Future<DataState<NewsPage>> call({SearchQuery? params}) async {
    final query = params!;
    queries.add(query);
    final answer = answers[(query.text, query.page)];
    if (answer is Completer<NewsPage>) return DataSuccess(await answer.future);
    if (answer is NewsPage) return DataSuccess(answer);
    return DataFailed(Exception('offline'));
  }
}

/// Recent searches kept in a list, most recent first.
class _MemoryHistory implements SearchHistoryRepository {
  final searches = <String>[];

  @override
  Future<List<SearchHistoryEntity>> getRecentSearches() async =>
      [for (final text in searches) SearchHistoryEntity(text: text)];

  @override
  Future<void> saveSearch(String text) async => searches
    ..remove(text)
    ..insert(0, text);

  @override
  Future<void> removeSearch(String text) async => searches.remove(text);
}

SearchCubit _cubit(SearchArticlesUseCase search, [_MemoryHistory? history]) {
  final repository = history ?? _MemoryHistory();
  return SearchCubit(
    search,
    GetRecentSearchesUseCase(repository),
    SaveSearchUseCase(repository),
    RemoveSearchUseCase(repository),
  );
}

void main() {
  test('shows what it found', () async {
    final cubit = _cubit(_FakeSearch({
      ('climate', 1): NewsPage(articles: [_story('a')], hasMore: false),
    }));
    addTearDown(cubit.close);

    await cubit.search('  climate ', languageCode: 'es');

    final state = cubit.state as SearchResults;
    expect(state.text, 'climate');
    expect(state.articles.single.url, 'a');
    expect(state.hasReachedEnd, isTrue);
  });

  test('an empty search does nothing', () async {
    final search = _FakeSearch({});
    final cubit = _cubit(search);
    addTearDown(cubit.close);

    await cubit.search('   ', languageCode: 'en');

    expect(cubit.state, const SearchIdle());
    expect(search.queries, isEmpty);
  });

  test('a slow older search never replaces a newer one', () async {
    final slow = Completer<NewsPage>();
    final cubit = _cubit(_FakeSearch({
      ('old', 1): slow,
      ('new', 1): NewsPage(articles: [_story('n')], hasMore: false),
    }));
    addTearDown(cubit.close);

    final older = cubit.search('old', languageCode: 'en');
    await cubit.search('new', languageCode: 'en');
    slow.complete(NewsPage(articles: [_story('o')], hasMore: false));
    await older;

    expect((cubit.state as SearchResults).text, 'new');
  });

  test('loads the next page in the same language', () async {
    final search = _FakeSearch({
      ('ai', 1): NewsPage(articles: [_story('a')], hasMore: true),
      ('ai', 2): NewsPage(articles: [_story('b')], hasMore: false),
    });
    final cubit = _cubit(search);
    addTearDown(cubit.close);

    await cubit.search('ai', languageCode: 'es');
    await cubit.loadMore();

    expect(
        (cubit.state as SearchResults).articles.map((a) => a.url), ['a', 'b']);
    expect(search.queries.last.languageCode, 'es');
  });

  test('says so when the search fails', () async {
    final cubit = _cubit(_FakeSearch({}));
    addTearDown(cubit.close);

    await cubit.search('anything', languageCode: 'en');

    expect(cubit.state, const SearchError('anything'));
  });

  test('remembers what was searched, most recent first', () async {
    final history = _MemoryHistory();
    final cubit = _cubit(_FakeSearch({}), history);
    addTearDown(cubit.close);

    await cubit.search('climate', languageCode: 'en');
    await cubit.search('elections', languageCode: 'en');
    await cubit.showHistory();

    expect((cubit.state as SearchIdle).history.map((e) => e.text),
        ['elections', 'climate']);
  });

  test('removing a search updates the list on screen', () async {
    final history = _MemoryHistory()..searches.addAll(['a', 'b']);
    final cubit = _cubit(_FakeSearch({}), history);
    addTearDown(cubit.close);
    await cubit.showHistory();

    await cubit.removeFromHistory('a');

    expect((cubit.state as SearchIdle).history.map((e) => e.text), ['b']);
  });
}
