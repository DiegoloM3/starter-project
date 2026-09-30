import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/data_sources/local/text_to_speech_data_source.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_narration.dart';

class MockFlutterTts extends Mock implements FlutterTts {}

ArticleNarrationEntity narrationOf(List<String> sentences, {String languageTag = 'en-US'}) {
  return ArticleNarrationEntity(
    parts: [NarrationPart(NarrationPartKind.paragraph, sentences)],
    languageTag: languageTag,
  );
}

void main() {
  late MockFlutterTts tts;
  late TextToSpeechDataSource dataSource;

  setUp(() {
    tts = MockFlutterTts();
    dataSource = TextToSpeechDataSource(tts);
    when(() => tts.awaitSpeakCompletion(any())).thenAnswer((_) async => 1);
    when(() => tts.setSpeechRate(any())).thenAnswer((_) async => 1);
    when(() => tts.isLanguageAvailable(any())).thenAnswer((_) async => true);
    when(() => tts.setLanguage(any())).thenAnswer((_) async => 1);
    when(() => tts.speak(any())).thenAnswer((_) async => 1);
    when(() => tts.stop()).thenAnswer((_) async => 1);
  });

  List<String> spokenTexts() => verify(() => tts.speak(captureAny())).captured.cast<String>();

  test('reads the sentences one by one in the article language, waiting for each to finish', () async {
    await dataSource.speak(narrationOf(['Title', 'Written by Me', 'Body.'], languageTag: 'es-ES')).drain<void>();

    verify(() => tts.awaitSpeakCompletion(true)).called(1);
    verify(() => tts.setLanguage('es-ES')).called(1);
    expect(spokenTexts(), ['Title', 'Written by Me', 'Body.']);
  });

  test('emits the index of each sentence right before reading it', () async {
    final events = <String>[];
    when(() => tts.speak(any())).thenAnswer((invocation) async {
      events.add('speak ${invocation.positionalArguments.single}');
      return 1;
    });

    await for (final index in dataSource.speak(narrationOf(['One.', 'Two.']))) {
      events.add('sentence $index');
    }

    expect(events, ['sentence 0', 'speak One.', 'sentence 1', 'speak Two.']);
  });

  test('keeps the default voice when the article language is not installed', () async {
    when(() => tts.isLanguageAvailable(any())).thenAnswer((_) async => false);

    await dataSource.speak(narrationOf(['Body.'])).drain<void>();

    verifyNever(() => tts.setLanguage(any()));
  });

  test('reads a sentence too long for Android in parts, without losing text', () async {
    final sentence = 'a' * (TextToSpeechDataSource.maxSpeechLength * 2 + 10);

    final indexes = await dataSource.speak(narrationOf([sentence])).toList();

    expect(indexes, [0]);
    expect(spokenTexts().map((part) => part.length), [
      TextToSpeechDataSource.maxSpeechLength,
      TextToSpeechDataSource.maxSpeechLength,
      10,
    ]);
  });

  test('stops before the next sentence when asked to stop', () async {
    when(() => tts.speak(any())).thenAnswer((_) async {
      await dataSource.stop();
      return 1;
    });

    final indexes = await dataSource.speak(narrationOf(['One.', 'Two.', 'Three.'])).toList();

    expect(indexes, [0]);
    expect(spokenTexts(), ['One.']);
    verify(() => tts.stop()).called(1);
  });

  test('can read again after being stopped', () async {
    await dataSource.stop();

    expect(await dataSource.speak(narrationOf(['One.'])).toList(), [0]);
  });

  test('fails when the device cannot speak', () async {
    when(() => tts.speak(any())).thenAnswer((_) async => 0);

    expect(dataSource.speak(narrationOf(['Body.'])).drain<void>(), throwsException);
  });
}
