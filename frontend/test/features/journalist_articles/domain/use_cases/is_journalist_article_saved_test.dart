import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/saved_journalist_article_repository.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/is_journalist_article_saved.dart';

class MockSavedJournalistArticleRepository extends Mock implements SavedJournalistArticleRepository {}

void main() {
  test('asks the repository whether the article is saved', () async {
    final repository = MockSavedJournalistArticleRepository();
    when(() => repository.isArticleSaved('article1')).thenAnswer((_) async => const DataSuccess(true));

    final dataState = await IsJournalistArticleSavedUseCase(repository)(params: 'article1');

    expect(dataState.data, isTrue);
  });
}
