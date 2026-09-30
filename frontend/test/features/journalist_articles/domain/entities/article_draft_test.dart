import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';

const validThumbnail = ArticleThumbnailEntity(localPath: '/gallery/photo.jpg', sizeInBytes: 1024);

const validDraft = ArticleDraftEntity(
  title: 'Breaking News!',
  content: '## Subtitle\n\nThis is **breaking** news.',
  author: 'Daily News Staff',
  thumbnail: validThumbnail,
);

void main() {
  group('errors', () {
    test('a complete draft is valid', () {
      expect(validDraft.errors, isEmpty);
      expect(validDraft.isValid, isTrue);
    });

    test('an empty draft reports every required field', () {
      expect(const ArticleDraftEntity().errors, {
        ArticleDraftError.titleEmpty,
        ArticleDraftError.contentEmpty,
        ArticleDraftError.authorEmpty,
        ArticleDraftError.thumbnailMissing,
      });
    });

    test('whitespace-only text counts as empty', () {
      final draft = validDraft.withTitle('  \n ').withContent('\t').withAuthor(' ');

      expect(draft.errors, {
        ArticleDraftError.titleEmpty,
        ArticleDraftError.contentEmpty,
        ArticleDraftError.authorEmpty,
      });
    });
  });

  group('length limits (UTF-16 code units, like the Firestore rules)', () {
    final limits = {
      'title': (ArticleDraftEntity.titleMaxLength, ArticleDraftError.titleTooLong, validDraft.withTitle),
      'content': (ArticleDraftEntity.contentMaxLength, ArticleDraftError.contentTooLong, validDraft.withContent),
      'author': (ArticleDraftEntity.authorMaxLength, ArticleDraftError.authorTooLong, validDraft.withAuthor),
    };

    limits.forEach((field, limit) {
      final (maxLength, tooLongError, draftWith) = limit;

      test('accepts a $field of exactly $maxLength characters', () {
        expect(draftWith('a' * maxLength).errors, isEmpty);
      });

      test('rejects a $field of ${maxLength + 1} characters', () {
        expect(draftWith('a' * (maxLength + 1)).errors, {tooLongError});
      });
    });

    test('limits match backend/firestore.rules', () {
      expect(ArticleDraftEntity.titleMaxLength, 100);
      expect(ArticleDraftEntity.contentMaxLength, 10000);
      expect(ArticleDraftEntity.authorMaxLength, 60);
      expect(ArticleDraftEntity.descriptionMaxLength, 300);
    });

    test('an emoji counts as 2: 50 emoji fit in the title, 51 do not', () {
      expect(validDraft.withTitle('😀' * 50).errors, isEmpty);
      expect(validDraft.withTitle('😀' * 51).errors, {ArticleDraftError.titleTooLong});
    });
  });

  group('thumbnail', () {
    test('rejects unsupported formats', () {
      final draft = validDraft.withThumbnail(const ArticleThumbnailEntity(localPath: '/a.heic', sizeInBytes: 10));

      expect(draft.errors, {ArticleDraftError.thumbnailUnsupportedFormat});
    });

    test('rejects images over 5 MB', () {
      const heavyThumbnail = ArticleThumbnailEntity(
        localPath: '/a.png',
        sizeInBytes: ArticleThumbnailEntity.maxSizeInBytes + 1,
      );

      expect(validDraft.withThumbnail(heavyThumbnail).errors, {ArticleDraftError.thumbnailTooLarge});
    });
  });

  group('description', () {
    test('is the content without Markdown syntax', () {
      const content = '## A heading\n\n'
          'Some **bold**, *italic*, __strong__, _em_, ~~old~~ and `code`.\n\n'
          '> A quote\n'
          '- first\n'
          '* second\n'
          '1. third\n'
          'A [link](https://example.com) and an image ![alt](https://example.com/a.png).';

      expect(
        validDraft.withContent(content).description,
        'A heading Some bold, italic, strong, em, old and code. A quote first second third A link and an image .',
      );
    });

    test('is empty when the content is empty', () {
      expect(const ArticleDraftEntity().description, '');
    });

    test('is truncated to 300 characters', () {
      final description = validDraft.withContent('a' * 500).description;

      expect(description.length, ArticleDraftEntity.descriptionMaxLength);
    });

    test('never splits an emoji in half when truncating', () {
      final content = '${'a' * 299}😀b';

      expect(validDraft.withContent(content).description, 'a' * 299);
    });
  });

  group('trimmed', () {
    test('removes surrounding whitespace from every text field', () {
      final draft = validDraft.withTitle('  Title  ').withContent('\nBody\n').withAuthor(' Me ').trimmed();

      expect(draft.title, 'Title');
      expect(draft.content, 'Body');
      expect(draft.author, 'Me');
      expect(draft.thumbnail, validThumbnail);
    });
  });

  group('immutability', () {
    test('with* methods return a new draft and leave the original untouched', () {
      final edited = validDraft.withTitle('Edited');

      expect(edited.title, 'Edited');
      expect(validDraft.title, 'Breaking News!');
    });
  });

  group('isBlank', () {
    test('is true for a new draft, even signed', () {
      expect(const ArticleDraftEntity().isBlank, isTrue);
      expect(const ArticleDraftEntity(author: 'Daily News Staff').isBlank, isTrue);
    });

    test('ignores whitespace', () {
      expect(const ArticleDraftEntity(title: ' ', content: '\n\n').isBlank, isTrue);
    });

    test('is false once there is a title, content or thumbnail', () {
      const thumbnail = ArticleThumbnailEntity(localPath: '/gallery/photo.jpg', sizeInBytes: 1024);

      expect(const ArticleDraftEntity(title: 'T').isBlank, isFalse);
      expect(const ArticleDraftEntity(content: 'C').isBlank, isFalse);
      expect(const ArticleDraftEntity(thumbnail: thumbnail).isBlank, isFalse);
    });
  });

  group('writing statistics', () {
    test('counts the words without the Markdown syntax', () {
      expect(const ArticleDraftEntity(content: '## A title\n\nSome **bold** words.').wordCount, 5);
      expect(const ArticleDraftEntity().wordCount, 0);
    });

    test('estimates the reading time at 200 words per minute', () {
      expect(ArticleDraftEntity(content: 'word ' * 199).readingTimeInMinutes, 1);
      expect(ArticleDraftEntity(content: 'word ' * 401).readingTimeInMinutes, 3);
    });
  });
}
