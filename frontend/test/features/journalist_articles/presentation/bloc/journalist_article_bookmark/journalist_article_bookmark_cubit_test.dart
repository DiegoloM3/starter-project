import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/is_journalist_article_saved.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/remove_saved_journalist_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/save_journalist_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/journalist_article_bookmark/journalist_article_bookmark_cubit.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/journalist_article_bookmark/journalist_article_bookmark_state.dart';

class MockIsJournalistArticleSavedUseCase extends Mock implements IsJournalistArticleSavedUseCase {}

class MockSaveJournalistArticleUseCase extends Mock implements SaveJournalistArticleUseCase {}

class MockRemoveSavedJournalistArticleUseCase extends Mock implements RemoveSavedJournalistArticleUseCase {}

void main() {
  late MockIsJournalistArticleSavedUseCase isArticleSaved;
  late MockSaveJournalistArticleUseCase saveArticle;
  late MockRemoveSavedJournalistArticleUseCase removeSavedArticle;
  late JournalistArticleBookmarkCubit cubit;

  setUp(() {
    isArticleSaved = MockIsJournalistArticleSavedUseCase();
    saveArticle = MockSaveJournalistArticleUseCase();
    removeSavedArticle = MockRemoveSavedJournalistArticleUseCase();
    cubit = JournalistArticleBookmarkCubit(isArticleSaved, saveArticle, removeSavedArticle, 'article1');
  });

  tearDown(() => cubit.close());

  Future<void> loadBookmark({required bool isSaved}) async {
    when(() => isArticleSaved(params: 'article1')).thenAnswer((_) async => DataSuccess(isSaved));
    await cubit.loadBookmark();
  }

  test('starts checking whether the article is saved', () {
    expect(cubit.state, const JournalistArticleBookmarkInProgress(false));
  });

  test('shows whether the article is saved', () async {
    await loadBookmark(isSaved: true);

    expect(cubit.state, const JournalistArticleBookmarkSuccess(true));
  });

  test('shows the article as not saved when that cannot be checked', () async {
    when(() => isArticleSaved(params: 'article1')).thenAnswer((_) async => DataFailed(Exception('No connection')));

    await cubit.loadBookmark();

    expect(cubit.state, const JournalistArticleBookmarkSuccess(false));
  });

  test('saves an article that is not saved', () async {
    await loadBookmark(isSaved: false);
    when(() => saveArticle(params: 'article1')).thenAnswer((_) async => const DataSuccess(null));

    final states = expectLater(
      cubit.stream,
      emitsInOrder([const JournalistArticleBookmarkInProgress(false), const JournalistArticleBookmarkChanged(true)]),
    );
    await cubit.toggleBookmark();
    await states;
  });

  test('removes an article that is saved', () async {
    await loadBookmark(isSaved: true);
    when(() => removeSavedArticle(params: 'article1')).thenAnswer((_) async => const DataSuccess(null));

    await cubit.toggleBookmark();

    expect(cubit.state, const JournalistArticleBookmarkChanged(false));
  });

  test('keeps the bookmark as it was when saving fails', () async {
    await loadBookmark(isSaved: false);
    final error = Exception('No connection');
    when(() => saveArticle(params: 'article1')).thenAnswer((_) async => DataFailed(error));

    await cubit.toggleBookmark();

    expect(cubit.state, JournalistArticleBookmarkFailure(false, error));
  });

  test('ignores taps while the bookmark is changing', () async {
    await loadBookmark(isSaved: false);
    when(() => saveArticle(params: 'article1')).thenAnswer((_) async => const DataSuccess(null));

    await Future.wait([cubit.toggleBookmark(), cubit.toggleBookmark()]);

    verify(() => saveArticle(params: 'article1')).called(1);
    expect(cubit.state.isSaved, isTrue);
  });
}
