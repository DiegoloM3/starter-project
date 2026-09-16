import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  String repeat(int length) => 'x' * length;

  group('ArticleDraft.validate', () {
    test('accepts a complete draft', () {
      expect(buildDraft().validate(), isEmpty);
      expect(buildDraft().isValid, isTrue);
    });

    test('accepts a draft without a summary', () {
      expect(buildDraft(description: null).isValid, isTrue);
      expect(buildDraft(description: '   ').isValid, isTrue);
    });

    test('accepts fields at their maximum length', () {
      final draft = buildDraft(
        title: repeat(ArticleLimits.titleMaxLength),
        description: repeat(ArticleLimits.descriptionMaxLength),
        content: repeat(ArticleLimits.contentMaxLength),
      );
      expect(draft.validate(), isEmpty);
    });

    test('rejects a blank title', () {
      expect(buildDraft(title: '   ').validate(), [ArticleValidationError.emptyTitle]);
    });

    test('rejects a title over the limit', () {
      final draft = buildDraft(title: repeat(ArticleLimits.titleMaxLength + 1));
      expect(draft.validate(), [ArticleValidationError.titleTooLong]);
    });

    test('rejects a summary over the limit', () {
      final draft = buildDraft(description: repeat(ArticleLimits.descriptionMaxLength + 1));
      expect(draft.validate(), [ArticleValidationError.descriptionTooLong]);
    });

    test('rejects a blank body', () {
      expect(buildDraft(content: '\n\t').validate(), [ArticleValidationError.emptyContent]);
    });

    test('rejects a body over the limit', () {
      final draft = buildDraft(content: repeat(ArticleLimits.contentMaxLength + 1));
      expect(draft.validate(), [ArticleValidationError.contentTooLong]);
    });

    test('reports every problem at once, title first', () {
      final draft = buildDraft(title: '', content: '', description: repeat(301));
      expect(draft.validate(), [
        ArticleValidationError.emptyTitle,
        ArticleValidationError.descriptionTooLong,
        ArticleValidationError.emptyContent,
      ]);
    });

  });

  group('trimmed accessors', () {
    test('strip surrounding whitespace', () {
      final draft = buildDraft(title: '  Hi  ', content: ' body ', description: ' s ');
      expect(draft.trimmedTitle, 'Hi');
      expect(draft.trimmedContent, 'body');
      expect(draft.trimmedDescription, 's');
    });

    test('trimmedDescription is null for a blank summary', () {
      expect(buildDraft(description: '  ').trimmedDescription, isNull);
      expect(buildDraft(description: null).trimmedDescription, isNull);
    });
  });

  test('copyWith replaces only the given fields', () {
    final draft = buildDraft();
    final copy = draft.copyWith(title: 'Changed');
    expect(copy.title, 'Changed');
    expect(copy.content, draft.content);
    expect(copy.publishedAt, draft.publishedAt);
  });

}
