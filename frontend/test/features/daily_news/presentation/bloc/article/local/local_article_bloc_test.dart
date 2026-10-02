import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_saved_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/remove_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_state.dart';

class MockGetSavedArticleUseCase extends Mock implements GetSavedArticlesUseCase {}

class MockRemoveArticleUseCase extends Mock implements RemoveArticleUseCase {}

void main() {
  late MockGetSavedArticleUseCase getSavedArticles;
  late MockRemoveArticleUseCase removeArticle;
  late LocalArticlesBloc bloc;

  const article = ArticleEntity(id: 7, url: 'https://example.com/steelers');
  final failure = Exception('Database closed');

  setUpAll(() => registerFallbackValue(article));

  setUp(() {
    getSavedArticles = MockGetSavedArticleUseCase();
    removeArticle = MockRemoveArticleUseCase();
    bloc = LocalArticlesBloc(getSavedArticles, removeArticle);
  });

  tearDown(() => bloc.close());

  test('shows the saved articles', () async {
    when(() => getSavedArticles()).thenAnswer((_) async => const DataSuccess([article]));

    bloc.add(const GetSavedArticles());

    await expectLater(bloc.stream, emits(const LocalArticlesDone([article])));
  });

  test('shows an error when the saved articles cannot be read', () async {
    when(() => getSavedArticles()).thenAnswer((_) async => DataFailed(failure));

    bloc.add(const GetSavedArticles());

    await expectLater(bloc.stream, emits(LocalArticlesError(failure)));
  });

  test('reads the saved articles again after removing one', () async {
    when(() => removeArticle(params: any(named: 'params'))).thenAnswer((_) async {});
    when(() => getSavedArticles()).thenAnswer((_) async => const DataSuccess(<ArticleEntity>[]));

    bloc.add(const RemoveArticle(article));

    await expectLater(bloc.stream, emits(const LocalArticlesDone([])));
    verify(() => removeArticle(params: article)).called(1);
  });
}
