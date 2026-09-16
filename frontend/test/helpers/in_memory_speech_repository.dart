import 'dart:async';

import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/speech_status.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/speech_repository.dart';

/// Silent voice for tests: tracks status and what was asked to be read.

class InMemorySpeechRepository implements SpeechRepository {
  final StreamController<SpeechStatus> _status = StreamController<SpeechStatus>.broadcast();
  SpeechStatus _current = SpeechStatus.idle;
  final List<String> spoken = [];
  double? lastRate;

  @override
  Stream<SpeechStatus> watchStatus() => Stream<SpeechStatus>.multi((controller) {
        controller.add(_current);
        final subscription = _status.stream.listen(controller.add, onDone: controller.close);
        controller.onCancel = subscription.cancel;
      });

  @override
  Future<DataState<void>> speak(String text, {required double rate}) async {
    spoken.add(text);
    lastRate = rate;
    _set(SpeechStatus.speaking);
    return const DataSuccess(null);
  }

  @override
  Future<DataState<void>> pause() async {
    _set(SpeechStatus.paused);
    return const DataSuccess(null);
  }

  @override
  Future<DataState<void>> resume() async {
    _set(SpeechStatus.speaking);
    return const DataSuccess(null);
  }

  @override
  Future<DataState<void>> stop() async {
    _set(SpeechStatus.idle);
    return const DataSuccess(null);
  }

  /// Simulates the voice reaching the end of the text.
  void finish() => _set(SpeechStatus.idle);

  void _set(SpeechStatus status) {
    _current = status;
    _status.add(status);
  }

  Future<void> dispose() => _status.close();
}
