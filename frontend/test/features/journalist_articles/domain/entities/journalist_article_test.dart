import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_failures.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_status.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/journalist_article.dart';

import '../../../../helpers/article_fixtures.dart';

void main() {
  group('validateAsDraft', () {
    test('accepts an incomplete draft as long as it is identifiable', () {
      const draft = JournalistArticleEntity(
        title: 'Working title',
        author: 'Alex Rivera',
        userId: 'journalist-1',
      );

      expect(draft.validateAsDraft(), isEmpty);
    });

    test('rejects a draft without a title', () {
      const draft = JournalistArticleEntity(
        title: '   ',
        author: 'Alex Rivera',
        userId: 'journalist-1',
      );

      expect(
        draft.validateAsDraft(),
        contains(ArticleValidationError.titleRequired),
      );
    });

    test('rejects a title longer than the schema allows', () {
      final draft = publishableArticle().copyWith(
        title: 'a' * (JournalistArticleEntity.titleMaxLength + 1),
      );

      expect(
        draft.validateAsDraft(),
        contains(ArticleValidationError.titleTooLong),
      );
    });

    test('rejects a description longer than the schema allows', () {
      final draft = publishableArticle().copyWith(
        description: 'a' * (JournalistArticleEntity.descriptionMaxLength + 1),
      );

      expect(
        draft.validateAsDraft(),
        contains(ArticleValidationError.descriptionTooLong),
      );
    });

    test('rejects an article without an author or an owner', () {
      const draft = JournalistArticleEntity(title: 'Working title');

      expect(
        draft.validateAsDraft(),
        containsAll(<ArticleValidationError>[
          ArticleValidationError.authorRequired,
          ArticleValidationError.userRequired,
        ]),
      );
    });
  });

  group('validateForPublishing', () {
    test('accepts a complete article', () {
      expect(publishableArticle().validateForPublishing(), isEmpty);
      expect(publishableArticle().canBePublished, isTrue);
    });

    test('rejects the fields a reader would miss', () {
      final incomplete = publishableArticle().copyWith(
        description: '',
        content: '',
        thumbnailUrl: '',
      );

      expect(
        incomplete.validateForPublishing(),
        containsAll(<ArticleValidationError>[
          ArticleValidationError.descriptionRequired,
          ArticleValidationError.contentRequired,
          ArticleValidationError.thumbnailRequired,
        ]),
      );
      expect(incomplete.canBePublished, isFalse);
    });
  });

  group('validate', () {
    test('applies the draft rules while the article is a draft', () {
      final incompleteDraft = publishableArticle().copyWith(content: '');

      expect(incompleteDraft.validate(), isEmpty);
    });

    test('applies the publishing rules once the article is published', () {
      final incompletePublished = publishableArticle(
        status: ArticleStatus.published,
      ).copyWith(content: '');

      expect(
        incompletePublished.validate(),
        contains(ArticleValidationError.contentRequired),
      );
    });
  });

  group('status transitions', () {
    test('markAsPublished publishes the article at the given moment', () {
      final publishedAt = DateTime(2026, 9, 22, 8, 0);

      final published = publishableArticle().markAsPublished(publishedAt);

      expect(published.status, ArticleStatus.published);
      expect(published.isPublished, isTrue);
      expect(published.publishedAt, publishedAt);
      expect(published.title, publishableArticle().title);
    });

    test('markAsDraft hides a published article without losing its data', () {
      final unpublished = publishableArticle(status: ArticleStatus.published)
          .markAsPublished(DateTime(2026, 9, 22))
          .markAsDraft();

      expect(unpublished.isDraft, isTrue);
      expect(unpublished.content, publishableArticle().content);
    });

    test('markAsDraft drops the publication date, as the rules require', () {
      final unpublished = publishableArticle(status: ArticleStatus.published)
          .markAsPublished(DateTime(2026, 9, 22))
          .markAsDraft();

      expect(unpublished.publishedAt, isNull);
    });

    test('re-publishing keeps the date the article first went public', () {
      final firstPublished = publishableArticle(status: ArticleStatus.draft)
          .markAsPublished(DateTime(2026, 9, 18));

      // Editing a published article and publishing the changes is not
      // publishing it again, and must not reorder the public feed.
      final edited = firstPublished
          .copyWith(content: 'A correction')
          .markAsPublished(DateTime(2026, 9, 25));

      expect(edited.publishedAt, DateTime(2026, 9, 18));
    });
  });

  group('isStored', () {
    test('is false until the article has an identifier', () {
      const newArticle = JournalistArticleEntity(title: 'Working title');

      expect(newArticle.isStored, isFalse);
      expect(publishableArticle().isStored, isTrue);
    });
  });
}
