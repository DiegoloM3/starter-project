import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/auth/data/repository/profile_photo_repository_impl.dart';
import 'package:news_app_clean_architecture/shared/media/data/data_sources/remote/image_storage_service.dart';

import '../../../../helpers/fixtures.dart';

class MockImageStorageService extends Mock implements ImageStorageService {}

void main() {
  late MockImageStorageService service;
  late ProfilePhotoRepositoryImpl repository;

  setUp(() {
    service = MockImageStorageService();
    repository = ProfilePhotoRepositoryImpl(service);
  });

  test('upload stores the photo under media/avatars/{uid} with the image extension', () async {
    when(() => service.upload(
          filePath: any(named: 'filePath'),
          objectPath: any(named: 'objectPath'),
          contentType: any(named: 'contentType'),
        )).thenAnswer((_) async => 'https://download/avatar');

    final result = await repository.upload(userId: 'uid-1', image: buildImage(mimeType: 'image/png'));

    expect(result.dataOrNull, 'https://download/avatar');
    verify(() => service.upload(
          filePath: '/tmp/photo.jpg',
          objectPath: 'media/avatars/uid-1.png',
          contentType: 'image/png',
        )).called(1);
  });

  test('an invalid image is rejected before any upload', () async {
    final result = await repository.upload(userId: 'uid-1', image: buildImage(mimeType: 'image/gif'));

    expect(result.failureOrNull?.type, FailureType.validation);
    verifyNever(() => service.upload(
          filePath: any(named: 'filePath'),
          objectPath: any(named: 'objectPath'),
          contentType: any(named: 'contentType'),
        ));
  });

  test('a storage error becomes a failure', () async {
    when(() => service.upload(
          filePath: any(named: 'filePath'),
          objectPath: any(named: 'objectPath'),
          contentType: any(named: 'contentType'),
        )).thenThrow(FirebaseException(plugin: 'firebase_storage', code: 'unauthorized'));

    final result = await repository.upload(userId: 'uid-1', image: buildImage());

    expect(result.isFailure, isTrue);
  });
}
