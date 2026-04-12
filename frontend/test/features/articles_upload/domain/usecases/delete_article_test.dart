import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/usecases/delete_article.dart';

import '../../_fixtures/mock_articles_repository.dart';

void main() {
  late MockArticlesUploadRepository repository;
  late DeleteArticleUseCase useCase;

  setUp(() {
    repository = MockArticlesUploadRepository();
    useCase = DeleteArticleUseCase(repository);
  });

  group('DeleteArticleUseCase', () {
    test('throws ArgumentError when id is null', () {
      expect(() => useCase(), throwsArgumentError);
      verifyZeroInteractions(repository);
    });

    test('throws ArgumentError when id is empty', () {
      expect(() => useCase(params: ''), throwsArgumentError);
      verifyZeroInteractions(repository);
    });

    test('delegates to repository.deleteArticle with the id', () async {
      const id = 'article-123';
      when(() => repository.deleteArticle(id))
          .thenAnswer((_) async => const DataSuccess(null));

      final result = await useCase(params: id);

      expect(result, isA<DataSuccess>());
      verify(() => repository.deleteArticle(id)).called(1);
      verifyNoMoreInteractions(repository);
    });
  });
}
