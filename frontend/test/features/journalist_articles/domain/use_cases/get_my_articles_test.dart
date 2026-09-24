import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_status.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/params/get_my_articles_params.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/get_my_articles.dart';

import '../../../../helpers/article_fixtures.dart';
import '../../../../helpers/fake_journalist_article_repository.dart';

void main() {
  late FakeJournalistArticleRepository repository;
  late GetMyArticlesUseCase getMyArticles;

  setUp(() {
    repository = FakeJournalistArticleRepository();
    getMyArticles = GetMyArticlesUseCase(repository);
  });

  test('returns the articles of the author', () async {
    repository.userArticlesResult = DataSuccess([publishableArticle()]);

    final result = await getMyArticles(
      const GetMyArticlesParams(userId: 'journalist-1'),
    );

    expect(result, isA<DataSuccess>());
    expect(result.data, hasLength(1));
    expect(repository.lastUserId, 'journalist-1');
  });

  test('forwards the status and search filters', () async {
    await getMyArticles(
      const GetMyArticlesParams(
        userId: 'journalist-1',
        status: ArticleStatus.draft,
        searchQuery: 'bus',
      ),
    );

    expect(repository.lastStatusFilter, ArticleStatus.draft);
    expect(repository.lastSearchQuery, 'bus');
  });
}
