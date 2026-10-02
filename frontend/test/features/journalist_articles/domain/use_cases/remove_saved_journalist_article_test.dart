import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/saved_journalist_article_repository.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/remove_saved_journalist_article.dart';

class MockSavedJournalistArticleRepository extends Mock implements SavedJournalistArticleRepository {}

void main() {
  test('removes the article from the saved ones through the repository', () async {
    final repository = MockSavedJournalistArticleRepository();
    when(() => repository.removeSavedArticle('article1')).thenAnswer((_) async => const DataSuccess(null));

    final dataState = await RemoveSavedJournalistArticleUseCase(repository)(params: 'article1');

    expect(dataState, isA<DataSuccess>());
    verify(() => repository.removeSavedArticle('article1')).called(1);
  });
}
