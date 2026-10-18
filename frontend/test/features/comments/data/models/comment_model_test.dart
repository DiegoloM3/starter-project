import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/comments/data/models/comment_model.dart';
import 'package:news_app_clean_architecture/features/comments/domain/entities/comment.dart';

void main() {
  test('parses a comment document', () {
    final model = CommentModel.fromRawData('comment-1', 'article-1', {
      'authorId': 'user-1',
      'authorName': 'Jane Doe',
      'text': 'Great article',
      'createdAt': DateTime(2026, 10, 17),
    });

    expect(
      model.toEntity(),
      CommentEntity(
        id: 'comment-1',
        articleId: 'article-1',
        authorId: 'user-1',
        authorName: 'Jane Doe',
        text: 'Great article',
        createdAt: DateTime(2026, 10, 17),
      ),
    );
  });

  test('uses the current time while the server has not set the creation date', () {
    final before = DateTime.now();

    final model = CommentModel.fromRawData('comment-1', 'article-1', {'text': 'Hi'});

    expect(model.createdAt.isBefore(before), isFalse);
  });

  test('converts to a plain entity', () {
    final entity = CommentModel.fromRawData('comment-1', 'article-1', const {}).toEntity();

    expect(entity.runtimeType, CommentEntity);
  });
}
