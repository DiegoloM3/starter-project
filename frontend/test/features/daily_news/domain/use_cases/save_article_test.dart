import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/save_article.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  test('forwards the entity', () async {
    final saved = MockSavedArticleRepository();
    final article = buildArticle();
    when(() => saved.saveArticle(article)).thenAnswer((_) async => const DataSuccess(null));

    final result = await SaveArticleUseCase(saved)(article);

    expect(result.isSuccess, isTrue);
    verify(() => saved.saveArticle(article)).called(1);
  });
}
