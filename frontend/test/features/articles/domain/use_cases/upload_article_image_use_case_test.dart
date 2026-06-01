import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/articles/domain/params/upload_article_image_params.dart';
import 'package:tortutip/features/articles/domain/repository/article_repository.dart';
import 'package:tortutip/features/articles/domain/use_cases/upload_article_image_use_case.dart';

class MockArticleRepository extends Mock implements ArticleRepository {}

void main() {
  late UploadArticleImageUseCase useCase;
  late MockArticleRepository mockRepository;

  setUp(() {
    mockRepository = MockArticleRepository();
    useCase = UploadArticleImageUseCase(mockRepository);
    registerFallbackValue(
      UploadArticleImageParams(
        userId: 'user_1',
        imageFile: File('test.jpg'),
        isVertical: true,
      ),
    );
  });

  group('UploadArticleImageUseCase', () {
    final params = UploadArticleImageParams(
      userId: 'user_1',
      imageFile: File('test.jpg'),
      isVertical: true,
    );

    test('should_return_url_when_repository_succeeds', () async {
      // Arrange
      const expectedUrl = 'https://storage/image.jpg';
      when(() => mockRepository.uploadArticleImage(any()))
          .thenAnswer((_) async => const DataSuccess(expectedUrl));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, isA<DataSuccess<String>>());
      expect(result.data, equals(expectedUrl));
      verify(() => mockRepository.uploadArticleImage(any())).called(1);
    });

    test('should_return_failure_when_repository_throws', () async {
      // Arrange
      final exception = Exception('Storage upload failed');
      when(() => mockRepository.uploadArticleImage(any()))
          .thenAnswer((_) async => DataFailed(exception));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, isA<DataFailed<String>>());
      expect(result.error, equals(exception));
    });
  });
}
