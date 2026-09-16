import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_saved_articles.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  test('returns the repository result unchanged', () async {
    final saved = MockSavedArticleRepository();
    final article = buildArticle();
    when(() => saved.getSavedArticles()).thenAnswer((_) async => DataSuccess([article]));

    final result = await GetSavedArticlesUseCase(saved)(const NoParams());

    expect(result.dataOrNull, [article]);
  });
}
