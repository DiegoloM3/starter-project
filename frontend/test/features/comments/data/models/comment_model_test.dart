import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/comments/data/models/comment.model.dart';
import 'package:news_app_clean_architecture/features/comments/domain/entities/comment.entity.dart';

void main() {
  const tJson = {
    'id': 'c1',
    'articleId': 'article-1',
    'authorId': 'user-1',
    'authorDisplayName': 'Ada',
    'content': '**Great** read!',
    'createdAt': '2026-09-27T00:00:00.000Z',
  };

  const tModel = CommentModel(
    id: 'c1',
    articleId: 'article-1',
    authorId: 'user-1',
    authorDisplayName: 'Ada',
    content: '**Great** read!',
    createdAt: '2026-09-27T00:00:00.000Z',
  );

  test('fromJson parses every schema field', () {
    expect(CommentModel.fromJson(tJson), tModel);
  });

  test('toJson round-trips the schema', () {
    expect(tModel.toJson(), tJson);
  });

  test('fromRawData matches fromJson', () {
    expect(CommentModel.fromRawData(tJson), tModel);
  });

  test('toEntity converts to the domain entity', () {
    final entity = tModel.toEntity();

    expect(entity, isA<CommentEntity>());
    expect(entity.id, 'c1');
    expect(entity.articleId, 'article-1');
    expect(entity.authorId, 'user-1');
    expect(entity.content, '**Great** read!');
  });

  test('fromEntity converts back to the model', () {
    expect(CommentModel.fromEntity(tModel.toEntity()), tModel);
  });
}
