import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/delete_comment.dart';

import 'comment_test_data.dart';

void main() {
  test('deletes the comment through the repository', () async {
    final repository = MockCommentRepository();
    when(() => repository.deleteComment(testComment)).thenAnswer((_) async => const DataSuccess(null));

    final result = await DeleteCommentUseCase(repository).call(testComment);

    expect(result, isA<DataSuccess>());
    verify(() => repository.deleteComment(testComment)).called(1);
  });
}
