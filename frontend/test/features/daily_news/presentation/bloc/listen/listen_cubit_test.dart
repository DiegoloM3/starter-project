import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/speech_status.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/control_reading.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/read_aloud.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/listen/listen_cubit.dart';

import '../../../../../helpers/in_memory_speech_repository.dart';
import '../../../../../helpers/pump_app.dart';

void main() {
  late InMemorySpeechRepository speech;
  late ListenCubit cubit;

  setUp(() {
    speech = InMemorySpeechRepository();
    cubit = ListenCubit(
      ReadAloudUseCase(speech),
      PauseReadingUseCase(speech),
      ResumeReadingUseCase(speech),
      StopReadingUseCase(speech),
      WatchReadingStatusUseCase(speech),
    );
  });
  tearDown(() async {
    await cubit.close();
    await speech.dispose();
  });

  test('toggle starts reading, pauses, resumes; another id replaces the voice', () async {
    await cubit.toggle(id: 'a', text: 'Story A', rate: 1.2);
    await flush();
    expect(cubit.isReading('a'), isTrue);
    expect(cubit.state.isSpeaking, isTrue);
    expect(speech.lastRate, 1.2);

    await cubit.toggle(id: 'a', text: 'Story A');
    await flush();
    expect(cubit.state.status, SpeechStatus.paused);
    expect(cubit.isReading('a'), isTrue);

    await cubit.toggle(id: 'a', text: 'Story A');
    await flush();
    expect(cubit.state.isSpeaking, isTrue);

    await cubit.toggle(id: 'b', text: 'Story B');
    await flush();
    expect(cubit.isReading('a'), isFalse);
    expect(cubit.isReading('b'), isTrue);
    expect(speech.spoken, ['Story A', 'Story B']);
  });

  test('the voice finishing on its own clears the current id; stop is a no-op when idle', () async {
    await cubit.toggle(id: 'a', text: 'Story A');
    await flush();

    speech.finish();
    await flush();
    expect(cubit.state.currentId, isNull);
    expect(cubit.state.status, SpeechStatus.idle);

    await cubit.stop();
    expect(cubit.state.status, SpeechStatus.idle);
  });

  test('blank text is reported and nothing plays', () async {
    await cubit.toggle(id: 'a', text: '   ');
    await flush();

    expect(cubit.state.failure, isNotNull);
    expect(cubit.state.currentId, isNull);
    expect(speech.spoken, isEmpty);
  });
}
