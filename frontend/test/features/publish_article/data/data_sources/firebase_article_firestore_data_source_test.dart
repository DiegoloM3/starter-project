import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/publish_article/data/data_sources/firebase_article_firestore_data_source.dart';
import 'package:news_app_clean_architecture/features/publish_article/data/data_sources/publication_data_source_exception.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/entities/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/params/publish_article_params.dart';

class RecordingFirestoreClient implements ArticleFirestoreClient {
  final calls = <String>[];
  Map<String, dynamic>? written;
  Map<String, dynamic>? document;
  GetOptions? options;
  FirebaseException? error;

  void record(String call) {
    calls.add(call);
    if (error != null) throw error!;
  }

  @override
  String createId(String collection) {
    record('id:$collection');
    return 'generated-id';
  }

  @override
  Future<void> setDocument(
      String collection, String id, Map<String, dynamic> data) async {
    record('set:$collection/$id');
    written = data;
  }

  @override
  Future<Map<String, dynamic>?> getDocument(
      String collection, String id, GetOptions options) async {
    record('get:$collection/$id');
    this.options = options;
    return document;
  }
}

void main() {
  late RecordingFirestoreClient client;
  late FirebaseArticleFirestoreDataSource source;
  final params = PublishArticleParams(
    author: 'Author',
    title: 'Title',
    description: 'Description',
    content: 'Content',
    thumbnail: ArticleThumbnail(
        fileName: 'image.png', mimeType: 'image/png', bytes: [1, 2, 3]),
  );
  const url = 'https://firebasestorage.googleapis.com/real-download-url';
  final dates = {
    'publishedAt': DateTime.utc(2026, 9, 18, 1),
    'createdAt': DateTime.utc(2026, 9, 18, 2),
    'updatedAt': DateTime.utc(2026, 9, 18, 3),
  };

  Map<String, dynamic> validDocument() => {
        'author': params.author,
        'title': params.title,
        'description': params.description,
        'content': params.content,
        'thumbnailURL': url,
        for (final entry in dates.entries)
          entry.key: Timestamp.fromDate(entry.value),
      };

  Future<void> create() => source.createArticle(
      articleId: 'chosen-id', params: params, thumbnailUrl: url);

  TypeMatcher<PublicationDataSourceException> failure(
          String code, PublicationDataSourceOperation operation,
          {Object? cause}) =>
      isA<PublicationDataSourceException>()
          .having((e) => e.source, 'source', PublicationDataSource.firestore)
          .having((e) => e.operation, 'operation', operation)
          .having((e) => e.code, 'code', code)
          .having(
              (e) => e.cause, 'cause', cause == null ? anything : same(cause));

  setUp(() {
    client = RecordingFirestoreClient();
    source = FirebaseArticleFirestoreDataSource.withClient(client);
  });

  test('generates an articles ID without reading or writing a document', () {
    expect(source.createArticleId(), 'generated-id');
    expect(client.calls, ['id:articles']);
    expect(client.written, isNull);
  });

  test('creates at the supplied ID with exactly eight fields and server dates',
      () async {
    await create();
    expect(client.calls, ['set:articles/chosen-id']);
    expect(client.written, {
      'author': params.author,
      'title': params.title,
      'description': params.description,
      'content': params.content,
      'thumbnailURL': url,
      'publishedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  });

  test(
      'reads supplied ID from server and converts all dates without mutating raw data',
      () async {
    client.document = validDocument();
    final model = await source.getArticleById('chosen-id');
    expect(client.calls, ['get:articles/chosen-id']);
    expect(client.options!.source, Source.server);
    expect(model.id, 'chosen-id');
    expect(model.author, params.author);
    expect(model.title, params.title);
    expect(model.description, params.description);
    expect(model.content, params.content);
    expect(model.thumbnailUrl, url);
    expect(model.publishedAt.isAtSameMomentAs(dates['publishedAt']!), isTrue);
    expect(model.createdAt.isAtSameMomentAs(dates['createdAt']!), isTrue);
    expect(model.updatedAt.isAtSameMomentAs(dates['updatedAt']!), isTrue);
    for (final field in dates.keys) {
      expect(client.document![field], isA<Timestamp>());
    }
  });

  test('rejects a nonexistent document', () async {
    await expectLater(
        source.getArticleById('missing'),
        throwsA(
            failure('not-found', PublicationDataSourceOperation.getArticle)));
  });

  for (final field in dates.keys) {
    for (final value in [null, 42, '2026-09-18', DateTime.utc(2026)]) {
      test('rejects invalid SDK timestamp $field: $value', () async {
        client.document = validDocument()..[field] = value;
        await expectLater(
            source.getArticleById('id'),
            throwsA(failure(
                'invalid-data', PublicationDataSourceOperation.getArticle)));
      });
    }
  }
  for (final field in validDocument().keys) {
    test('rejects missing field $field', () async {
      client.document = validDocument()..remove(field);
      await expectLater(
          source.getArticleById('id'),
          throwsA(failure(
              'invalid-data', PublicationDataSourceOperation.getArticle)));
    });
  }
  for (final field in [
    'author',
    'title',
    'description',
    'content',
    'thumbnailURL'
  ]) {
    test('translates model rejection of invalid $field', () async {
      client.document = validDocument()..[field] = 42;
      await expectLater(
          source.getArticleById('id'),
          throwsA(
              failure('invalid-data', PublicationDataSourceOperation.getArticle)
                  .having((e) => e.cause, 'cause', isA<FormatException>())));
    });
  }
  test('rejects extra document fields', () async {
    client.document = validDocument()..['id'] = 'unexpected';
    await expectLater(
        source.getArticleById('id'),
        throwsA(failure(
            'invalid-data', PublicationDataSourceOperation.getArticle)));
  });

  for (final code in [
    'permission-denied',
    'unavailable',
    'deadline-exceeded'
  ]) {
    test('translates create SDK error $code', () async {
      client.error = FirebaseException(
          plugin: 'cloud_firestore', code: code, message: 'SDK message');
      await expectLater(
          create(),
          throwsA(failure(code, PublicationDataSourceOperation.createArticle,
                  cause: client.error)
              .having((e) => e.message, 'message', 'SDK message')));
    });
    test('translates read SDK error $code', () async {
      client.error = FirebaseException(plugin: 'cloud_firestore', code: code);
      await expectLater(
          source.getArticleById('id'),
          throwsA(failure(code, PublicationDataSourceOperation.getArticle,
                  cause: client.error)
              .having(
                  (e) => e.message, 'message', 'Firestore operation failed.')));
    });
  }
  test('translates SDK error allocating a reference as a creation operation',
      () {
    client.error =
        FirebaseException(plugin: 'cloud_firestore', code: 'unknown');
    expect(
        source.createArticleId,
        throwsA(failure('unknown', PublicationDataSourceOperation.createArticle,
            cause: client.error)));
  });
}
