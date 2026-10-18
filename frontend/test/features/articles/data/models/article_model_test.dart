import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/articles/data/models/article_model.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_content.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_topic.dart';

void main() {
  Map<String, dynamic> buildRawData({Object? publishedAt, List<Object?> topics = const ['sports', 'gaming']}) {
    return {
      'title': 'Title',
      'description': 'Description',
      'content': '[{"insert":"Content\\n"}]',
      'thumbnailURL': 'https://example.com/image.jpg',
      'topics': topics,
      'publishedAt': publishedAt ?? DateTime(2026, 10, 16),
      'authorId': 'journalist-1',
      'authorName': 'Jane Doe',
    };
  }

  test('parses an article document', () {
    final model = ArticleModel.fromRawData('article-1', buildRawData());

    expect(
      model.toEntity(),
      ArticleEntity(
        id: 'article-1',
        title: 'Title',
        description: 'Description',
        content: const ArticleContent('[{"insert":"Content\\n"}]'),
        thumbnailURL: 'https://example.com/image.jpg',
        topics: const [ArticleTopic.sports, ArticleTopic.gaming],
        publishedAt: DateTime(2026, 10, 16),
        authorId: 'journalist-1',
        authorName: 'Jane Doe',
      ),
    );
  });

  test('skips topics that the app does not know', () {
    final model = ArticleModel.fromRawData('article-1', buildRawData(topics: ['sports', 'cooking', null]));

    expect(model.topics, [ArticleTopic.sports]);
  });

  test('uses the current time while the server has not set the publication date', () {
    final before = DateTime.now();

    final model = ArticleModel.fromRawData('article-1', buildRawData()..['publishedAt'] = null);

    expect(model.publishedAt.isBefore(before), isFalse);
  });

  test('converts to a plain entity', () {
    final entity = ArticleModel.fromRawData('article-1', buildRawData()).toEntity();

    expect(entity.runtimeType, ArticleEntity);
  });
}
