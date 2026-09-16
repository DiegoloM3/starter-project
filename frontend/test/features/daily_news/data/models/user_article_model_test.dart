import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/user_article_model.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/thumbnail_reference.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  final publishedAt = DateTime.utc(2026, 9, 15, 10);

  test('fromRawData reads every schema field and optional nulls', () {
    final model = UserArticleModel.fromRawData('doc-1', {
      'title': 'Sea wall',
      'description': null,
      'content': 'Body',
      'author': 'Ada',
      'authorId': 'uid-1',
      'category': 'science',
      'thumbnailURL': null,
      'thumbnailPath': null,
      'publishedAt': publishedAt,
    });

    expect(model.source, ArticleSource.user);
    expect(model.description, isNull);
    expect(model.imageUrl, isNull);
    expect(model.category, NewsCategory.science);
    expect(model.publishedAt, publishedAt);
    expect(model.isOwnedBy('uid-1'), isTrue);
  });

  test('a malformed document renders instead of crashing', () {
    final model = UserArticleModel.fromRawData('bad', {'title': 42, 'category': 'nope'});

    expect(model.title, '');
    expect(model.category, NewsCategory.general);
    expect(model.publishedAt, DateTime.fromMillisecondsSinceEpoch(0, isUtc: true));
  });

  test('fromDraft + toRawData produce exactly the schema fields with nulls for absent optionals', () {
    final model = UserArticleModel.fromDraft(
      id: '',
      draft: buildDraft(description: '  ', publishedAt: publishedAt),
      authorId: 'uid-1',
      authorName: 'Ada',
    );

    expect(model.toRawData(), {
      'title': 'A valid title',
      'description': null,
      'content': 'A valid body.',
      'author': 'Ada',
      'authorId': 'uid-1',
      'category': 'general',
      'thumbnailURL': null,
      'thumbnailPath': null,
      'publishedAt': publishedAt,
    });
  });

  test('a thumbnail reference lands in both URL and path', () {
    const reference = ThumbnailReference(url: 'https://x/y?alt=media', path: 'media/articles/y');
    final model = UserArticleModel.fromDraft(
      id: 'doc-2',
      draft: buildDraft(),
      authorId: 'uid-1',
      authorName: 'Ada',
      thumbnail: reference,
    );

    expect(model.toRawData()['thumbnailURL'], reference.url);
    expect(model.toRawData()['thumbnailPath'], reference.path);
  });
}
