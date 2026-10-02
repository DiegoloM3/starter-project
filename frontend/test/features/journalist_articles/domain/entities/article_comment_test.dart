import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_comment.dart';

void main() {
  ArticleCommentEntity commentBy(String author) {
    return ArticleCommentEntity(
      id: 'comment1',
      content: 'Great news for the rural towns.',
      author: author,
      authorId: 'johnSmithUid',
      createdAt: DateTime.utc(2026, 10, 2, 9, 41),
    );
  }

  test('the avatar shows the initials of the author', () {
    expect(commentBy('John Smith').authorInitials, 'JS');
  });

  test('the avatar shows a question mark when the author has no name', () {
    expect(commentBy(' ').authorInitials, '?');
  });
}
