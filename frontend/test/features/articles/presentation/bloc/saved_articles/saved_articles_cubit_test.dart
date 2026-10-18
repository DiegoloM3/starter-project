import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/get_saved_articles.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/remove_saved_article.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/save_article.dart';
import 'package:news_app_clean_architecture/features/articles/presentation/bloc/saved_articles/saved_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/articles/presentation/bloc/saved_articles/saved_articles_state.dart';

import '../article_presentation_test_data.dart';

class MockGetSavedArticlesUseCase extends Mock implements GetSavedArticlesUseCase {}

class MockSaveArticleUseCase extends Mock implements SaveArticleUseCase {}

class MockRemoveSavedArticleUseCase extends Mock implements RemoveSavedArticleUseCase {}

void main() {
  late MockGetSavedArticlesUseCase getSavedArticles;
  late MockSaveArticleUseCase saveArticle;
  late MockRemoveSavedArticleUseCase removeSavedArticle;
  final savedArticle = buildArticle(id: 'saved');
  final otherArticle = buildArticle(id: 'other');
  final loadedState = SavedArticlesState(status: SavedArticlesStatus.success, articles: [savedArticle]);

  setUpAll(() => registerFallbackValue(const NoParams()));

  setUp(() {
    getSavedArticles = MockGetSavedArticlesUseCase();
    saveArticle = MockSaveArticleUseCase();
    removeSavedArticle = MockRemoveSavedArticleUseCase();
  });

  SavedArticlesCubit buildCubit() => SavedArticlesCubit(getSavedArticles, saveArticle, removeSavedArticle);

  blocTest<SavedArticlesCubit, SavedArticlesState>(
    'loads the saved articles',
    setUp: () => when(() => getSavedArticles(any())).thenAnswer((_) async => DataSuccess([savedArticle])),
    build: buildCubit,
    act: (cubit) => cubit.load(),
    expect: () => [const SavedArticlesState(status: SavedArticlesStatus.loading), loadedState],
  );

  test('knows which articles are saved', () {
    expect(loadedState.isSaved(savedArticle.id), isTrue);
    expect(loadedState.isSaved(otherArticle.id), isFalse);
  });

  blocTest<SavedArticlesCubit, SavedArticlesState>(
    'saves an unsaved article and shows it first',
    setUp: () => when(() => saveArticle(otherArticle.id)).thenAnswer((_) async => const DataSuccess(null)),
    build: buildCubit,
    seed: () => loadedState,
    act: (cubit) => cubit.toggle(otherArticle),
    expect:
        () => [
          SavedArticlesState(status: SavedArticlesStatus.success, articles: [otherArticle, savedArticle]),
        ],
  );

  blocTest<SavedArticlesCubit, SavedArticlesState>(
    'removes a saved article',
    setUp: () => when(() => removeSavedArticle(savedArticle.id)).thenAnswer((_) async => const DataSuccess(null)),
    build: buildCubit,
    seed: () => loadedState,
    act: (cubit) => cubit.toggle(savedArticle),
    expect: () => [const SavedArticlesState(status: SavedArticlesStatus.success)],
  );

  blocTest<SavedArticlesCubit, SavedArticlesState>(
    'restores the saved articles when the change fails',
    setUp: () => when(() => saveArticle(otherArticle.id)).thenAnswer((_) async => DataFailed(Exception('offline'))),
    build: buildCubit,
    seed: () => loadedState,
    act: (cubit) => cubit.toggle(otherArticle),
    expect:
        () => [
          SavedArticlesState(status: SavedArticlesStatus.success, articles: [otherArticle, savedArticle]),
          SavedArticlesState(status: SavedArticlesStatus.toggleFailure, articles: [savedArticle]),
        ],
  );
}
