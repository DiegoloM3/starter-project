import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/articles/domain/repository/reading_history_repository.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/get_reading_history.dart';

import 'article_test_data.dart';

class MockReadingHistoryRepository extends Mock implements ReadingHistoryRepository {}

void main() {
  test('gets the most recently viewed articles', () async {
    final repository = MockReadingHistoryRepository();
    when(
      () => repository.getRecentlyViewed(ReadingHistoryLimits.maxEntries),
    ).thenAnswer((_) async => DataSuccess([testArticle]));

    final result = await GetReadingHistoryUseCase(repository).call(const NoParams());

    expect(result.data, [testArticle]);
  });
}
