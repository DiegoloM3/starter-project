import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/usecases/create_article.dart';

import '../../_fixtures/article_upload_fixture.dart';
import '../../_fixtures/mock_articles_repository.dart';

void main() {
  late MockArticlesUploadRepository repository;
  late CreateArticleUseCase useCase;

  setUpAll(registerArticleFallbacks);

  setUp(() {
    repository = MockArticlesUploadRepository();
    useCase = CreateArticleUseCase(repository);
  });

  group('CreateArticleUseCase', () {
    test('throws ArgumentError when params is null', () {
      expect(() => useCase(), throwsArgumentError);
      verifyZeroInteractions(repository);
    });

    test('delegates to repository.createArticle and returns its result',
        () async {
      final params = ArticleUploadFixture.sampleParams();
      final created = ArticleUploadFixture.sample();
      when(() => repository.createArticle(params))
          .thenAnswer((_) async => DataSuccess(created));

      final result = await useCase(params: params);

      expect(result, isA<DataSuccess>());
      expect(result.data, created);
      verify(() => repository.createArticle(params)).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('propagates a repository failure as DataFailed', () async {
      final params = ArticleUploadFixture.sampleParams();
      final failure = Exception('network down');
      when(() => repository.createArticle(params))
          .thenAnswer((_) async => DataFailed(failure));

      final result = await useCase(params: params);

      expect(result, isA<DataFailed>());
      expect(result.error, failure);
    });
  });
}
