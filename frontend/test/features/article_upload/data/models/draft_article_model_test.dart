import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/article_upload/data/models/draft_article_model.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_category.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_location.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/draft_article.dart';

void main() {
  final lastSavedAt = DateTime(2024, 6, 15, 10, 0, 0);

  DraftArticleEntity fullEntity() => DraftArticleEntity(
        id: 5,
        title: 'My Draft Title',
        description: 'A detailed description here',
        content: 'The full body content of the draft article.',
        localImagePath: '/tmp/photo.jpg',
        category: ArticleCategory.tech,
        tags: ['dart', 'flutter', 'tdd'],
        language: 'en',
        location: const ArticleLocation(
          latitude: 19.432608,
          longitude: -99.133209,
          placeName: 'Mexico City',
        ),
        lastSavedAt: lastSavedAt,
      );

  group('DraftArticleModel', () {
    group('fromEntity', () {
      test('preserves all fields from a full entity', () {
        final model = DraftArticleModel.fromEntity(fullEntity());

        expect(model.draftId, equals(5));
        expect(model.title, equals('My Draft Title'));
        expect(model.description, equals('A detailed description here'));
        expect(model.content, equals('The full body content of the draft article.'));
        expect(model.localImagePath, equals('/tmp/photo.jpg'));
        expect(model.categoryRaw, equals('tech'));
        expect(model.tagsRaw, equals('dart,flutter,tdd'));
        expect(model.language, equals('en'));
        expect(model.locationLat, equals(19.432608));
        expect(model.locationLng, equals(-99.133209));
        expect(model.locationPlaceName, equals('Mexico City'));
        expect(model.lastSavedAtMillis,
            equals(lastSavedAt.millisecondsSinceEpoch));
      });

      test('id=0 sentinel is stored as null draftId (unsaved)', () {
        final entity = fullEntity().copyWith(id: 0);
        final model = DraftArticleModel.fromEntity(entity);
        expect(model.draftId, isNull);
      });

      test('null localImagePath is preserved as null', () {
        final entity = DraftArticleEntity(
          id: 1,
          title: 'T',
          description: 'D',
          content: 'C',
          tags: const [],
          language: 'en',
          lastSavedAt: lastSavedAt,
        );
        final model = DraftArticleModel.fromEntity(entity);
        expect(model.localImagePath, isNull);
      });

      test('null category produces null categoryRaw', () {
        final entity = DraftArticleEntity(
          id: 1,
          title: 'T',
          description: 'D',
          content: 'C',
          tags: const [],
          language: 'en',
          lastSavedAt: lastSavedAt,
        );
        final model = DraftArticleModel.fromEntity(entity);
        expect(model.categoryRaw, isNull);
      });

      test('empty tags list produces empty tagsRaw string', () {
        final entity = DraftArticleEntity(
          id: 1,
          title: 'T',
          description: 'D',
          content: 'C',
          tags: const [],
          language: 'en',
          lastSavedAt: lastSavedAt,
        );
        final model = DraftArticleModel.fromEntity(entity);
        expect(model.tagsRaw, equals(''));
      });

      test('null location produces null lat/lng columns', () {
        final entity = DraftArticleEntity(
          id: 1,
          title: 'T',
          description: 'D',
          content: 'C',
          tags: const [],
          language: 'en',
          lastSavedAt: lastSavedAt,
        );
        final model = DraftArticleModel.fromEntity(entity);
        expect(model.locationLat, isNull);
        expect(model.locationLng, isNull);
        expect(model.locationPlaceName, isNull);
      });

      test('lastSavedAt is encoded as millisecondsSinceEpoch', () {
        final now = DateTime(2025, 1, 1, 12, 0, 0);
        final entity = fullEntity().copyWith(lastSavedAt: now);
        final model = DraftArticleModel.fromEntity(entity);
        expect(model.lastSavedAtMillis, equals(now.millisecondsSinceEpoch));
      });
    });

    group('toEntity', () {
      test('round-trip preserves all fields', () {
        final original = fullEntity();
        final model = DraftArticleModel.fromEntity(original);
        final restored = model.toEntity();

        expect(restored.id, equals(original.id));
        expect(restored.title, equals(original.title));
        expect(restored.description, equals(original.description));
        expect(restored.content, equals(original.content));
        expect(restored.localImagePath, equals(original.localImagePath));
        expect(restored.category, equals(original.category));
        expect(restored.tags, equals(original.tags));
        expect(restored.language, equals(original.language));
        expect(restored.location?.latitude,
            equals(original.location?.latitude));
        expect(restored.location?.longitude,
            equals(original.location?.longitude));
        expect(restored.location?.placeName,
            equals(original.location?.placeName));
        expect(restored.lastSavedAt, equals(original.lastSavedAt));
      });

      test('null category is preserved after round-trip', () {
        final entity = DraftArticleEntity(
          id: 2,
          title: 'T',
          description: 'D',
          content: 'C',
          tags: const [],
          language: 'es',
          lastSavedAt: lastSavedAt,
        );
        final restored = DraftArticleModel.fromEntity(entity).toEntity();
        expect(restored.category, isNull);
      });

      test('empty tags list is preserved after round-trip', () {
        final entity = DraftArticleEntity(
          id: 2,
          title: 'T',
          description: 'D',
          content: 'C',
          tags: const [],
          language: 'en',
          lastSavedAt: lastSavedAt,
        );
        final restored = DraftArticleModel.fromEntity(entity).toEntity();
        expect(restored.tags, isEmpty);
      });

      test('null location is preserved after round-trip', () {
        final entity = DraftArticleEntity(
          id: 2,
          title: 'T',
          description: 'D',
          content: 'C',
          tags: const [],
          language: 'en',
          lastSavedAt: lastSavedAt,
        );
        final restored = DraftArticleModel.fromEntity(entity).toEntity();
        expect(restored.location, isNull);
      });

      test('tags comma-join and re-split preserves order', () {
        final entity = DraftArticleEntity(
          id: 3,
          title: 'T',
          description: 'D',
          content: 'C',
          tags: const ['alpha', 'beta', 'gamma'],
          language: 'en',
          lastSavedAt: lastSavedAt,
        );
        final restored = DraftArticleModel.fromEntity(entity).toEntity();
        expect(restored.tags, equals(['alpha', 'beta', 'gamma']));
      });

      test('lastSavedAt millis round-trip matches original DateTime', () {
        final specific = DateTime(2024, 3, 21, 14, 30, 45);
        final entity = fullEntity().copyWith(lastSavedAt: specific);
        final restored = DraftArticleModel.fromEntity(entity).toEntity();
        expect(restored.lastSavedAt, equals(specific));
      });

      test('null draftId is restored as id=0 sentinel', () {
        final model = DraftArticleModel(
          draftId: null,
          title: 'T',
          description: 'D',
          content: 'C',
          tagsRaw: '',
          language: 'en',
          lastSavedAtMillis: lastSavedAt.millisecondsSinceEpoch,
        );
        final entity = model.toEntity();
        expect(entity.id, equals(0));
      });
    });
  });
}
