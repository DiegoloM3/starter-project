import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/articles/domain/repository/reading_history_repository.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/record_article_view.dart';

class MockReadingHistoryRepository extends Mock implements ReadingHistoryRepository {}

void main() {
  late MockReadingHistoryRepository repository;

  setUp(() {
    repository = MockReadingHistoryRepository();
    when(() => repository.recordView('article-1')).thenAnswer((_) async => const DataSuccess(null));
    when(() => repository.deleteViewsBeyond(any())).thenAnswer((_) async => const DataSuccess(null));
  });

  test('records the view and keeps only the most recent ones', () async {
    final result = await RecordArticleViewUseCase(repository).call('article-1');

    expect(result, isA<DataSuccess>());
    verifyInOrder([
      () => repository.recordView('article-1'),
      () => repository.deleteViewsBeyond(ReadingHistoryLimits.maxEntries),
    ]);
  });

  test('does not clean the history when the view cannot be recorded', () async {
    when(() => repository.recordView('article-1')).thenAnswer((_) async => DataFailed(Exception('offline')));

    final result = await RecordArticleViewUseCase(repository).call('article-1');

    expect(result, isA<DataFailed>());
    verifyNever(() => repository.deleteViewsBeyond(any()));
  });
}
