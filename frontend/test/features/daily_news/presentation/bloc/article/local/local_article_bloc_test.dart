import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_saved_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/remove_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/save_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_state.dart';

class MockGetSavedArticleUseCase extends Mock implements GetSavedArticleUseCase {}

class MockSaveArticleUseCase extends Mock implements SaveArticleUseCase {}

class MockRemoveArticleUseCase extends Mock implements RemoveArticleUseCase {}

void main() {
  late MockGetSavedArticleUseCase getSavedArticles;
  late MockSaveArticleUseCase saveArticle;
  late MockRemoveArticleUseCase removeArticle;
  late LocalArticleBloc bloc;

  const article = ArticleEntity(title: 'Breaking News!');

  setUpAll(() {
    registerFallbackValue(const ArticleEntity());
  });

  setUp(() {
    getSavedArticles = MockGetSavedArticleUseCase();
    saveArticle = MockSaveArticleUseCase();
    removeArticle = MockRemoveArticleUseCase();
    bloc = LocalArticleBloc(getSavedArticles, saveArticle, removeArticle);
  });

  tearDown(() => bloc.close());

  void stubSavedArticles(List<ArticleEntity> articles) {
    when(() => getSavedArticles()).thenAnswer((_) async => articles);
  }

  group('LocalArticleBloc', () {
    test('starts loading', () {
      expect(bloc.state, const LocalArticlesLoading());
    });

    test('emits the saved articles', () async {
      stubSavedArticles([article]);

      bloc.add(const GetSavedArticles());

      await expectLater(bloc.stream, emits(const LocalArticlesDone([article])));
    });

    test('saves an article and emits the updated saved articles', () async {
      when(() => saveArticle(params: any(named: 'params'))).thenAnswer((_) async {});
      stubSavedArticles([article]);

      bloc.add(const SaveArticle(article));

      await expectLater(bloc.stream, emits(const LocalArticlesDone([article])));
      verify(() => saveArticle(params: article)).called(1);
    });

    test('removes an article and emits the updated saved articles', () async {
      when(() => removeArticle(params: any(named: 'params'))).thenAnswer((_) async {});
      stubSavedArticles([]);

      bloc.add(const RemoveArticle(article));

      await expectLater(bloc.stream, emits(const LocalArticlesDone([])));
      verify(() => removeArticle(params: article)).called(1);
    });

    test('compares events and states without failing on missing values', () {
      expect(const GetSavedArticles(), const GetSavedArticles());
      expect(const LocalArticlesLoading(), const LocalArticlesLoading());
    });
  });
}
