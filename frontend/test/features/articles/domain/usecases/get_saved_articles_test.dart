import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/get_articles.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/get_saved_articles.dart';

void main() {
  test('returns saved articles that exist', () async {
    final allArticles = (await GetArticlesUseCase().call(const NoParams())).data!;

    final result = await GetSavedArticlesUseCase().call(const NoParams());

    expect(result, isA<DataSuccess>());
    expect(result.data, isNotEmpty);
    expect(allArticles, containsAll(result.data!));
  });
}
