import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/delete_article.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/articles/presentation/bloc/article_detail/article_detail_cubit.dart';
import 'package:news_app_clean_architecture/features/articles/presentation/bloc/article_detail/article_detail_state.dart';

import '../article_presentation_test_data.dart';

class MockGetArticleUseCase extends Mock implements GetArticleUseCase {}

class MockDeleteArticleUseCase extends Mock implements DeleteArticleUseCase {}

void main() {
  late MockGetArticleUseCase getArticle;
  late MockDeleteArticleUseCase deleteArticle;
  final article = buildArticle();

  setUp(() {
    getArticle = MockGetArticleUseCase();
    deleteArticle = MockDeleteArticleUseCase();
  });

  ArticleDetailCubit buildCubit() => ArticleDetailCubit(article, getArticle, deleteArticle);

  test('starts showing the given article', () {
    expect(buildCubit().state, ArticleDetailState(article: article));
  });

  blocTest<ArticleDetailCubit, ArticleDetailState>(
    'shows the latest version of the article after refreshing',
    setUp:
        () =>
            when(() => getArticle(article.id)).thenAnswer((_) async => DataSuccess(article.copyWith(title: 'Edited'))),
    build: buildCubit,
    act: (cubit) => cubit.refresh(),
    expect: () => [ArticleDetailState(article: article.copyWith(title: 'Edited'))],
  );

  blocTest<ArticleDetailCubit, ArticleDetailState>(
    'deletes the article',
    setUp: () => when(() => deleteArticle(article.id)).thenAnswer((_) async => const DataSuccess(null)),
    build: buildCubit,
    act: (cubit) => cubit.delete(),
    expect:
        () => [
          ArticleDetailState(article: article, status: ArticleDetailStatus.deleting),
          ArticleDetailState(article: article, status: ArticleDetailStatus.deleted),
        ],
  );

  blocTest<ArticleDetailCubit, ArticleDetailState>(
    'reports when the article could not be deleted',
    setUp: () => when(() => deleteArticle(article.id)).thenAnswer((_) async => DataFailed(Exception('offline'))),
    build: buildCubit,
    act: (cubit) => cubit.delete(),
    expect:
        () => [
          ArticleDetailState(article: article, status: ArticleDetailStatus.deleting),
          ArticleDetailState(article: article, status: ArticleDetailStatus.deleteFailure),
        ],
  );
}
