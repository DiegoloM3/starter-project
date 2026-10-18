import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/get_comments.dart';

import 'comment_test_data.dart';

void main() {
  test('gets the comments of the article from the repository', () async {
    final repository = MockCommentRepository();
    when(() => repository.getComments('article-1')).thenAnswer((_) async => DataSuccess([testComment]));

    final result = await GetCommentsUseCase(repository).call('article-1');

    expect(result.data, [testComment]);
  });
}
