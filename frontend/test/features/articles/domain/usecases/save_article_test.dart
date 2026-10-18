import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/articles/domain/exceptions/article_exceptions.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/get_articles.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/save_article.dart';

void main() {
  test('saves an existing article', () async {
    final article = (await GetArticlesUseCase().call(const NoParams())).data!.first;

    final result = await SaveArticleUseCase().call(article.id);

    expect(result, isA<DataSuccess>());
  });

  test('fails when the article does not exist', () async {
    final result = await SaveArticleUseCase().call('missing');

    expect(result.error, isA<ArticleNotFoundException>());
  });
}
