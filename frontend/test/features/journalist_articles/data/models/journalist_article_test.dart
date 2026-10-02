import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/models/journalist_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/journalist_article.dart';

void main() {
  final publishedAt = DateTime.utc(2026, 9, 30, 9);
  final rawData = <String, dynamic>{
    'title': 'Local startup brings clean water to 10,000 homes',
    'description': 'A team of engineers has designed a low-cost filter.',
    'content': 'When the first prototype was installed last spring...',
    'author': 'Jane Doe',
    'authorId': 'janeDoeUid',
    'thumbnailURL': 'https://example.com/media%2Farticles%2Farticle1.jpg',
    'publishedAt': publishedAt,
  };

  test('reads every field of a stored article', () {
    final model = JournalistArticleModel.fromRawData('article1', rawData);

    expect(model.id, 'article1');
    expect(model.title, rawData['title']);
    expect(model.description, rawData['description']);
    expect(model.content, rawData['content']);
    expect(model.author, rawData['author']);
    expect(model.authorId, rawData['authorId']);
    expect(model.thumbnailURL, rawData['thumbnailURL']);
    expect(model.publishedAt, publishedAt);
  });

  test('reads the number of comments counted by the data source', () {
    expect(JournalistArticleModel.fromRawData('article1', {...rawData, 'commentCount': 3}).commentCount, 3);
  });

  test('a new article, without a comment count, has no comments', () {
    expect(JournalistArticleModel.fromRawData('article1', rawData).commentCount, 0);
  });

  test('converts to an entity with the same fields', () {
    final entity = JournalistArticleModel.fromRawData('article1', rawData).toEntity();

    expect(entity, isNot(isA<JournalistArticleModel>()));
    expect(
      entity,
      JournalistArticleEntity(
        id: 'article1',
        title: rawData['title'],
        description: rawData['description'],
        content: rawData['content'],
        author: rawData['author'],
        authorId: rawData['authorId'],
        thumbnailURL: rawData['thumbnailURL'],
        publishedAt: publishedAt,
      ),
    );
  });

  test('builds the fields of a new article from a draft, leaving the author and the date to the data source', () {
    final draft = ArticleDraftEntity(
      title: 'A title',
      description: 'A description',
      content: 'Some content',
      thumbnail: ArticleThumbnailEntity(bytes: Uint8List(8), fileExtension: 'jpg'),
    );

    final newArticle = JournalistArticleModel.buildRawDataOfNewArticle(draft, 'https://example.com/thumb.jpg');

    expect(newArticle, {
      'title': 'A title',
      'description': 'A description',
      'content': 'Some content',
      'thumbnailURL': 'https://example.com/thumb.jpg',
    });
  });
}
