import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/data_sources/remote/article_thumbnail_storage_data_source.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';

class MockStorage extends Mock implements FirebaseStorage {}

class MockReference extends Mock implements Reference {}

/// An upload the server accepted but never answers, like a frozen or overloaded backend.
class UnansweredUploadTask extends Fake implements UploadTask {
  final Completer<TaskSnapshot> _never = Completer();
  bool isCancelled = false;

  @override
  Future<bool> cancel() async => isCancelled = true;

  @override
  Future<R> then<R>(FutureOr<R> Function(TaskSnapshot) onValue, {Function? onError}) {
    return _never.future.then(onValue, onError: onError);
  }

  @override
  Future<TaskSnapshot> timeout(Duration timeLimit, {FutureOr<TaskSnapshot> Function()? onTimeout}) {
    return _never.future.timeout(timeLimit, onTimeout: onTimeout);
  }
}

void main() {
  late MockFirebaseStorage storage;
  late ArticleThumbnailStorageDataSource dataSource;
  late Directory gallery;

  setUp(() async {
    storage = MockFirebaseStorage();
    dataSource = ArticleThumbnailStorageDataSource(storage);
    gallery = await Directory.systemTemp.createTemp('gallery');
  });

  tearDown(() => gallery.delete(recursive: true));

  Future<ArticleThumbnailEntity> galleryImage(String fileName) async {
    final file = await File('${gallery.path}/$fileName').writeAsBytes(List.filled(64, 0));
    return ArticleThumbnailEntity(localPath: file.path, sizeInBytes: 64);
  }

  test('uploads to media/articles/{articleId}.{extension}, with jpeg stored as jpg', () async {
    await dataSource.uploadThumbnail('article1', await galleryImage('IMG_0001.jpeg'));

    expect(storage.storedFilesMap.keys, ['media/articles/article1.jpg']);
  });

  test('declares the content type that storage.rules expects for the extension', () async {
    final thumbnail = await galleryImage('photo.png');

    await dataSource.uploadThumbnail('article1', thumbnail);

    final metadata = await storage.ref('media/articles/article1.png').getMetadata();
    expect(metadata.contentType, 'image/png');
  });

  test('deletes the thumbnail of an article', () async {
    final thumbnail = await galleryImage('photo.webp');
    await dataSource.uploadThumbnail('article1', thumbnail);

    await dataSource.deleteThumbnail('article1', thumbnail);

    expect(storage.storedFilesMap, isEmpty);
  });

  test('returns the download URL of the uploaded thumbnail', () async {
    final thumbnail = await galleryImage('photo.jpg');
    await dataSource.uploadThumbnail('article1', thumbnail);

    expect(await dataSource.getThumbnailUrl('article1', thumbnail), contains('article1.jpg'));
  });

  group('when the server never answers', () {
    const shortLimit = Duration(milliseconds: 50);
    late MockReference reference;
    late ArticleThumbnailStorageDataSource impatientDataSource;

    setUpAll(() {
      registerFallbackValue(File('fallback'));
      registerFallbackValue(SettableMetadata());
    });

    setUp(() {
      final storage = MockStorage();
      reference = MockReference();
      when(() => storage.ref(any())).thenReturn(reference);
      impatientDataSource = ArticleThumbnailStorageDataSource(
        storage,
        uploadTimeLimit: shortLimit,
        requestTimeLimit: shortLimit,
      );
    });

    // setMaxUploadRetryTime only limits retries after errors: an unanswered request waits forever.
    test('gives up the upload after its time limit and cancels it', () async {
      final upload = UnansweredUploadTask();
      when(() => reference.putFile(any(), any())).thenAnswer((_) => upload);

      await expectLater(
        impatientDataSource.uploadThumbnail('article1', await galleryImage('photo.jpg')),
        throwsA(isA<TimeoutException>()),
      );
      expect(upload.isCancelled, isTrue);
    });

    test('gives up asking for the download URL', () async {
      when(() => reference.getDownloadURL()).thenAnswer((_) => Completer<String>().future);

      await expectLater(
        impatientDataSource.getThumbnailUrl('article1', await galleryImage('photo.jpg')),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('gives up deleting an orphaned thumbnail', () async {
      when(() => reference.delete()).thenAnswer((_) => Completer<void>().future);

      await expectLater(
        impatientDataSource.deleteThumbnail('article1', await galleryImage('photo.jpg')),
        throwsA(isA<TimeoutException>()),
      );
    });
  });
}
