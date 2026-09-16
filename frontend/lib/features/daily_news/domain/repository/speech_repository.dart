import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/speech_status.dart';

/// The device's text-to-speech voice. One utterance at a time.
abstract interface class SpeechRepository {
  /// Emits the current status first, then every change (also when the
  /// voice finishes on its own).
  Stream<SpeechStatus> watchStatus();

  /// Starts reading [text], replacing whatever was being read.
  Future<DataState<void>> speak(String text, {required double rate});

  Future<DataState<void>> pause();

  Future<DataState<void>> resume();

  Future<DataState<void>> stop();
}
