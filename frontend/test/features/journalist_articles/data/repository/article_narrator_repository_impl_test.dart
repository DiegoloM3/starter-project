import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/data_sources/local/text_to_speech_data_source.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/repository/article_narrator_repository_impl.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_narration.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_narration_progress.dart';

class MockTextToSpeechDataSource extends Mock implements TextToSpeechDataSource {}

const narration = ArticleNarrationEntity(
  parts: [NarrationPart(NarrationPartKind.title, ['Title', 'Subtitle'])],
  languageTag: 'en-US',
);

void main() {
  late MockTextToSpeechDataSource dataSource;
  late ArticleNarratorRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(narration));

  setUp(() {
    dataSource = MockTextToSpeechDataSource();
    repository = ArticleNarratorRepositoryImpl(dataSource);
  });

  test('reports which sentence of the narration is being read', () async {
    when(() => dataSource.speak(any())).thenAnswer((_) => Stream.fromIterable([0, 1]));

    final results = await repository.read(narration).toList();

    expect(results.map((result) => result.data), const [
      ArticleNarrationProgressEntity(narration: narration, sentenceIndex: 0),
      ArticleNarrationProgressEntity(narration: narration, sentenceIndex: 1),
    ]);
    verify(() => dataSource.speak(narration)).called(1);
  });

  test('fails when the device cannot speak', () async {
    final error = Exception('no text-to-speech engine');
    when(() => dataSource.speak(any())).thenAnswer((_) => Stream.error(error));

    final results = await repository.read(narration).toList();

    expect(results.single, isA<DataFailed<ArticleNarrationProgressEntity>>());
    expect(results.single.error, same(error));
  });

  test('stops reading', () async {
    when(() => dataSource.stop()).thenAnswer((_) async {});

    expect(await repository.stopReading(), isA<DataSuccess<void>>());
    verify(() => dataSource.stop()).called(1);
  });
}
