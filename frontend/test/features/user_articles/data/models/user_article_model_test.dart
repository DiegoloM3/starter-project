import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/user_articles/data/models/user_article_model.dart';

void main() {
  group('isDraft', () {
    test('a draft is stored with status "draft" and reads back as one', () {
      final model = UserArticleModel(
        id: 'a1',
        authorId: 'u1',
        authorName: 'Ana',
        title: '',
        description: '',
        content: '',
        thumbnailURL: '',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        isDraft: true,
      );

      expect(model.toMap()['status'], 'draft');
      expect(
        UserArticleModel.fromRawData('a1', model.toMap()).isDraft,
        isTrue,
      );
    });

    test('a published article is stored with status "published"', () {
      final model = UserArticleModel(
        id: 'a1',
        authorId: 'u1',
        authorName: 'Ana',
        title: 'Real title',
        description: 'A description long enough to pass.',
        content: 'x' * 60,
        thumbnailURL: 'https://example.com/x.jpg',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

      expect(model.toMap()['status'], 'published');
      expect(
        UserArticleModel.fromRawData('a1', model.toMap()).isDraft,
        isFalse,
      );
    });

    test('a document written before drafts existed has no status field, '
        'and reads as published, not as a draft', () {
      final entity = UserArticleModel.fromRawData('a1', {
        'authorId': 'u1',
        'authorName': 'Ana',
        'title': 'Old article',
        'description': 'From before this feature existed.',
        'content': 'x' * 60,
        'thumbnailURL': 'https://example.com/x.jpg',
      });

      expect(entity.isDraft, isFalse);
    });
  });
}
