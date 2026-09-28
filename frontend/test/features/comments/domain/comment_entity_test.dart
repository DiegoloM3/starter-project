import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/comments/domain/entities/comment.entity.dart';

CommentEntity _comment(String content) {
  return CommentEntity(
    articleId: 'article-1',
    authorId: 'user-1',
    content: content,
    createdAt: '2026-09-27T00:00:00.000Z',
  );
}

void main() {
  test('hasUsableContent is true for plain and markdown text', () {
    expect(_comment('Nice article!').hasUsableContent, isTrue);
    expect(_comment('**Bold** and `code`').hasUsableContent, isTrue);
  });

  test('hasUsableContent is false for blank content', () {
    expect(_comment('').hasUsableContent, isFalse);
    expect(_comment('   \n\t ').hasUsableContent, isFalse);
  });

  test('hasUsableContent is false beyond maxContentLength', () {
    final long = List.filled(
      CommentEntity.maxContentLength + 1,
      'a',
    ).join();
    expect(_comment(long).hasUsableContent, isFalse);
  });
}
