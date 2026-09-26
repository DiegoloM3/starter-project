import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/legacy_article_local_data_source_web.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/news_api_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

ArticleModel article({String title = 'Saved headline'}) => ArticleModel(
      id: 42,
      author: 'Author',
      title: title,
      description: 'Description',
      url: 'https://example.test/article',
      urlToImage: 'https://example.test/image.jpg',
      publishedAt: '2026-09-22T10:00:00Z',
      content: 'Content',
    );

void main() {
  test('persists bookmarks across data source instances and removes them',
      () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final first = LegacyArticleLocalDataSource(preferences);

    await first.saveArticle(article());
    final second = LegacyArticleLocalDataSource(preferences);
    expect((await second.getArticles()).single.title, 'Saved headline');

    await second.saveArticle(article(title: 'Updated headline'));
    expect((await first.getArticles()), hasLength(1));
    expect((await first.getArticles()).single.title, 'Updated headline');

    await first.removeArticle(article());
    expect(await second.getArticles(), isEmpty);
  });

  test('persists and individually removes two null-ID NewsAPI articles',
      () async {
    final response = NewsApiResponseModel.fromJson({
      'status': 'ok',
      'totalResults': 2,
      'articles': [
        {
          'author': 'Author One',
          'title': 'First headline',
          'description': 'First description',
          'url': 'https://EXAMPLE.test/first?b=2&a=1#section',
          'urlToImage': 'https://example.test/first.jpg',
          'publishedAt': '2026-09-22T10:00:00Z',
          'content': 'First content',
        },
        {
          'author': 'Author Two',
          'title': 'Second headline',
          'description': 'Second description',
          'url': 'https://example.test/second',
          'urlToImage': 'https://example.test/second.jpg',
          'publishedAt': '2026-09-22T11:00:00Z',
          'content': 'Second content',
        },
      ],
    });
    expect(response.articles.every((article) => article.id == null), isTrue);

    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final first = LegacyArticleLocalDataSource(preferences);

    await first.saveArticle(response.articles[0]);
    await first.saveArticle(response.articles[1]);

    final second = LegacyArticleLocalDataSource(preferences);
    final reloaded = await second.getArticles();
    expect(reloaded, hasLength(2));
    expect(reloaded.map((article) => article.title),
        containsAll(<String?>['First headline', 'Second headline']));

    await second.removeArticle(
      const ArticleModel(url: 'https://example.test/first?a=1&b=2'),
    );

    final remaining = await first.getArticles();
    expect(remaining, hasLength(1));
    expect(remaining.single.url, 'https://example.test/second');
  });

  test('persists sparse article fields without changing its bookmark identity',
      () async {
    const sparse = ArticleModel(
      title: 'Oil Prices Fall on U.S.-Iran Diplomacy Hopes - WSJ',
      url: 'https://example.test/wsj/oil-prices',
      publishedAt: '2026-09-23T08:00:00Z',
    );
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final first = LegacyArticleLocalDataSource(preferences);

    await first.saveArticle(sparse);
    final reloaded = await first.getArticles();

    expect(reloaded, hasLength(1));
    expect(articleBookmarkKey(reloaded.single), articleBookmarkKey(sparse));
    expect(reloaded.single.title, sparse.title);
    expect(reloaded.single.url, sparse.url);
    expect(reloaded.single.publishedAt, sparse.publishedAt);
  });
}
