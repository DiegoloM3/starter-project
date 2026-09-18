import 'package:news_app_clean_architecture/features/publish_article/domain/entities/publishable_article.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/repository/read_published_articles_repository.dart';

class FakeReadPublishedArticlesRepository
    implements ReadPublishedArticlesRepository {
  List<PublishableArticle> articles = const [];
  Object? error;
  int calls = 0;

  @override
  Future<List<PublishableArticle>> getPublishedArticles() async {
    calls += 1;
    if (error != null) throw error!;
    return articles;
  }
}

PublishableArticle publishedArticle({
  String id = 'article-1',
  String title = 'Published title',
  DateTime? publishedAt,
}) {
  final timestamp = publishedAt ?? DateTime.utc(2026, 9, 18);
  return PublishableArticle(
    id: id,
    author: 'Jane Doe',
    title: title,
    description: 'Published description',
    content: 'Complete published content',
    thumbnailUrl: 'https://example.com/thumbnail.jpg',
    publishedAt: timestamp,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}
