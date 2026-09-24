import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/models/journalist_article_model.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_status.dart';

import '../../../../helpers/article_fixtures.dart';

void main() {
  final publishedAt = DateTime(2026, 9, 18, 9, 30);

  Map<String, dynamic> rawArticle() {
    return <String, dynamic>{
      'title': 'The night bus driver',
      'description': 'A ride along the last line of the night.',
      'content': 'The depot doors open at 23:40.',
      'author': 'Alex Rivera',
      'userId': 'journalist-1',
      'thumbnailURL': 'https://storage/media/articles/journalist-1/bus.jpg',
      'status': 'published',
      'viewCount': 12,
      'publishedAt': publishedAt,
      'createdAt': publishedAt,
      'updatedAt': publishedAt,
    };
  }

  test('reads a stored document, mapping thumbnailURL onto thumbnailUrl', () {
    final model = JournalistArticleModel.fromRawData('a-1', rawArticle());

    expect(model.id, 'a-1');
    expect(model.status, ArticleStatus.published);
    expect(model.viewCount, 12);
    expect(model.publishedAt, publishedAt);
    expect(
      model.thumbnailUrl,
      'https://storage/media/articles/journalist-1/bus.jpg',
    );
  });

  test('reads a draft with no publication date', () {
    final raw = rawArticle()
      ..['status'] = 'draft'
      ..['publishedAt'] = null;

    final model = JournalistArticleModel.fromRawData('a-1', raw);

    expect(model.status, ArticleStatus.draft);
    expect(model.publishedAt, isNull);
  });

  test('reads an unknown status as a draft, the private one', () {
    final raw = rawArticle()..['status'] = 'something-else';

    expect(
      JournalistArticleModel.fromRawData('a-1', raw).status,
      ArticleStatus.draft,
    );
  });

  test('survives a document missing every optional field', () {
    final model = JournalistArticleModel.fromRawData('a-1', const {});

    expect(model.title, isEmpty);
    expect(model.viewCount, 0);
    expect(model.createdAt, isNull);
  });

  test('writes the full document on create, view count included', () {
    final document = JournalistArticleModel.fromEntity(
      publishableArticle(status: ArticleStatus.published),
    ).toRawData();

    expect(document['thumbnailURL'], isNotEmpty);
    expect(document['status'], 'published');
    expect(document['viewCount'], 0);
    expect(document.containsKey('userId'), isTrue);
  });

  test('leaves out what an author may not change on update', () {
    final update = JournalistArticleModel.fromEntity(
      publishableArticle(),
    ).toRawDataForUpdate();

    // The rules reject an update that rewrites any of these, and sending a
    // stale viewCount back would break every edit of a read article.
    expect(update.containsKey('viewCount'), isFalse);
    expect(update.containsKey('userId'), isFalse);
    expect(update.containsKey('createdAt'), isFalse);
    expect(update['title'], isNotEmpty);
  });
}
