import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/comments/data/models/comment_model.dart';

void main() {
  test('CommentModel serializes new comments as non-deleted documents', () {
    final model = CommentModel(
      articleId: 'article-1',
      authorId: 'user-1',
      authorName: 'Reporter',
      authorPhotoUrl: 'https://example.com/avatar.png',
      text: 'Hello world',
      createdAt: DateTime(2026),
      replyTo: 'parent-1',
      isDeleted: false,
    );

    final map = model.toMap();

    expect(map['authorId'], 'user-1');
    expect(map['authorName'], 'Reporter');
    expect(map['authorPhotoUrl'], 'https://example.com/avatar.png');
    expect(map['text'], 'Hello world');
    expect(map['replyTo'], 'parent-1');
    expect(map['isDeleted'], isFalse);
  });
}
