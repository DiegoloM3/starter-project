import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/get_articles.dart';
import 'package:news_app_clean_architecture/features/articles/presentation/bloc/articles/articles_cubit.dart';
import 'package:news_app_clean_architecture/features/articles/presentation/bloc/articles/articles_state.dart';

import '../article_presentation_test_data.dart';

class MockGetArticlesUseCase extends Mock implements GetArticlesUseCase {}

void main() {
  late MockGetArticlesUseCase getArticles;
  final articles = [buildArticle(id: 'a'), buildArticle(id: 'b')];

  setUpAll(() => registerFallbackValue(const NoParams()));

  setUp(() => getArticles = MockGetArticlesUseCase());

  test('starts without articles', () {
    expect(ArticlesCubit(getArticles).state, const ArticlesState());
  });

  blocTest<ArticlesCubit, ArticlesState>(
    'loads the articles',
    setUp: () => when(() => getArticles(any())).thenAnswer((_) async => DataSuccess(articles)),
    build: () => ArticlesCubit(getArticles),
    act: (cubit) => cubit.load(),
    expect:
        () => [
          const ArticlesState(status: ArticlesStatus.loading),
          ArticlesState(status: ArticlesStatus.success, articles: articles),
        ],
  );

  blocTest<ArticlesCubit, ArticlesState>(
    'keeps the current articles while refreshing and when it fails',
    setUp: () => when(() => getArticles(any())).thenAnswer((_) async => DataFailed(Exception('offline'))),
    build: () => ArticlesCubit(getArticles),
    seed: () => ArticlesState(status: ArticlesStatus.success, articles: articles),
    act: (cubit) => cubit.load(),
    expect:
        () => [
          ArticlesState(status: ArticlesStatus.loading, articles: articles),
          ArticlesState(status: ArticlesStatus.failure, articles: articles),
        ],
  );
}
