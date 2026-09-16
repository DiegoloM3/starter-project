import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/speech_status.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/control_reading.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/read_aloud.dart';

import '../../../../helpers/in_memory_speech_repository.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  late InMemorySpeechRepository speech;

  setUp(() => speech = InMemorySpeechRepository());
  tearDown(() => speech.dispose());

  test('pause, resume and stop drive the status stream', () async {
    final statuses = <SpeechStatus>[];
    final sub = speech.watchStatus().listen(statuses.add);
    await flush();

    await ReadAloudUseCase(speech)(const ReadAloudParams(text: 'x'));
    await PauseReadingUseCase(speech)(const NoParams());
    await ResumeReadingUseCase(speech)(const NoParams());
    await StopReadingUseCase(speech)(const NoParams());
    await flush();
    await sub.cancel();

    expect(statuses, [
      SpeechStatus.idle,
      SpeechStatus.speaking,
      SpeechStatus.paused,
      SpeechStatus.speaking,
      SpeechStatus.idle,
    ]);
    expect(await WatchReadingStatusUseCase(speech)(const NoParams()).first, SpeechStatus.idle);
  });
}
