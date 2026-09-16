import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/device/device_speech_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/speech_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/speech_status.dart';

import '../../../../helpers/pump_app.dart';

class MockDeviceSpeechService extends Mock implements DeviceSpeechService {}

void main() {
  late MockDeviceSpeechService service;
  late SpeechRepositoryImpl repository;
  late StreamController<SpeechStatus> statuses;

  setUp(() {
    service = MockDeviceSpeechService();
    statuses = StreamController<SpeechStatus>.broadcast();
    when(() => service.status).thenReturn(SpeechStatus.idle);
    when(() => service.statusChanges).thenAnswer((_) => statuses.stream);
    when(() => service.speak(any(), rate: any(named: 'rate'))).thenAnswer((_) async {});
    when(service.pause).thenAnswer((_) async {});
    when(service.stop).thenAnswer((_) async {});
    when(() => service.resume(any(), rate: any(named: 'rate'))).thenAnswer((_) async {});
    repository = SpeechRepositoryImpl(service);
  });
  tearDown(() => statuses.close());

  test('watchStatus starts with the current status and then follows the engine', () async {
    final seen = <SpeechStatus>[];
    final sub = repository.watchStatus().listen(seen.add);
    await flush();
    statuses.add(SpeechStatus.speaking);
    await flush();
    await sub.cancel();

    expect(seen, [SpeechStatus.idle, SpeechStatus.speaking]);
  });

  test('resume re-speaks the last text at the last rate', () async {
    await repository.speak('Hello', rate: 1.2);
    await repository.resume();

    verify(() => service.resume('Hello', rate: 1.2)).called(1);
  });

  test('engine errors become a failure instead of crashing', () async {
    when(() => service.speak(any(), rate: any(named: 'rate'))).thenThrow(Exception('no engine'));

    final result = await repository.speak('x', rate: 1);

    expect(result.isFailure, isTrue);
    expect((await repository.stop()).isSuccess, isTrue);
  });

  test('pause delegates to the engine', () async {
    expect((await repository.pause()).isSuccess, isTrue);
    verify(service.pause).called(1);
  });
}
