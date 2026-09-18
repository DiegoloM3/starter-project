import 'package:news_app_clean_architecture/features/publish_article/domain/entities/publishable_article.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/repository/publish_article_repository.dart';

class FakePublishArticleRepository implements PublishArticleRepository {
  final Future<PublishableArticle> Function(PublishArticleParams)? handler;
  final calls = <PublishArticleParams>[];

  FakePublishArticleRepository({this.handler});

  @override
  Future<PublishableArticle> confirmPublication(String articleId) {
    throw StateError('This fake has no retained publication attempt.');
  }

  @override
  Future<PublishableArticle> publishArticle(PublishArticleParams params) async {
    calls.add(params);
    if (handler != null) return handler!(params);

    final instant = DateTime.utc(2026, 9, 17, 12);
    return PublishableArticle(
      id: 'article-123',
      author: params.author,
      title: params.title,
      description: params.description,
      content: params.content,
      thumbnailUrl: 'https://example.com/thumbnail.jpg',
      publishedAt: instant,
      createdAt: instant,
      updatedAt: instant,
    );
  }
}
