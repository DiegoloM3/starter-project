import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/comments/domain/entities/comment.dart';

void main() {
  final comment = CommentEntity(
    id: 'comment-1',
    articleId: 'article-1',
    authorId: 'user-1',
    authorName: 'Jane Doe',
    text: 'Great article',
    createdAt: DateTime(2026, 10, 17),
  );

  test('knows its author', () {
    expect(comment.isAuthoredBy('user-1'), isTrue);
    expect(comment.isAuthoredBy('user-2'), isFalse);
    expect(comment.isAuthoredBy(null), isFalse);
  });
}
