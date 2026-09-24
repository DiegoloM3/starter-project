import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_failures.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/params/delete_article_params.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/delete_article.dart';

import '../../../../helpers/fake_journalist_article_repository.dart';

void main() {
  late FakeJournalistArticleRepository repository;
  late DeleteArticleUseCase deleteArticle;

  setUp(() {
    repository = FakeJournalistArticleRepository();
    deleteArticle = DeleteArticleUseCase(repository);
  });

  test('asks the repository to delete the given article', () async {
    final result = await deleteArticle(const DeleteArticleParams('article-1'));

    expect(result, isA<DataSuccess>());
    expect(repository.lastDeletedArticleId, 'article-1');
  });

  test('propagates a repository failure', () async {
    repository.deleteResult = const DataFailed(
      ArticleNotFoundException('article-1'),
    );

    final result = await deleteArticle(const DeleteArticleParams('article-1'));

    expect(result, isA<DataFailed>());
    expect(result.error, isA<ArticleNotFoundException>());
  });
}
