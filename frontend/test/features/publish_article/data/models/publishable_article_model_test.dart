import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/publish_article/data/models/publishable_article_model.dart';

void main() {
  final publishedAt = DateTime.utc(2026, 9, 18, 12);
  final createdAt = DateTime.utc(2026, 9, 18, 12, 1);
  final updatedAt = DateTime.utc(2026, 9, 18, 12, 2);

  Map<String, dynamic> createRawData() {
    return {
      'author': 'Jane Doe',
      'title': 'How Technology Is Changing Fitness',
      'description': 'A short article description.',
      'content': 'The complete article content.',
      'thumbnailURL':
          'https://firebasestorage.googleapis.com/example-thumbnail.jpg',
      'publishedAt': publishedAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  group('PublishableArticleModel.fromRawData', () {
    test('creates a model from valid raw data', () {
      final model = PublishableArticleModel.fromRawData(
        id: 'article-1',
        data: createRawData(),
      );

      expect(model.id, 'article-1');
      expect(model.author, 'Jane Doe');
      expect(model.title, 'How Technology Is Changing Fitness');
      expect(model.description, 'A short article description.');
      expect(model.content, 'The complete article content.');
      expect(
        model.thumbnailUrl,
        'https://firebasestorage.googleapis.com/example-thumbnail.jpg',
      );
      expect(model.publishedAt, publishedAt);
      expect(model.createdAt, createdAt);
      expect(model.updatedAt, updatedAt);
    });

    test('throws FormatException when a required field is missing', () {
      final data = createRawData()..remove('title');

      expect(
        () => PublishableArticleModel.fromRawData(
          id: 'article-1',
          data: data,
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when a field has an invalid type', () {
      final data = createRawData()..['publishedAt'] = '2026-09-18';

      expect(
        () => PublishableArticleModel.fromRawData(
          id: 'article-1',
          data: data,
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when an unexpected field is present', () {
      final data = createRawData()..['id'] = 'article-1';

      expect(
        () => PublishableArticleModel.fromRawData(
          id: 'article-1',
          data: data,
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });

  test('toEntity returns an independent domain entity', () {
    final model = PublishableArticleModel.fromRawData(
      id: 'article-1',
      data: createRawData(),
    );

    final entity = model.toEntity();

    expect(entity.runtimeType, isNot(PublishableArticleModel));
    expect(entity.id, model.id);
    expect(entity.author, model.author);
    expect(entity.title, model.title);
    expect(entity.description, model.description);
    expect(entity.content, model.content);
    expect(entity.thumbnailUrl, model.thumbnailUrl);
    expect(entity.publishedAt, model.publishedAt);
    expect(entity.createdAt, model.createdAt);
    expect(entity.updatedAt, model.updatedAt);
  });
}
