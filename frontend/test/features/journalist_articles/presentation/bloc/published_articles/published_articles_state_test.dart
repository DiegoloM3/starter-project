import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/published_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/published_articles/published_articles_state.dart';

final article = PublishedArticleEntity(
  id: 'article-1',
  title: 'T',
  content: 'C',
  description: 'C',
  author: 'A',
  thumbnailUrl: 'https://example.com/1.jpg',
  publishedAt: DateTime.utc(2026, 9, 28),
);

void main() {
  test('loading more keeps the articles and whether more exist', () {
    final loaded = PublishedArticlesLoaded(articles: [article], hasMore: true);

    final loadingMore = loaded.startLoadingMore();

    expect(loadingMore.isLoadingMore, isTrue);
    expect(loadingMore.articles, [article]);
    expect(loadingMore.hasMore, isTrue);
    expect(loadingMore.stopLoadingMore(), loaded);
  });

  test('errors with different causes are different', () {
    expect(PublishedArticlesError(Exception('a')), isNot(PublishedArticlesError(Exception('b'))));
  });
}
