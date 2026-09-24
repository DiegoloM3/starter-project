import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/params/increment_article_view_count_params.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/increment_article_view_count.dart';

import '../../../../helpers/fake_journalist_article_repository.dart';

void main() {
  late FakeJournalistArticleRepository repository;
  late IncrementArticleViewCountUseCase incrementViewCount;

  setUp(() {
    repository = FakeJournalistArticleRepository();
    incrementViewCount = IncrementArticleViewCountUseCase(repository);
  });

  test('forwards the article id to the repository', () async {
    final result = await incrementViewCount(
        const IncrementArticleViewCountParams('article-1'));

    expect(result, isA<DataSuccess>());
    expect(repository.incrementViewCountCallCount, 1);
    expect(repository.lastViewedArticleId, 'article-1');
  });
}
