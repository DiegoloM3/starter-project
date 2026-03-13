import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/upload_image.dart';

import '../../../../mocks/mocks.dart';

void main() {
  late UploadImageUseCase useCase;
  late MockUserArticleRepository mockRepository;

  setUp(() {
    mockRepository = MockUserArticleRepository();
    useCase = UploadImageUseCase(mockRepository);
  });

  group('UploadImageUseCase', () {
    const testImageUrl = 'https://example.com/uploaded-image.jpg';

    // Note: In real tests, you'd use a mock file or test file
    // For unit tests, we're mainly testing the use case logic

    test('should return DataSuccess with image URL when upload succeeds',
        () async {
      // Arrange
      final mockFile = File('test_image.jpg');
      when(mockRepository.uploadImage(mockFile))
          .thenAnswer((_) async => DataSuccess(testImageUrl));

      // Act
      final result = await useCase(params: mockFile);

      // Assert
      expect(result, isA<DataSuccess>());
      expect((result as DataSuccess).data, testImageUrl);
      verify(mockRepository.uploadImage(mockFile)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return DataFailed when upload fails', () async {
      // Arrange
      final mockFile = File('test_image.jpg');
      final exception = Exception('Upload failed');
      when(mockRepository.uploadImage(mockFile))
          .thenAnswer((_) async => DataFailed(exception));

      // Act
      final result = await useCase(params: mockFile);

      // Assert
      expect(result, isA<DataFailed>());
      verify(mockRepository.uploadImage(mockFile)).called(1);
    });

    test('should return DataFailed when file is null', () async {
      // Act
      final result = await useCase(params: null);

      // Assert
      expect(result, isA<DataFailed>());
      verifyNever(mockRepository.uploadImage(any));
    });

    test('should return valid URL format on successful upload', () async {
      // Arrange
      final mockFile = File('test_image.jpg');
      when(mockRepository.uploadImage(mockFile))
          .thenAnswer((_) async => DataSuccess(testImageUrl));

      // Act
      final result = await useCase(params: mockFile);

      // Assert
      final url = (result as DataSuccess).data;
      expect(url, startsWith('https://'));
      expect(url, contains('.'));
    });
  });
}
