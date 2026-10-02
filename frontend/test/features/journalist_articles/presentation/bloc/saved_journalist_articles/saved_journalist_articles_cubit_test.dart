import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/get_saved_journalist_articles.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/remove_saved_journalist_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/saved_journalist_articles/saved_journalist_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/saved_journalist_articles/saved_journalist_articles_state.dart';

class MockGetSavedJournalistArticlesUseCase extends Mock implements GetSavedJournalistArticlesUseCase {}

class MockRemoveSavedJournalistArticleUseCase extends Mock implements RemoveSavedJournalistArticleUseCase {}

JournalistArticleEntity buildArticle(String id) {
  return JournalistArticleEntity(
    id: id,
    title: 'Article $id',
    description: 'A description',
    content: 'Some content',
    author: 'Jane Doe',
    authorId: 'janeDoeUid',
    thumbnailURL: '',
    publishedAt: DateTime.utc(2026, 9, 30),
  );
}

void main() {
  late MockGetSavedJournalistArticlesUseCase getSavedArticles;
  late MockRemoveSavedJournalistArticleUseCase removeSavedArticle;
  late SavedJournalistArticlesCubit cubit;

  final first = buildArticle('article1');
  final second = buildArticle('article2');

  setUp(() {
    getSavedArticles = MockGetSavedJournalistArticlesUseCase();
    removeSavedArticle = MockRemoveSavedJournalistArticleUseCase();
    cubit = SavedJournalistArticlesCubit(getSavedArticles, removeSavedArticle);
  });

  tearDown(() => cubit.close());

  Future<void> loadArticles(List<JournalistArticleEntity> articles) async {
    when(() => getSavedArticles()).thenAnswer((_) async => DataSuccess(articles));
    await cubit.loadSavedArticles();
  }

  test('shows the saved articles once they are loaded', () async {
    when(() => getSavedArticles()).thenAnswer((_) async => DataSuccess([first]));

    final states = expectLater(
      cubit.stream,
      emitsInOrder([const SavedJournalistArticlesInProgress(), SavedJournalistArticlesSuccess([first])]),
    );
    await cubit.loadSavedArticles();
    await states;
  });

  test('shows a failure when they cannot be loaded', () async {
    final error = Exception('No connection');
    when(() => getSavedArticles()).thenAnswer((_) async => DataFailed(error));

    await cubit.loadSavedArticles();

    expect(cubit.state, SavedJournalistArticlesFailure(error));
  });

  test('refreshes them without going back to loading', () async {
    await loadArticles([first]);
    when(() => getSavedArticles()).thenAnswer((_) async => DataSuccess([second, first]));

    final states = expectLater(cubit.stream, emitsInOrder([SavedJournalistArticlesSuccess([second, first])]));
    await cubit.loadSavedArticles();
    await states;
  });

  test('takes a removed article out of the list', () async {
    await loadArticles([first, second]);
    when(() => removeSavedArticle(params: 'article1')).thenAnswer((_) async => const DataSuccess(null));

    await cubit.removeSavedArticle(first);

    expect(cubit.state, SavedJournalistArticleRemoved([second]));
  });

  test('keeps the list as it was when an article cannot be removed', () async {
    await loadArticles([first, second]);
    final error = Exception('No connection');
    when(() => removeSavedArticle(params: 'article1')).thenAnswer((_) async => DataFailed(error));

    await cubit.removeSavedArticle(first);

    expect(cubit.state, SavedJournalistArticleRemoveFailure([first, second], error));
  });
}
