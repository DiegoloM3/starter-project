import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/articles/domain/exceptions/article_exceptions.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/delete_article.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/get_articles.dart';

void main() {
  test('deletes an existing article', () async {
    final article = (await GetArticlesUseCase().call(const NoParams())).data!.first;

    final result = await DeleteArticleUseCase().call(article.id);

    expect(result, isA<DataSuccess>());
  });

  test('fails when the article does not exist', () async {
    final result = await DeleteArticleUseCase().call('missing');

    expect(result.error, isA<ArticleNotFoundException>());
  });
}
