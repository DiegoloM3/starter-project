import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/upload_thumbnail.dart';

import '../../../../helpers/mock_classes.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late UploadThumbnailUseCase useCase;
  late MockArticleRepository mockRepository;

  setUp(() {
    mockRepository = MockArticleRepository();
    useCase = UploadThumbnailUseCase(mockRepository);
  });

  test('returns DataSuccess with download URL', () async {
    when(() => mockRepository.uploadThumbnail(
          articleId: any(named: 'articleId'),
          filePath: any(named: 'filePath'),
        )).thenAnswer((_) async => const DataSuccess(tThumbnailUrl));

    final result = await useCase(
      params: const UploadThumbnailParams(
        articleId: tArticleId,
        filePath: tFilePath,
      ),
    );

    expect(result, isA<DataSuccess>());
    expect(result.data, tThumbnailUrl);
    verify(() => mockRepository.uploadThumbnail(
          articleId: tArticleId,
          filePath: tFilePath,
        )).called(1);
  });

  test('returns DataFailed on repository error', () async {
    const error = StorageException(message: 'Upload failed', code: 'err');
    when(() => mockRepository.uploadThumbnail(
          articleId: any(named: 'articleId'),
          filePath: any(named: 'filePath'),
        )).thenAnswer((_) async => const DataFailed(error));

    final result = await useCase(
      params: const UploadThumbnailParams(
        articleId: tArticleId,
        filePath: tFilePath,
      ),
    );

    expect(result, isA<DataFailed>());
  });

  test('throws ArgumentError when params is null', () {
    expect(
      () => useCase(params: null),
      throwsA(isA<ArgumentError>()),
    );
  });
}
