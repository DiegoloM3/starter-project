import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/news/domain/repository/user_article_repository.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/delete_user_article.dart';

import 'delete_user_article_test.mocks.dart';

@GenerateMocks([UserArticleRepository])
void main() {
  late MockUserArticleRepository mockRepository;
  late DeleteUserArticle usecase;

  setUp(() {
    mockRepository = MockUserArticleRepository();
    usecase = DeleteUserArticle(mockRepository);
  });

  test('should call deleteUserArticle on repository with the article id',
      () async {
    when(mockRepository.deleteUserArticle(any))
        .thenAnswer((_) async => const DataSuccess(null));

    final result = await usecase(
      params: const DeleteUserArticleParams(articleId: '1'),
    );

    expect(result, isA<DataSuccess<void>>());
    verify(mockRepository.deleteUserArticle('1')).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return DataFailed when repository fails', () async {
    when(mockRepository.deleteUserArticle(any)).thenAnswer(
        (_) async => const DataGenericFailed('Failed to delete article'));

    final result = await usecase(
      params: const DeleteUserArticleParams(articleId: '1'),
    );

    expect(result, isA<DataGenericFailed<void>>());
    verify(mockRepository.deleteUserArticle('1')).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return DataGenericFailed when params are null', () async {
    final result = await usecase();

    expect(result, isA<DataGenericFailed<void>>());
    verifyZeroInteractions(mockRepository);
  });

  test('should return DataGenericFailed when the article id is blank',
      () async {
    final result = await usecase(
      params: const DeleteUserArticleParams(articleId: '   '),
    );

    expect(result, isA<DataGenericFailed<void>>());
    verifyZeroInteractions(mockRepository);
  });
}
