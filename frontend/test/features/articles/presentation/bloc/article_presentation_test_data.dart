import 'package:news_app_clean_architecture/features/articles/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_content.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_topic.dart';

ArticleEntity buildArticle({String id = 'article-1', String title = 'Title'}) {
  return ArticleEntity(
    id: id,
    title: title,
    description: 'Description',
    content: ArticleContent.fromPlainText('Content'),
    thumbnailURL: 'https://example.com/$id.jpg',
    topics: const [ArticleTopic.technology],
    publishedAt: DateTime(2026, 10, 16),
    authorId: 'journalist-1',
    authorName: 'Jane Doe',
  );
}
