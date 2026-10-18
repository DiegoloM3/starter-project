import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/get_articles.dart';

void main() {
  test('returns the articles from the newest to the oldest', () async {
    final result = await GetArticlesUseCase().call(const NoParams());

    expect(result, isA<DataSuccess>());
    final publicationDates = result.data!.map((article) => article.publishedAt).toList();
    final sortedDates = [...publicationDates]..sort((a, b) => b.compareTo(a));
    expect(publicationDates, isNotEmpty);
    expect(publicationDates, sortedDates);
  });
}
