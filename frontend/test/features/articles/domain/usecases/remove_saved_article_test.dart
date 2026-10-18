import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/get_articles.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/remove_saved_article.dart';

void main() {
  test('removes a saved article', () async {
    final article = (await GetArticlesUseCase().call(const NoParams())).data!.first;

    final result = await RemoveSavedArticleUseCase().call(article.id);

    expect(result, isA<DataSuccess>());
  });
}
