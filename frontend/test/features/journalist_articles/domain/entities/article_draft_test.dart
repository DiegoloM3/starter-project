import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';

final validThumbnail = ArticleThumbnailEntity(bytes: Uint8List(1024), fileExtension: 'jpg');

ArticleDraftEntity buildValidDraft() {
  return ArticleDraftEntity(
    title: 'Local startup brings clean water to 10,000 homes',
    description: 'A team of engineers has designed a low-cost filter.',
    content: 'When the first prototype was installed last spring...',
    thumbnail: validThumbnail,
  );
}

ArticleDraftEntity buildDraftWith({
  String? title,
  String? description,
  String? content,
}) {
  final draft = buildValidDraft();
  return ArticleDraftEntity(
    title: title ?? draft.title,
    description: description ?? draft.description,
    content: content ?? draft.content,
    thumbnail: draft.thumbnail,
  );
}

void main() {
  test('a draft that follows every rule is valid', () {
    final draft = buildValidDraft();

    expect(draft.isValid, isTrue);
    expect(draft.titleError, isNull);
    expect(draft.descriptionError, isNull);
    expect(draft.contentError, isNull);
    expect(draft.thumbnailError, isNull);
  });

  test('an empty draft is not valid', () {
    expect(const ArticleDraftEntity().isValid, isFalse);
  });

  group('copyWith', () {
    test('changes only the given fields', () {
      final draft = buildValidDraft();

      final edited = draft.copyWith(title: 'A new title');

      expect(edited.title, 'A new title');
      expect(edited.description, draft.description);
      expect(edited.content, draft.content);
      expect(edited.thumbnail, draft.thumbnail);
    });

    test('adds a thumbnail to a draft without one', () {
      final edited = const ArticleDraftEntity().copyWith(thumbnail: validThumbnail);

      expect(edited.thumbnail, validThumbnail);
    });

    test('does not modify the original draft', () {
      final draft = buildValidDraft();

      draft.copyWith(title: 'A new title');

      expect(draft, buildValidDraft());
    });
  });

  final textFields = <String, ({int maxLength, ArticleDraftError? Function(ArticleDraftEntity) errorOf, ArticleDraftEntity Function(String) draftWith})>{
    'title': (
      maxLength: ArticleDraftEntity.maxTitleLength,
      errorOf: (draft) => draft.titleError,
      draftWith: (value) => buildDraftWith(title: value),
    ),
    'description': (
      maxLength: ArticleDraftEntity.maxDescriptionLength,
      errorOf: (draft) => draft.descriptionError,
      draftWith: (value) => buildDraftWith(description: value),
    ),
    'content': (
      maxLength: ArticleDraftEntity.maxContentLength,
      errorOf: (draft) => draft.contentError,
      draftWith: (value) => buildDraftWith(content: value),
    ),
  };

  textFields.forEach((field, rule) {
    group(field, () {
      test('is valid with exactly ${rule.maxLength} characters', () {
        final draft = rule.draftWith('a' * rule.maxLength);
        expect(rule.errorOf(draft), isNull);
        expect(draft.isValid, isTrue);
      });

      test('is too long with ${rule.maxLength + 1} characters', () {
        final draft = rule.draftWith('a' * (rule.maxLength + 1));
        expect(rule.errorOf(draft), ArticleDraftError.tooLong);
        expect(draft.isValid, isFalse);
      });

      test('is blank when empty', () {
        expect(rule.errorOf(rule.draftWith('')), ArticleDraftError.blank);
      });

      test('is blank when it only has whitespace', () {
        expect(rule.errorOf(rule.draftWith(' \n\t ')), ArticleDraftError.blank);
      });
    });
  });

  group('thumbnail', () {
    ArticleDraftEntity draftWithThumbnail(ArticleThumbnailEntity? thumbnail) {
      final draft = buildValidDraft();
      return ArticleDraftEntity(
        title: draft.title,
        description: draft.description,
        content: draft.content,
        thumbnail: thumbnail,
      );
    }

    test('is missing when the journalist has not chosen one', () {
      expect(draftWithThumbnail(null).thumbnailError, ArticleDraftError.missing);
    });

    test('has an unsupported type when it is not jpg, png or webp', () {
      final gif = ArticleThumbnailEntity(bytes: Uint8List(1024), fileExtension: 'gif');
      expect(draftWithThumbnail(gif).thumbnailError, ArticleDraftError.unsupportedType);
    });

    test('is too large when it is bigger than 5 MB', () {
      final hugeImage = ArticleThumbnailEntity(
        bytes: Uint8List(ArticleThumbnailEntity.maxSizeInBytes + 1),
        fileExtension: 'jpg',
      );
      expect(draftWithThumbnail(hugeImage).thumbnailError, ArticleDraftError.tooLarge);
    });
  });
}
