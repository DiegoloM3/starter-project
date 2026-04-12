import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/entities/article_upload.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/usecases/get_all_articles.dart';

import '../../_fixtures/article_upload_fixture.dart';
import '../../_fixtures/mock_articles_repository.dart';

void main() {
  late MockArticlesUploadRepository repository;
  late GetAllArticlesUseCase useCase;

  setUp(() {
    repository = MockArticlesUploadRepository();
    useCase = GetAllArticlesUseCase(repository);
  });

  group('GetAllArticlesUseCase', () {
    test('forwards the success list returned by the repository', () async {
      final expected = [ArticleUploadFixture.sample()];
      when(() => repository.getAllArticles())
          .thenAnswer((_) async => DataSuccess(expected));

      final result = await useCase();

      expect(result, isA<DataSuccess<List<ArticleUploadEntity>>>());
      expect(result.data, expected);
      verify(() => repository.getAllArticles()).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('propagates a DataFailed without wrapping it', () async {
      final failure = Exception('boom');
      when(() => repository.getAllArticles())
          .thenAnswer((_) async => DataFailed(failure));

      final result = await useCase();

      expect(result, isA<DataFailed<List<ArticleUploadEntity>>>());
      expect(result.error, failure);
    });
  });
}
