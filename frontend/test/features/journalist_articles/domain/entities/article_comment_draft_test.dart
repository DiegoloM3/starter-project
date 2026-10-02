import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_comment_draft.dart';

void main() {
  ArticleCommentDraftEntity draftWith(String content) {
    return ArticleCommentDraftEntity(articleId: 'article1', content: content);
  }

  test('a comment with text is valid', () {
    final draft = draftWith('Great news for the rural towns.');

    expect(draft.contentError, isNull);
    expect(draft.isValid, isTrue);
  });

  test('a new draft is empty and not valid', () {
    const draft = ArticleCommentDraftEntity(articleId: 'article1');

    expect(draft.content, '');
    expect(draft.contentError, ArticleCommentDraftError.blank);
    expect(draft.isValid, isFalse);
  });

  test('a comment made only of whitespace is blank', () {
    expect(draftWith(' \n\t ').contentError, ArticleCommentDraftError.blank);
  });

  test('accepts up to ${ArticleCommentDraftEntity.maxContentLength} characters', () {
    final longestComment = 'a' * ArticleCommentDraftEntity.maxContentLength;

    expect(draftWith(longestComment).isValid, isTrue);
    expect(draftWith('${longestComment}a').contentError, ArticleCommentDraftError.tooLong);
  });

  test('copyWith keeps the article', () {
    final edited = draftWith('First').copyWith(content: 'Second');

    expect(edited, draftWith('Second'));
  });
}
