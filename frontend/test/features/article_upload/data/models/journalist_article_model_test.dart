import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/article_upload/data/models/journalist_article_model.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_category.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_status.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/journalist_article.dart';

// ignore: subtype_of_sealed_class
class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late MockDocumentSnapshot snapshot;

  final baseTimestamp = Timestamp.fromDate(DateTime(2024, 6, 15, 10, 0, 0));
  final createdTimestamp = Timestamp.fromDate(DateTime(2024, 6, 14, 8, 0, 0));
  final updatedTimestamp = Timestamp.fromDate(DateTime(2024, 6, 15, 9, 30, 0));

  Map<String, dynamic> baseData() => {
        'title': 'Flutter Testing Best Practices',
        'description': 'A comprehensive guide to testing Flutter apps.',
        'content': 'Testing is a cornerstone of reliable Flutter development.',
        'urlToImage': 'https://example.com/image.jpg',
        'publishedAt': baseTimestamp,
        'userId': 'user123',
        'userDisplayName': 'Jane Doe',
        'userPhotoUrl': 'https://example.com/photo.jpg',
        'source': 'journalist',
        'category': 'tech',
        'tags': ['flutter', 'testing'],
        'language': 'en',
        'readingTimeMinutes': 5,
        'location': {
          'latitude': 19.432608,
          'longitude': -99.133209,
          'placeName': 'Mexico City',
        },
        'status': 'published',
        'createdAt': createdTimestamp,
        'updatedAt': updatedTimestamp,
        'viewCount': 42,
        'favoriteCount': 7,
        'isDeleted': false,
      };

  setUp(() {
    snapshot = MockDocumentSnapshot();
    when(() => snapshot.id).thenReturn('article123');
    when(() => snapshot.data()).thenReturn(baseData());
  });

  group('JournalistArticleModel', () {
    group('fromRawData', () {
      test('maps all required fields correctly', () {
        final model = JournalistArticleModel.fromRawData(snapshot);

        expect(model.id, equals('article123'));
        expect(model.title, equals('Flutter Testing Best Practices'));
        expect(model.description, equals('A comprehensive guide to testing Flutter apps.'));
        expect(model.content, equals('Testing is a cornerstone of reliable Flutter development.'));
        expect(model.urlToImage, equals('https://example.com/image.jpg'));
        expect(model.publishedAt, equals(baseTimestamp.toDate()));
        expect(model.userId, equals('user123'));
        expect(model.userDisplayName, equals('Jane Doe'));
        expect(model.userPhotoUrl, equals('https://example.com/photo.jpg'));
        expect(model.source, equals('journalist'));
        expect(model.category, equals(ArticleCategory.tech));
        expect(model.tags, equals(['flutter', 'testing']));
        expect(model.language, equals('en'));
        expect(model.readingTimeMinutes, equals(5));
        expect(model.status, equals(ArticleStatus.published));
        expect(model.createdAt, equals(createdTimestamp.toDate()));
        expect(model.updatedAt, equals(updatedTimestamp.toDate()));
        expect(model.viewCount, equals(42));
        expect(model.favoriteCount, equals(7));
      });

      test('maps location when present', () {
        final model = JournalistArticleModel.fromRawData(snapshot);

        expect(model.location, isNotNull);
        expect(model.location!.latitude, equals(19.432608));
        expect(model.location!.longitude, equals(-99.133209));
        expect(model.location!.placeName, equals('Mexico City'));
      });

      test('id comes from snapshot.id, not a data field', () {
        when(() => snapshot.id).thenReturn('different-id');
        final data = baseData();
        when(() => snapshot.data()).thenReturn(data);

        final model = JournalistArticleModel.fromRawData(snapshot);
        expect(model.id, equals('different-id'));
      });

      test('null userPhotoUrl is handled gracefully', () {
        final data = baseData();
        data['userPhotoUrl'] = null;
        when(() => snapshot.data()).thenReturn(data);

        final model = JournalistArticleModel.fromRawData(snapshot);
        expect(model.userPhotoUrl, isNull);
      });

      test('null location results in null location field', () {
        final data = baseData();
        data['location'] = null;
        when(() => snapshot.data()).thenReturn(data);

        final model = JournalistArticleModel.fromRawData(snapshot);
        expect(model.location, isNull);
      });

      test('missing source falls back to journalist', () {
        final data = baseData();
        data.remove('source');
        when(() => snapshot.data()).thenReturn(data);

        final model = JournalistArticleModel.fromRawData(snapshot);
        expect(model.source, equals('journalist'));
      });

      test('missing language falls back to en', () {
        final data = baseData();
        data.remove('language');
        when(() => snapshot.data()).thenReturn(data);

        final model = JournalistArticleModel.fromRawData(snapshot);
        expect(model.language, equals('en'));
      });

      test('missing viewCount falls back to 0', () {
        final data = baseData();
        data.remove('viewCount');
        when(() => snapshot.data()).thenReturn(data);

        final model = JournalistArticleModel.fromRawData(snapshot);
        expect(model.viewCount, equals(0));
      });

      test('missing favoriteCount falls back to 0', () {
        final data = baseData();
        data.remove('favoriteCount');
        when(() => snapshot.data()).thenReturn(data);

        final model = JournalistArticleModel.fromRawData(snapshot);
        expect(model.favoriteCount, equals(0));
      });

      test('missing tags falls back to empty list', () {
        final data = baseData();
        data['tags'] = null;
        when(() => snapshot.data()).thenReturn(data);

        final model = JournalistArticleModel.fromRawData(snapshot);
        expect(model.tags, isEmpty);
      });

      test('status publishing round-trip', () {
        final data = baseData();
        data['status'] = 'publishing';
        data['urlToImage'] = 'pending://thumbnail';
        when(() => snapshot.data()).thenReturn(data);

        final model = JournalistArticleModel.fromRawData(snapshot);
        expect(model.status, equals(ArticleStatus.publishing));
        expect(model.urlToImage, equals('pending://thumbnail'));
      });

      for (final category in ArticleCategory.values) {
        test('category ${category.name} round-trips', () {
          final data = baseData();
          data['category'] = category.toApiValue();
          when(() => snapshot.data()).thenReturn(data);

          final model = JournalistArticleModel.fromRawData(snapshot);
          expect(model.category, equals(category));
        });
      }

      test('reads userId, userDisplayName and userPhotoUrl', () {
        final model = JournalistArticleModel.fromRawData(snapshot);
        expect(model.userId, equals('user123'));
        expect(model.userDisplayName, equals('Jane Doe'));
        expect(model.userPhotoUrl, equals('https://example.com/photo.jpg'));
      });

      test('isDeleted defaults to false when field absent', () {
        final data = baseData();
        data.remove('isDeleted');
        when(() => snapshot.data()).thenReturn(data);

        final model = JournalistArticleModel.fromRawData(snapshot);
        expect(model.isDeleted, isFalse);
        expect(model.deletedAt, isNull);
      });

      test('isDeleted true with deletedAt round-trip', () {
        final deletedTs = Timestamp.fromDate(DateTime(2026, 3, 10, 8, 0, 0));
        final data = baseData();
        data['isDeleted'] = true;
        data['deletedAt'] = deletedTs;
        when(() => snapshot.data()).thenReturn(data);

        final model = JournalistArticleModel.fromRawData(snapshot);
        expect(model.isDeleted, isTrue);
        expect(model.deletedAt, equals(deletedTs.toDate()));
      });
    });

    group('toFirestore', () {
      test('round-trip: toFirestore output matches fromRawData input', () {
        final model = JournalistArticleModel.fromRawData(snapshot);
        final map = model.toFirestore();

        expect(map['title'], equals('Flutter Testing Best Practices'));
        expect(map['description'], equals('A comprehensive guide to testing Flutter apps.'));
        expect(map['urlToImage'], equals('https://example.com/image.jpg'));
        expect(map['userId'], equals('user123'));
        expect(map['category'], equals('tech'));
        expect(map['status'], equals('published'));
        expect(map['tags'], equals(['flutter', 'testing']));
        expect(map.containsKey('publishedAt'), isFalse,
            reason: 'data source sets publishedAt via FieldValue.serverTimestamp()');
        expect(map.containsKey('createdAt'), isFalse,
            reason: 'data source sets createdAt via FieldValue.serverTimestamp()');
        expect(map.containsKey('updatedAt'), isFalse,
            reason: 'data source sets updatedAt via FieldValue.serverTimestamp()');
        expect(map['viewCount'], equals(42));
        expect(map['favoriteCount'], equals(7));
        expect(map['isDeleted'], isFalse);
        expect(map['deletedAt'], isNull);
      });

      test('toFirestore serializes isDeleted true with deletedAt as Timestamp', () {
        final deletedTs = Timestamp.fromDate(DateTime(2026, 3, 10, 8, 0, 0));
        final data = baseData();
        data['isDeleted'] = true;
        data['deletedAt'] = deletedTs;
        when(() => snapshot.data()).thenReturn(data);

        final model = JournalistArticleModel.fromRawData(snapshot);
        final map = model.toFirestore();
        expect(map['isDeleted'], isTrue);
        expect(map['deletedAt'], isA<Timestamp>());
        expect((map['deletedAt'] as Timestamp).toDate(), equals(deletedTs.toDate()));
      });

      test('toFirestore includes location map when location is present', () {
        final model = JournalistArticleModel.fromRawData(snapshot);
        final map = model.toFirestore();

        expect(map['location'], isA<Map<String, dynamic>>());
        final loc = map['location'] as Map<String, dynamic>;
        expect(loc['latitude'], equals(19.432608));
        expect(loc['longitude'], equals(-99.133209));
        expect(loc['placeName'], equals('Mexico City'));
      });

      test('toFirestore has null location when location is null', () {
        final data = baseData();
        data['location'] = null;
        when(() => snapshot.data()).thenReturn(data);

        final model = JournalistArticleModel.fromRawData(snapshot);
        final map = model.toFirestore();
        expect(map['location'], isNull);
      });

      test('toFirestore does not include the id field', () {
        final model = JournalistArticleModel.fromRawData(snapshot);
        final map = model.toFirestore();
        expect(map.containsKey('id'), isFalse);
      });

      test('sentinel urlToImage preserved through toFirestore', () {
        final data = baseData();
        data['status'] = 'publishing';
        data['urlToImage'] = 'pending://thumbnail';
        when(() => snapshot.data()).thenReturn(data);

        final model = JournalistArticleModel.fromRawData(snapshot);
        final map = model.toFirestore();
        expect(map['urlToImage'], equals('pending://thumbnail'));
        expect(map['status'], equals('publishing'));
      });
    });

    group('toEntity', () {
      test('returns a JournalistArticleEntity instance', () {
        final model = JournalistArticleModel.fromRawData(snapshot);
        final entity = model.toEntity();

        expect(entity, isA<JournalistArticleEntity>());
        expect(entity.id, equals(model.id));
        expect(entity.title, equals(model.title));
        expect(entity.category, equals(model.category));
      });

      test('toEntity preserves location', () {
        final model = JournalistArticleModel.fromRawData(snapshot);
        final entity = model.toEntity();

        expect(entity.location, isNotNull);
        expect(entity.location!.latitude, equals(19.432608));
      });

      test('toEntity returns null location when absent', () {
        final data = baseData();
        data['location'] = null;
        when(() => snapshot.data()).thenReturn(data);

        final model = JournalistArticleModel.fromRawData(snapshot);
        expect(model.toEntity().location, isNull);
      });
    });
  });
}
