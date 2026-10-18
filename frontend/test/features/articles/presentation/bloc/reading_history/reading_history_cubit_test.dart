import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/get_reading_history.dart';
import 'package:news_app_clean_architecture/features/articles/presentation/bloc/reading_history/reading_history_cubit.dart';

import '../article_presentation_test_data.dart';

class MockGetReadingHistoryUseCase extends Mock implements GetReadingHistoryUseCase {}

void main() {
  late MockGetReadingHistoryUseCase getReadingHistory;

  setUpAll(() => registerFallbackValue(const NoParams()));

  setUp(() => getReadingHistory = MockGetReadingHistoryUseCase());

  test('starts without articles', () {
    expect(ReadingHistoryCubit(getReadingHistory).state, isEmpty);
  });

  blocTest<ReadingHistoryCubit, List<ArticleEntity>>(
    'loads the recently viewed articles',
    setUp: () => when(() => getReadingHistory(any())).thenAnswer((_) async => DataSuccess([buildArticle()])),
    build: () => ReadingHistoryCubit(getReadingHistory),
    act: (cubit) => cubit.load(),
    expect:
        () => [
          [buildArticle()],
        ],
  );

  blocTest<ReadingHistoryCubit, List<ArticleEntity>>(
    'keeps the current articles when they cannot be loaded',
    setUp: () => when(() => getReadingHistory(any())).thenAnswer((_) async => DataFailed(Exception('offline'))),
    build: () => ReadingHistoryCubit(getReadingHistory),
    act: (cubit) => cubit.load(),
    expect: () => <List<ArticleEntity>>[],
  );
}
