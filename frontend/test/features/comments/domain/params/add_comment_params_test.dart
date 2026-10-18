import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/comments/domain/params/add_comment_params.dart';

void main() {
  test('removes surrounding spaces from the text', () {
    expect(AddCommentParams(articleId: 'article-1', text: '  Nice  ').text, 'Nice');
  });

  test('is valid with a text of up to the maximum length', () {
    final params = AddCommentParams(articleId: 'article-1', text: 'a' * CommentLimits.textMaxLength);

    expect(params.validationErrors, isEmpty);
  });

  test('reports an empty text, ignoring spaces', () {
    expect(AddCommentParams(articleId: 'article-1', text: '   ').validationErrors, {CommentValidationError.textEmpty});
  });

  test('reports a text longer than the maximum length', () {
    final params = AddCommentParams(articleId: 'article-1', text: 'a' * (CommentLimits.textMaxLength + 1));

    expect(params.validationErrors, {CommentValidationError.textTooLong});
  });
}
