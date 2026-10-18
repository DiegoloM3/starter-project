import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/comments/domain/exceptions/comment_exceptions.dart';
import 'package:news_app_clean_architecture/features/comments/domain/params/add_comment_params.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/add_comment.dart';

import 'comment_test_data.dart';

void main() {
  late MockCommentRepository repository;

  setUpAll(() => registerFallbackValue(AddCommentParams(articleId: '', text: '')));

  setUp(() => repository = MockCommentRepository());

  test('adds a valid comment through the repository', () async {
    final params = AddCommentParams(articleId: 'article-1', text: 'Great article');
    when(() => repository.addComment(params)).thenAnswer((_) async => DataSuccess(testComment));

    final result = await AddCommentUseCase(repository).call(params);

    expect(result.data, testComment);
  });

  test('fails with the validation errors without calling the repository', () async {
    final result = await AddCommentUseCase(repository).call(AddCommentParams(articleId: 'article-1', text: ' '));

    final error = result.error as CommentValidationException;
    expect(error.errors, {CommentValidationError.textEmpty});
    verifyNever(() => repository.addComment(any()));
  });
}
