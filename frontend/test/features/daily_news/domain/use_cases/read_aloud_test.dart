import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/read_aloud.dart';

import '../../../../helpers/in_memory_speech_repository.dart';

void main() {
  late InMemorySpeechRepository speech;

  setUp(() => speech = InMemorySpeechRepository());
  tearDown(() => speech.dispose());

  test('trims the text and passes the rate', () async {
    final result = await ReadAloudUseCase(speech)(const ReadAloudParams(text: '  Hello  ', rate: 1.2));

    expect(result.isSuccess, isTrue);
    expect(speech.spoken, ['Hello']);
    expect(speech.lastRate, 1.2);
  });

  test('refuses blank text without speaking', () async {
    final result = await ReadAloudUseCase(speech)(const ReadAloudParams(text: '   '));

    expect(result.failureOrNull?.type, FailureType.validation);
    expect(speech.spoken, isEmpty);
  });
}
