import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/article_narrator_repository.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/stop_reading_aloud.dart';

class MockArticleNarratorRepository extends Mock implements ArticleNarratorRepository {}

void main() {
  test('stops the voice through the repository', () async {
    final repository = MockArticleNarratorRepository();
    when(() => repository.stopReading()).thenAnswer((_) async => const DataSuccess(null));

    expect(await StopReadingAloudUseCase(repository)(), isA<DataSuccess<void>>());
    verify(() => repository.stopReading()).called(1);
  });
}
