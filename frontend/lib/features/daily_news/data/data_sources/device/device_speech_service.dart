// coverage:ignore-file
// Thin wrapper over the platform text-to-speech plugin.
// Covered by the repository tests above it, with the SDK mocked at this seam.
import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/speech_status.dart';

/// Talks to the platform text-to-speech engine through `flutter_tts`.
/// The engine reports completion and cancellation through callbacks, which
/// are turned into [SpeechStatus] events here.
class DeviceSpeechService {
  final FlutterTts _tts;
  final StreamController<SpeechStatus> _status = StreamController<SpeechStatus>.broadcast();
  SpeechStatus _current = SpeechStatus.idle;

  DeviceSpeechService(this._tts) {
    _tts.setStartHandler(() => _set(SpeechStatus.speaking));
    _tts.setContinueHandler(() => _set(SpeechStatus.speaking));
    _tts.setPauseHandler(() => _set(SpeechStatus.paused));
    _tts.setCompletionHandler(() => _set(SpeechStatus.idle));
    _tts.setCancelHandler(() => _set(SpeechStatus.idle));
    _tts.setErrorHandler((_) => _set(SpeechStatus.idle));
  }

  static const String language = 'en-US';

  SpeechStatus get status => _current;

  Stream<SpeechStatus> get statusChanges => _status.stream;

  Future<void> speak(String text, {required double rate}) async {
    await _tts.stop();
    // The app is English-only, so the voice is too, whatever the device locale.
    await _tts.setLanguage(language);
    // flutter_tts rates are 0..1 with 0.5 as normal on Android.
    await _tts.setSpeechRate((0.5 * rate).clamp(0.1, 1.0));
    await _tts.awaitSpeakCompletion(false);
    await _tts.speak(text);
    _set(SpeechStatus.speaking);
  }

  Future<void> pause() async {
    await _tts.pause();
    _set(SpeechStatus.paused);
  }

  /// `flutter_tts` has no resume; speaking again continues from the pause
  /// point on platforms that support it, otherwise restarts.
  Future<void> resume(String text, {required double rate}) => speak(text, rate: rate);

  Future<void> stop() async {
    await _tts.stop();
    _set(SpeechStatus.idle);
  }

  void _set(SpeechStatus status) {
    _current = status;
    if (!_status.isClosed) _status.add(status);
  }

  Future<void> dispose() => _status.close();
}
