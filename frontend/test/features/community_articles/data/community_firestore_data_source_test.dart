// These provider types are sealed; mocktail requires test doubles to implement
// their public contracts for exercising the datasource boundary.
// ignore_for_file: subtype_of_sealed_class

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/community_articles/data/data_sources/community_firestore_data_source.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/entities/article_image.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/params/publish_article_params.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

class MockReference extends Mock implements Reference {}

class MockFullMetadata extends Mock implements FullMetadata {}

const _image = ArticleImageEntity(
  bytes: [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A],
  fileName: 'story.png',
  mimeType: 'image/png',
);

const _params = PublishArticleParams(
  clientId: 'article-test-request',
  title: 'A valid title',
  content: 'This body is long enough to publish safely.',
  image: _image,
);

String _payloadHash() => sha256
    .convert([
      ...utf8.encode(_params.title),
      0,
      ...utf8.encode(_params.content),
      0,
      ..._image.bytes,
    ])
    .toString();

void _stubStorage({
  required MockFirebaseStorage storage,
  required MockReference reference,
  required MockFullMetadata metadata,
}) {
  when(() => storage.ref('media/articles/uid/article-test-request/story.png'))
      .thenReturn(reference);
  when(() => reference.getMetadata()).thenAnswer((_) async => metadata);
  when(() => metadata.customMetadata)
      .thenReturn({'payloadHash': _payloadHash()});
  when(() => metadata.contentType).thenReturn('image/png');
  when(() => reference.getDownloadURL())
      .thenAnswer((_) async => 'https://storage.example/story.png');
}

void main() {
  test('limits long descriptions to 240 code units without splitting Unicode',
      () {
    final description = CommunityFirestoreDataSource.descriptionFor(
      '${'🙂' * 200}end',
    );

    expect(description.length, lessThanOrEqualTo(240));
    expect(description.endsWith('…'), isTrue);
    expect(description.runes.last, 0x2026);
    expect(description.contains('\uFFFD'), isFalse);
  });

  test('keeps short descriptions unchanged', () {
    const description = 'A concise article summary.';

    expect(
      CommunityFirestoreDataSource.descriptionFor(description),
      description,
    );
  });

  test('returns the acknowledged article when readback fails and retries safely',
      () async {
    final auth = MockFirebaseAuth();
    final user = MockUser();
    final firestore = MockFirebaseFirestore();
    final collection = MockCollectionReference();
    final document = MockDocumentReference();
    final missing = MockDocumentSnapshot();
    final existing = MockDocumentSnapshot();
    final storage = MockFirebaseStorage();
    final reference = MockReference();
    final metadata = MockFullMetadata();
    final source = CommunityFirestoreDataSource(
      auth: auth,
      firestore: firestore,
      storage: storage,
    );
    final persisted = <String, dynamic>{};
    var reads = 0;

    when(() => auth.currentUser).thenReturn(user);
    when(() => user.uid).thenReturn('uid');
    when(() => user.displayName).thenReturn('Reporter');
    when(() => firestore.collection('articles')).thenReturn(collection);
    when(() => collection.doc(_params.clientId)).thenReturn(document);
    when(() => document.id).thenReturn(_params.clientId);
    when(() => missing.exists).thenReturn(false);
    when(() => document.get()).thenAnswer((_) async {
      if (reads++ == 0) return missing;
      if (reads == 2) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
        );
      }
      return existing;
    });
    when(() => document.set(any())).thenAnswer((invocation) async {
      persisted.addAll(
        Map<String, dynamic>.from(
          invocation.positionalArguments.first as Map<String, dynamic>,
        ),
      );
    });
    when(() => existing.exists).thenReturn(true);
    when(() => existing.id).thenReturn(_params.clientId);
    when(() => existing.data()).thenAnswer((_) {
      final serverTime = Timestamp.fromDate(DateTime.utc(2026, 1, 1));
      return {
        ...persisted,
        'publishedAt': serverTime,
        'createdAt': serverTime,
        'updatedAt': serverTime,
      };
    });
    _stubStorage(
      storage: storage,
      reference: reference,
      metadata: metadata,
    );

    final first = await source.publishArticle(_params);

    expect(first.id, _params.clientId);
    expect(first.title, _params.title);
    expect(first.publishedAt, isNotEmpty);
    expect(first.createdAt, isNotNull);
    final retry = await source.publishArticle(_params);

    expect(retry.id, _params.clientId);
    expect(retry.publishedAt, startsWith('2026-01-01T'));
    verify(() => document.set(any())).called(1);
  });
}
