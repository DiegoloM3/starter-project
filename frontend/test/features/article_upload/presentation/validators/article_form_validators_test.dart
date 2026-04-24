import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/validators/article_form_validators.dart';

void main() {
  group('ArticleFormValidators.validateTitle', () {
    test('returns error for null', () {
      expect(ArticleFormValidators.validateTitle(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(ArticleFormValidators.validateTitle(''), isNotNull);
    });

    test('returns error for 4-character title', () {
      expect(ArticleFormValidators.validateTitle('abcd'), isNotNull);
    });

    test('returns null for exactly 5 characters', () {
      expect(ArticleFormValidators.validateTitle('abcde'), isNull);
    });

    test('returns error for 121-character title', () {
      expect(
        ArticleFormValidators.validateTitle('a' * 121),
        isNotNull,
      );
    });

    test('returns null for valid title', () {
      expect(ArticleFormValidators.validateTitle('A valid title'), isNull);
    });
  });

  group('ArticleFormValidators.validateContent', () {
    test('returns error for null', () {
      expect(ArticleFormValidators.validateContent(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(ArticleFormValidators.validateContent(''), isNotNull);
    });

    test('returns error for 49 characters', () {
      expect(ArticleFormValidators.validateContent('a' * 49), isNotNull);
    });

    test('returns null for exactly 50 characters', () {
      expect(ArticleFormValidators.validateContent('a' * 50), isNull);
    });

    test('returns error for content shorter than 50 chars', () {
      expect(
        ArticleFormValidators.validateContent('This is a short article.'),
        isNotNull,
      );
    });

    test('returns null for long content', () {
      expect(
        ArticleFormValidators.validateContent('a' * 500),
        isNull,
      );
    });
  });

  group('ArticleFormValidators.isFormReady', () {
    test('returns false when title invalid', () {
      expect(
        ArticleFormValidators.isFormReady(
          title: 'ab',
          content: 'a' * 50,
          hasThumbnail: true,
        ),
        isFalse,
      );
    });

    test('returns false when content invalid', () {
      expect(
        ArticleFormValidators.isFormReady(
          title: 'Valid title',
          content: 'short',
          hasThumbnail: true,
        ),
        isFalse,
      );
    });

    test('returns false when no thumbnail', () {
      expect(
        ArticleFormValidators.isFormReady(
          title: 'Valid title',
          content: 'a' * 50,
          hasThumbnail: false,
        ),
        isFalse,
      );
    });

    test('returns true when all conditions met', () {
      expect(
        ArticleFormValidators.isFormReady(
          title: 'Valid title',
          content: 'a' * 50,
          hasThumbnail: true,
        ),
        isTrue,
      );
    });
  });
}
