import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/error/app_failure.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/upload_thumbnail_params.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/repository/user_article_repository.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/upload_thumbnail.dart';

class _MockRepository extends Mock implements UserArticleRepository {}

UploadThumbnailParams _params({
  String authorId = 'u1',
  String articleId = 'a1',
  String fileName = 'thumb.jpg',
  List<int> bytes = const [1, 2, 3, 4],
  String contentType = 'image/jpeg',
}) {
  return UploadThumbnailParams(
    authorId: authorId,
    articleId: articleId,
    fileName: fileName,
    bytes: bytes,
    contentType: contentType,
  );
}

void main() {
  late _MockRepository repository;
  late UploadThumbnailUseCase useCase;

  setUpAll(() {
    registerFallbackValue(_params());
  });

  setUp(() {
    repository = _MockRepository();
    useCase = UploadThumbnailUseCase(repository);
  });

  test('rejects non-image content types', () async {
    final result = await useCase(_params(contentType: 'application/pdf'));
    expect(result.isLeft(), isTrue);
    verifyNever(() => repository.uploadThumbnail(any()));
  });

  test('rejects payloads larger than 5 MiB', () async {
    final bytes = List<int>.filled(5 * 1024 * 1024 + 1, 0);
    final result = await useCase(_params(bytes: bytes));
    expect(result.isLeft(), isTrue);
  });

  test('rejects empty bytes', () async {
    final result = await useCase(_params(bytes: const []));
    expect(result.isLeft(), isTrue);
  });

  test('forwards the call and returns the URL on success', () async {
    when(() => repository.uploadThumbnail(any())).thenAnswer(
      (_) async => const Right('https://cdn.test/a1.jpg'),
    );

    final result = await useCase(_params());

    expect(
      result,
      const Right<AppFailure, String>('https://cdn.test/a1.jpg'),
    );
    verify(() => repository.uploadThumbnail(any())).called(1);
  });
}
