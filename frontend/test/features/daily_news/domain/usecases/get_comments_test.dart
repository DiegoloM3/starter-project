import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_comments.dart';

import '../../../../helpers/mock_classes.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late GetCommentsUseCase useCase;
  late MockCommentRepository mockRepository;

  setUp(() {
    mockRepository = MockCommentRepository();
    useCase = GetCommentsUseCase(mockRepository);
  });

  test('returns stream with comments for given articleId', () {
    final comments = testCommentList();
    when(() => mockRepository.getComments(any()))
        .thenAnswer((_) => Stream.value(DataSuccess(comments)));

    final stream = useCase(params: tArticleId);

    expect(stream, emits(isA<DataSuccess>()));
    verify(() => mockRepository.getComments(tArticleId)).called(1);
  });

  test('throws ArgumentError when params is null', () {
    expect(
      () => useCase(params: null),
      throwsA(isA<ArgumentError>()),
    );
  });
}
