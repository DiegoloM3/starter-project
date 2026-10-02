import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/is_article_saved.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/remove_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/save_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/bookmark/article_bookmark_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/bookmark/article_bookmark_state.dart';

class MockIsArticleSavedUseCase extends Mock implements IsArticleSavedUseCase {}

class MockSaveArticleUseCase extends Mock implements SaveArticleUseCase {}

class MockRemoveArticleUseCase extends Mock implements RemoveArticleUseCase {}

void main() {
  late MockIsArticleSavedUseCase isArticleSaved;
  late MockSaveArticleUseCase saveArticle;
  late MockRemoveArticleUseCase removeArticle;
  late ArticleBookmarkCubit cubit;

  const article = ArticleEntity(title: 'A headline', url: 'https://example.com/news');

  setUp(() {
    isArticleSaved = MockIsArticleSavedUseCase();
    saveArticle = MockSaveArticleUseCase();
    removeArticle = MockRemoveArticleUseCase();
    cubit = ArticleBookmarkCubit(isArticleSaved, saveArticle, removeArticle, article);
    when(() => saveArticle(params: article)).thenAnswer((_) async {});
    when(() => removeArticle(params: article)).thenAnswer((_) async {});
  });

  tearDown(() => cubit.close());

  Future<void> loadBookmark({required bool isSaved}) async {
    when(() => isArticleSaved(params: article)).thenAnswer((_) async => DataSuccess(isSaved));
    await cubit.loadBookmark();
  }

  test('shows whether the news article is saved', () async {
    await loadBookmark(isSaved: true);

    expect(cubit.state, const ArticleBookmarkSuccess(true));
  });

  test('saves an article that is not saved', () async {
    await loadBookmark(isSaved: false);

    final states = expectLater(
      cubit.stream,
      emitsInOrder([const ArticleBookmarkInProgress(false), const ArticleBookmarkChanged(true)]),
    );
    await cubit.toggleBookmark();
    await states;
    verify(() => saveArticle(params: article)).called(1);
  });

  test('removes an article that is saved', () async {
    await loadBookmark(isSaved: true);

    await cubit.toggleBookmark();

    expect(cubit.state, const ArticleBookmarkChanged(false));
    verify(() => removeArticle(params: article)).called(1);
  });

  test('shows the article as not saved when that cannot be checked', () async {
    when(() => isArticleSaved(params: article)).thenAnswer((_) async => DataFailed(Exception('Database closed')));

    await cubit.loadBookmark();

    expect(cubit.state, const ArticleBookmarkSuccess(false));
  });
}
