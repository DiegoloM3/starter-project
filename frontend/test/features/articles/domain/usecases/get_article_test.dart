import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/articles/domain/exceptions/article_exceptions.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/get_articles.dart';

void main() {
  test('returns the article with the given id', () async {
    final existingArticle = (await GetArticlesUseCase().call(const NoParams())).data!.first;

    final result = await GetArticleUseCase().call(existingArticle.id);

    expect(result, isA<DataSuccess>());
    expect(result.data, existingArticle);
  });

  test('fails when the article does not exist', () async {
    final result = await GetArticleUseCase().call('missing');

    expect(result, isA<DataFailed>());
    expect(result.error, isA<ArticleNotFoundException>());
  });
}
