import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/device/device_speech_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/speech_status.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/speech_repository.dart';

class SpeechRepositoryImpl implements SpeechRepository {
  final DeviceSpeechService _service;
  String _lastText = '';
  double _lastRate = 1;

  SpeechRepositoryImpl(this._service);

  static const String _errorMessage = "The device voice couldn't read this.";

  /// A plain stream (no `async*`): the current status is delivered
  /// synchronously and later changes follow, which also keeps widget tests
  /// under fake time from waiting on a generator that never settles.
  @override
  Stream<SpeechStatus> watchStatus() => Stream<SpeechStatus>.multi((controller) {
        controller.add(_service.status);
        final subscription = _service.statusChanges.listen(controller.add, onDone: controller.close);
        controller.onCancel = subscription.cancel;
      });

  @override
  Future<DataState<void>> speak(String text, {required double rate}) {
    _lastText = text;
    _lastRate = rate;
    return _guard(() => _service.speak(text, rate: rate));
  }

  @override
  Future<DataState<void>> pause() => _guard(_service.pause);

  @override
  Future<DataState<void>> resume() => _guard(() => _service.resume(_lastText, rate: _lastRate));

  @override
  Future<DataState<void>> stop() => _guard(_service.stop);

  Future<DataState<void>> _guard(Future<void> Function() operation) =>
      runGuarded(operation, onError: (_) => const Failure.unknown(_errorMessage));
}
