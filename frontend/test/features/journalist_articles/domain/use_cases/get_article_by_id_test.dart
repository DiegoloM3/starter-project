import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_failures.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/params/get_article_by_id_params.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/get_article_by_id.dart';

import '../../../../helpers/article_fixtures.dart';
import '../../../../helpers/fake_journalist_article_repository.dart';

void main() {
  late FakeJournalistArticleRepository repository;
  late GetArticleByIdUseCase getArticleById;

  setUp(() {
    repository = FakeJournalistArticleRepository();
    getArticleById = GetArticleByIdUseCase(repository);
  });

  test('returns the requested article', () async {
    repository.articleByIdResult = DataSuccess(publishableArticle());

    final result = await getArticleById(
      const GetArticleByIdParams('article-1'),
    );

    expect(result, isA<DataSuccess>());
    expect(result.data?.id, 'article-1');
    expect(repository.lastRequestedArticleId, 'article-1');
  });

  test('propagates a missing article', () async {
    repository.articleByIdResult = const DataFailed(
      ArticleNotFoundException('unknown'),
    );

    final result = await getArticleById(const GetArticleByIdParams('unknown'));

    expect(result, isA<DataFailed>());
    expect(result.error, isA<ArticleNotFoundException>());
  });
}
