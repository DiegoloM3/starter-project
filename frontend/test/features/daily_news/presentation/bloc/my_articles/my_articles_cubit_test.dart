import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/my_articles/my_articles_cubit.dart';

import '../../../../../helpers/fixtures.dart';
import '../../../../../helpers/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(buildArticle());
  });

  late MockGetMyArticlesUseCase getMyArticles;
  late MockDeleteArticleUseCase deleteArticle;
  late MyArticlesCubit cubit;
  final older = buildUserArticle(id: 'a', publishedAt: DateTime.utc(2026, 9, 10));
  final newer = buildUserArticle(id: 'b', publishedAt: DateTime.utc(2026, 9, 15));

  setUp(() {
    getMyArticles = MockGetMyArticlesUseCase();
    deleteArticle = MockDeleteArticleUseCase();
    when(() => getMyArticles(any())).thenAnswer((_) async => DataSuccess([newer, older]));
    when(() => deleteArticle(any())).thenAnswer((_) async => const DataSuccess(null));
    cubit = MyArticlesCubit(getMyArticles, deleteArticle);
  });
  tearDown(() => cubit.close());

  test('load fills the list; a failure is reported', () async {
    await cubit.load();
    expect(cubit.state.status, MyArticlesStatus.loaded);
    expect(cubit.state.articles, [newer, older]);

    when(() => getMyArticles(any())).thenAnswer((_) async => const DataFailed(Failure.unauthenticated()));
    await cubit.load();
    expect(cubit.state.status, MyArticlesStatus.failure);
  });

  test('upsert inserts or replaces and keeps newest first', () async {
    await cubit.load();
    final newest = buildUserArticle(id: 'c', publishedAt: DateTime.utc(2026, 9, 20));
    cubit.upsert(newest);
    expect(cubit.state.articles.first, newest);

    final edited = older.copyWith(title: 'Edited');
    cubit.upsert(edited);
    expect(cubit.state.articles.length, 3);
    expect(cubit.state.articles.last.title, 'Edited');
  });

  test('delete removes on success and keeps the list on failure', () async {
    await cubit.load();

    expect(await cubit.delete(newer), isTrue);
    expect(cubit.state.articles, [older]);

    when(() => deleteArticle(any())).thenAnswer((_) async => const DataFailed(Failure.permissionDenied()));
    expect(await cubit.delete(older), isFalse);
    expect(cubit.state.articles, [older]);
    expect(cubit.state.failure?.type, FailureType.permissionDenied);
  });

  test('reset returns to the initial state', () async {
    await cubit.load();
    cubit.reset();
    expect(cubit.state, const MyArticlesState());
  });
}
