import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/shared/media/data/data_sources/remote/image_storage_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/thumbnail_storage_repository_impl.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

class MockImageStorageService extends Mock implements ImageStorageService {}

void main() {
  late MockImageStorageService service;
  late MockAuthRepository auth;
  late ThumbnailStorageRepositoryImpl repository;

  setUp(() {
    service = MockImageStorageService();
    auth = MockAuthRepository();
    when(() => auth.currentUser).thenReturn(user);
    repository = ThumbnailStorageRepositoryImpl(service, auth, random: Random(1));
  });

  test('upload stores the file under media/articles, named after the owner, with the right extension and type',
      () async {
    when(() => service.upload(
          filePath: any(named: 'filePath'),
          objectPath: any(named: 'objectPath'),
          contentType: any(named: 'contentType'),
        )).thenAnswer((_) async => 'https://download/url?alt=media');

    final result = await repository.upload(buildImage(mimeType: 'image/png'));

    final captured = verify(() => service.upload(
          filePath: '/tmp/photo.jpg',
          objectPath: captureAny(named: 'objectPath'),
          contentType: 'image/png',
        )).captured.single as String;
    expect(captured, matches(RegExp('^media/articles/${user.id}-\\d+-[0-9a-f]{6}\\.png\$')));
    expect(result.dataOrNull?.path, captured);
    expect(result.dataOrNull?.url, 'https://download/url?alt=media');
  });

  test('without a session nothing is uploaded', () async {
    when(() => auth.currentUser).thenReturn(null);

    final result = await repository.upload(buildImage());

    expect(result.failureOrNull?.type, FailureType.unauthenticated);
    verifyNever(() => service.upload(
          filePath: any(named: 'filePath'),
          objectPath: any(named: 'objectPath'),
          contentType: any(named: 'contentType'),
        ));
  });

  test('an invalid image is rejected before any upload', () async {
    final result = await repository.upload(buildImage(mimeType: 'image/gif'));

    expect(result.failureOrNull?.type, FailureType.validation);
    verifyNever(() => service.upload(
          filePath: any(named: 'filePath'),
          objectPath: any(named: 'objectPath'),
          contentType: any(named: 'contentType'),
        ));
  });

  test('delete succeeds, and a file already gone counts as success', () async {
    when(() => service.delete('media/articles/a.jpg')).thenAnswer((_) async {});
    expect((await repository.delete('media/articles/a.jpg')).isSuccess, isTrue);

    when(() => service.delete('media/articles/b.jpg'))
        .thenThrow(FirebaseException(plugin: 'firebase_storage', code: 'object-not-found'));
    expect((await repository.delete('media/articles/b.jpg')).isSuccess, isTrue);

    when(() => service.delete('media/articles/c.jpg'))
        .thenThrow(FirebaseException(plugin: 'firebase_storage', code: 'unauthorized'));
    expect((await repository.delete('media/articles/c.jpg')).failureOrNull?.type, FailureType.permissionDenied);
  });

}
