import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_status.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/journalist_stats.dart';

import '../../../../helpers/article_fixtures.dart';

/// The counting rule itself, with nothing else in the way: this is why it is
/// an entity rather than a `fold` inside a cubit.
void main() {
  test('counts every article and adds up the views', () {
    final stats = JournalistStatsEntity.of([
      publishableArticle(id: 'a-1', status: ArticleStatus.published)
          .copyWith(viewCount: 1200),
      publishableArticle(id: 'a-2', status: ArticleStatus.published)
          .copyWith(viewCount: 300),
    ]);

    expect(stats.articleCount, 2);
    expect(stats.totalViews, 1500);
  });

  /// "My articles" lists drafts too, so the number beside it has to include
  /// them — while a draft nobody could read contributes no views.
  test('drafts are counted, but bring no views with them', () {
    final stats = JournalistStatsEntity.of([
      publishableArticle(id: 'a-1', status: ArticleStatus.published)
          .copyWith(viewCount: 40),
      publishableArticle(id: 'a-2'),
    ]);

    expect(stats.articleCount, 2);
    expect(stats.totalViews, 40);
  });

  test('a journalist who has written nothing has nothing to show', () {
    const stats = JournalistStatsEntity();

    expect(stats.articleCount, 0);
    expect(stats.totalViews, 0);
    expect(stats.hasArticles, isFalse);
  });

  test('one article is enough to have something to show', () {
    final stats = JournalistStatsEntity.of([publishableArticle()]);

    expect(stats.hasArticles, isTrue);
  });
}
