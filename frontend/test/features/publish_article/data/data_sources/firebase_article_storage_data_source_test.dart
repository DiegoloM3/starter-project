import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/publish_article/data/data_sources/firebase_article_storage_data_source.dart';
import 'package:news_app_clean_architecture/features/publish_article/data/data_sources/publication_data_source_exception.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/entities/article_thumbnail.dart';

class RecordingStorageClient implements ArticleStorageClient {
  final calls = <String>[];
  Uint8List? bytes;
  SettableMetadata? metadata;
  FirebaseException? uploadError;
  FirebaseException? downloadError;
  Completer<void>? upload;
  final url =
      'https://firebasestorage.googleapis.com/v0/b/bucket/o/image?alt=media&token=real';

  @override
  Future<void> putData(
      String path, Uint8List bytes, SettableMetadata metadata) async {
    calls.add('put:$path');
    this.bytes = bytes;
    this.metadata = metadata;
    if (uploadError != null) throw uploadError!;
    if (upload != null) await upload!.future;
  }

  @override
  Future<String> getDownloadUrl(String path) async {
    calls.add('url:$path');
    if (downloadError != null) throw downloadError!;
    return url;
  }
}

void main() {
  late RecordingStorageClient client;
  late FirebaseArticleStorageDataSource source;
  const path = 'media/articles/chosen-id/chosen-name.webp';
  ArticleThumbnail thumbnail(String mime) => ArticleThumbnail(
      fileName: 'different-name.jpg', mimeType: mime, bytes: [1, 2, 255]);
  Future<String> upload() => source.uploadThumbnail(
      storagePath: path, thumbnail: thumbnail('image/webp'));

  TypeMatcher<PublicationDataSourceException> failure(String code,
          PublicationDataSourceOperation operation, Object cause) =>
      isA<PublicationDataSourceException>()
          .having((e) => e.source, 'source', PublicationDataSource.storage)
          .having((e) => e.operation, 'operation', operation)
          .having((e) => e.code, 'code', code)
          .having((e) => e.cause, 'cause', same(cause));

  setUp(() {
    client = RecordingStorageClient();
    source = FirebaseArticleStorageDataSource.withClient(client);
  });

  for (final mime in ['image/jpeg', 'image/png', 'image/webp']) {
    test(
        'uploads exact bytes to supplied path with explicit $mime and returns SDK URL',
        () async {
      final result = await source.uploadThumbnail(
          storagePath: path, thumbnail: thumbnail(mime));
      expect(client.calls, ['put:$path', 'url:$path']);
      expect(client.bytes, [1, 2, 255]);
      expect(client.metadata!.contentType, mime);
      expect(result, client.url);
    });
  }
  test('waits for upload completion before requesting URL', () async {
    client.upload = Completer<void>();
    final pending = upload();
    await Future<void>.delayed(Duration.zero);
    expect(client.calls, ['put:$path']);
    client.upload!.complete();
    expect(await pending, client.url);
    expect(client.calls, ['put:$path', 'url:$path']);
  });
  test('find returns existing SDK URL without uploading', () async {
    expect(await source.findThumbnailDownloadUrl(path), client.url);
    expect(client.calls, ['url:$path']);
  });
  test('find returns null only for object-not-found', () async {
    client.downloadError =
        FirebaseException(plugin: 'firebase_storage', code: 'object-not-found');
    expect(await source.findThumbnailDownloadUrl(path), isNull);
    expect(client.calls, ['url:$path']);
  });
  test('missing URL after upload is an exception, not a successful upload',
      () async {
    client.downloadError =
        FirebaseException(plugin: 'firebase_storage', code: 'object-not-found');
    await expectLater(
        upload(),
        throwsA(failure(
            'object-not-found',
            PublicationDataSourceOperation.getThumbnailDownloadUrl,
            client.downloadError!)));
  });
  for (final code in [
    'unauthorized',
    'unauthenticated',
    'retry-limit-exceeded',
    'canceled',
    'quota-exceeded',
    'bucket-not-found',
    'unknown'
  ]) {
    test('translates upload error $code without requesting URL', () async {
      client.uploadError = FirebaseException(
          plugin: 'firebase_storage', code: code, message: 'SDK message');
      await expectLater(
          upload(),
          throwsA(failure(code, PublicationDataSourceOperation.uploadThumbnail,
                  client.uploadError!)
              .having((e) => e.message, 'message', 'SDK message')));
      expect(client.calls, ['put:$path']);
    });
    test('translates lookup error $code instead of returning null', () async {
      client.downloadError =
          FirebaseException(plugin: 'firebase_storage', code: code);
      await expectLater(
          source.findThumbnailDownloadUrl(path),
          throwsA(failure(
                  code,
                  PublicationDataSourceOperation.getThumbnailDownloadUrl,
                  client.downloadError!)
              .having(
                  (e) => e.message, 'message', 'Storage operation failed.')));
    });
    test('translates URL error $code after successful upload', () async {
      client.downloadError =
          FirebaseException(plugin: 'firebase_storage', code: code);
      await expectLater(
          upload(),
          throwsA(failure(
              code,
              PublicationDataSourceOperation.getThumbnailDownloadUrl,
              client.downloadError!)));
      expect(client.calls, ['put:$path', 'url:$path']);
    });
  }
}
