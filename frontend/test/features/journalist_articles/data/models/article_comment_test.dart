import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/models/article_comment.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_comment.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_comment_draft.dart';

void main() {
  final createdAt = DateTime.utc(2026, 10, 2, 9, 41);
  final rawData = <String, dynamic>{
    'content': 'Great news for the rural towns.',
    'author': 'John Smith',
    'authorId': 'johnSmithUid',
    'createdAt': createdAt,
  };

  test('reads every field of a stored comment', () {
    final model = ArticleCommentModel.fromRawData('comment1', rawData);

    expect(model.id, 'comment1');
    expect(model.content, rawData['content']);
    expect(model.author, rawData['author']);
    expect(model.authorId, rawData['authorId']);
    expect(model.createdAt, createdAt);
  });

  test('converts to an entity with the same fields', () {
    final entity = ArticleCommentModel.fromRawData('comment1', rawData).toEntity();

    expect(entity, isNot(isA<ArticleCommentModel>()));
    expect(
      entity,
      ArticleCommentEntity(
        id: 'comment1',
        content: rawData['content'],
        author: rawData['author'],
        authorId: rawData['authorId'],
        createdAt: createdAt,
      ),
    );
  });

  test('builds the text of a new comment without the spaces around it', () {
    const draft = ArticleCommentDraftEntity(articleId: 'article1', content: '  Great news!\n');

    expect(ArticleCommentModel.buildRawDataOfNewComment(draft), {'content': 'Great news!'});
  });
}
