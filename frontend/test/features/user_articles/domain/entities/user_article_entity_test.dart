import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';

const _longContent =
    'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

UserArticleEntity _article({
  String title = 'Clean architecture',
  String content = _longContent,
  String thumbnailURL = 'https://cdn.test/thumb.jpg',
  UserArticleStatus status = UserArticleStatus.draft,
}) {
  return UserArticleEntity(
    id: 'a1',
    authorId: 'u1',
    authorName: 'Author',
    title: title,
    description: 'desc',
    content: content,
    thumbnailURL: thumbnailURL,
    publishedAt: DateTime(2026, 4, 24),
    updatedAt: DateTime(2026, 4, 24),
    status: status,
  );
}

void main() {
  group('UserArticleEntity', () {
    test('canPublish is true when all rules pass', () {
      expect(_article().canPublish, isTrue);
    });

    test('canPublish is false when title shorter than 5 chars', () {
      expect(_article(title: 'hi').canPublish, isFalse);
    });

    test('canPublish is false when content shorter than 50 chars', () {
      expect(_article(content: 'short').canPublish, isFalse);
    });

    test('canPublish is false when thumbnailURL is empty', () {
      expect(_article(thumbnailURL: '').canPublish, isFalse);
    });

    test('isPublished reflects the status enum', () {
      expect(_article().isPublished, isFalse);
      expect(
        _article(status: UserArticleStatus.published).isPublished,
        isTrue,
      );
    });
  });
}
