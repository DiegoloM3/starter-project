import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_content.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_topic.dart';
import 'package:news_app_clean_architecture/features/articles/domain/params/article_draft.dart';
import 'package:news_app_clean_architecture/features/articles/domain/params/article_image.dart';
import 'package:news_app_clean_architecture/features/articles/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/articles/domain/repository/saved_articles_repository.dart';

class MockArticleRepository extends Mock implements ArticleRepository {}

class MockSavedArticlesRepository extends Mock implements SavedArticlesRepository {}

ArticleDraft buildValidDraft({String title = 'New title'}) {
  return ArticleDraft(
    title: title,
    description: 'New description',
    content: ArticleContent.fromPlainText('New content'),
    topics: const {ArticleTopic.sports},
  );
}

ArticleDraft buildInvalidDraft() => buildValidDraft(title: '');

ArticleImage buildValidImage() => ArticleImage(Uint8List(10));

final ArticleEntity testArticle = ArticleEntity(
  id: 'article-1',
  title: 'Title',
  description: 'Description',
  content: ArticleContent.fromPlainText('Content'),
  thumbnailURL: 'https://example.com/image.jpg',
  topics: const [ArticleTopic.sports],
  publishedAt: DateTime(2026, 10, 16),
  authorId: 'journalist-1',
  authorName: 'Jane Doe',
);
