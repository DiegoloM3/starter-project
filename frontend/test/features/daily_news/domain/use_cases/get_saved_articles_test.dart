import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_saved_articles.dart';

import '../../../../helpers/fake_article_repository.dart';

void main() {
  late FakeArticleRepository repository;
  late GetSavedArticlesUseCase useCase;

  setUp(() {
    repository = FakeArticleRepository();
    useCase = GetSavedArticlesUseCase(repository);
  });

  test('lists what the reader kept', () async {
    repository.savedArticles.add(newsArticle(title: 'Retro Vinyl Returns'));

    final result = await useCase(const NoParams());

    expect(result, isA<DataSuccess>());
    expect(result.data!.single.title, 'Retro Vinyl Returns');
  });

  test('an empty list is an answer, not a failure', () async {
    final result = await useCase(const NoParams());

    expect(result, isA<DataSuccess>());
    expect(result.data, isEmpty);
  });

  /// The saved articles live on the device, which can fail too. Reporting it
  /// is what lets the Saved tab say so instead of spinning.
  test('reports a database that could not be read', () async {
    repository.savedArticlesResult = DataFailed(Exception('disk error'));

    expect(await useCase(const NoParams()), isA<DataFailed>());
  });
}
