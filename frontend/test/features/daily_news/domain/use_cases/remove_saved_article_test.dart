import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/remove_saved_article.dart';

import '../../../../helpers/mocks.dart';

void main() {
  test('forwards the id', () async {
    final saved = MockSavedArticleRepository();
    when(() => saved.removeArticle('a')).thenAnswer((_) async => const DataSuccess(null));

    await RemoveSavedArticleUseCase(saved)('a');

    verify(() => saved.removeArticle('a')).called(1);
  });
}
