import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/feed.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/search/search_cubit.dart';

import '../../../../../helpers/fixtures.dart';
import '../../../../../helpers/mocks.dart';

void main() {
  late MockSearchArticlesUseCase search;
  late SearchCubit cubit;
  final hit = buildArticle(title: 'Tram strike');

  setUp(() {
    search = MockSearchArticlesUseCase();
    when(() => search(any())).thenAnswer((_) async => DataSuccess(FeedEntity(articles: [hit])));
    cubit = SearchCubit(search, debounce: const Duration(milliseconds: 20));
  });
  tearDown(() => cubit.close());

  test('typing is debounced: one request per pause, results afterwards', () {
    fakeAsync((async) {
      cubit.queryChanged('t');
      cubit.queryChanged('tr');
      cubit.queryChanged('tram');
      verifyNever(() => search(any()));

      async.elapse(const Duration(milliseconds: 40));

      verify(() => search('tram')).called(1);
      expect(cubit.state.status, SearchStatus.results);
      expect(cubit.state.results, [hit]);
      expect(cubit.state.recent, ['tram']);
    });
  });

  test('clearing the field returns to idle without a request', () {
    fakeAsync((async) {
      cubit.queryChanged('tram');
      cubit.queryChanged('');
      async.elapse(const Duration(milliseconds: 40));

      verifyNever(() => search(any()));
      expect(cubit.state.status, SearchStatus.idle);
    });
  });

  test('search records recents newest first, without duplicates, capped', () async {
    for (var i = 0; i < SearchCubit.maxRecent + 2; i++) {
      await cubit.search('query $i');
    }
    await cubit.search('Query 3');

    expect(cubit.state.recent.length, SearchCubit.maxRecent);
    expect(cubit.state.recent.first, 'Query 3');
    expect(cubit.state.recent.where((r) => r.toLowerCase() == 'query 3').length, 1);
  });

  test('no results and failures are distinct states', () async {
    when(() => search(any())).thenAnswer((_) async => const DataSuccess(FeedEntity.empty));
    await cubit.search('zeppelin');
    expect(cubit.state.hasNoResults, isTrue);

    when(() => search(any())).thenAnswer((_) async => const DataFailed(Failure.network()));
    await cubit.search('zeppelin');
    expect(cubit.state.status, SearchStatus.failure);
  });

  test('clear and clearRecent reset what they say', () async {
    await cubit.search('tram');
    cubit.clear();
    expect(cubit.state.query, isEmpty);
    expect(cubit.state.status, SearchStatus.idle);
    expect(cubit.state.recent, ['tram']);

    cubit.clearRecent();
    expect(cubit.state.recent, isEmpty);
  });
}
