import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/saved/saved_articles_cubit.dart';

import '../../../../../helpers/fixtures.dart';
import '../../../../../helpers/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(buildArticle());
  });

  late MockGetSavedArticlesUseCase getSaved;
  late MockSaveArticleUseCase save;
  late MockRemoveSavedArticleUseCase remove;
  late SavedArticlesCubit cubit;
  final a = buildArticle(id: 'a');
  final b = buildArticle(id: 'b');

  setUp(() {
    getSaved = MockGetSavedArticlesUseCase();
    save = MockSaveArticleUseCase();
    remove = MockRemoveSavedArticleUseCase();
    when(() => getSaved(any())).thenAnswer((_) async => DataSuccess([a, b]));
    when(() => save(any())).thenAnswer((_) async => const DataSuccess(null));
    when(() => remove(any())).thenAnswer((_) async => const DataSuccess(null));
    cubit = SavedArticlesCubit(getSaved, save, remove);
  });
  tearDown(() => cubit.close());

  test('load fills the list and the id set', () async {
    await cubit.load();

    expect(cubit.state.status, SavedStatus.loaded);
    expect(cubit.state.savedIds, {'a', 'b'});
    expect(cubit.isSaved('a'), isTrue);
    expect(cubit.isSaved('zzz'), isFalse);
  });

  test('a failed load is reported', () async {
    when(() => getSaved(any())).thenAnswer((_) async => const DataFailed(Failure.unknown()));
    await cubit.load();
    expect(cubit.state.status, SavedStatus.failure);
    expect(cubit.state.failure, const Failure.unknown());
  });

  test('toggle saves an unsaved article to the top and removes a saved one', () async {
    await cubit.load();
    final c = buildArticle(id: 'c');

    await cubit.toggle(c);
    expect(cubit.state.articles.first, c);
    verify(() => save(c)).called(1);

    await cubit.toggle(a);
    expect(cubit.isSaved('a'), isFalse);
    expect(cubit.state.lastRemoved, a);
    verify(() => remove('a')).called(1);
  });

  test('undoRemove puts the last removed article back and forgets it', () async {
    await cubit.load();
    await cubit.remove(b);

    await cubit.undoRemove();

    expect(cubit.isSaved('b'), isTrue);
    expect(cubit.state.lastRemoved, isNull);
    await cubit.undoRemove();
    verify(() => save(b)).called(1);
  });

  test('a rejected save keeps the list and reports the failure', () async {
    when(() => save(any())).thenAnswer((_) async => const DataFailed(Failure.unknown()));
    await cubit.load();

    await cubit.save(buildArticle(id: 'c'));

    expect(cubit.state.savedIds, {'a', 'b'});
    expect(cubit.state.failure, const Failure.unknown());
  });

  test('reset forgets the loaded list', () async {
    await cubit.load();
    expect(cubit.state.articles, isNotEmpty);

    cubit.reset();

    expect(cubit.state, const SavedArticlesState());
  });
}
