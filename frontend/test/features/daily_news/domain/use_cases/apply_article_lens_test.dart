import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_lens.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/apply_article_lens.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  test('passes the lens and article through', () async {
    final assistant = MockArticleAssistantRepository();
    const result = ArticleLensResult(lens: ArticleLens.brief, bullets: ['a']);
    final article = buildArticle();
    when(() => assistant.apply(ArticleLens.brief, article)).thenAnswer((_) async => const DataSuccess(result));

    final outcome = await ApplyArticleLensUseCase(assistant)(
      ApplyArticleLensParams(lens: ArticleLens.brief, article: article),
    );

    expect(outcome.dataOrNull, result);
    expect(result.spokenText, 'a');
  });
}
