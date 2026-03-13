import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'tts_state.dart';

/// Cubit for managing Text-to-Speech functionality in article detail view
class TtsCubit extends Cubit<TtsState> {
  final FlutterTts _flutterTts;
  String? _currentText;
  // ignore: unused_field
  int _currentWordIndex = 0;

  TtsCubit({FlutterTts? flutterTts})
      : _flutterTts = flutterTts ?? FlutterTts(),
        super(const TtsState()) {
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      // Check if TTS is available
      final isAvailable = await _flutterTts.isLanguageAvailable('en-US');

      if (isAvailable) {
        await _flutterTts.setLanguage('en-US');
        await _flutterTts.setSpeechRate(0.5);
        await _flutterTts.setVolume(1.0);
        await _flutterTts.setPitch(1.0);

        _flutterTts.setStartHandler(() {
          emit(state.copyWith(status: TtsStatus.playing));
        });

        _flutterTts.setCompletionHandler(() {
          emit(state.copyWith(
            status: TtsStatus.stopped,
            currentPosition: Duration.zero,
          ));
          _currentWordIndex = 0;
        });

        _flutterTts.setErrorHandler((error) {
          emit(state.copyWith(
            status: TtsStatus.error,
            errorMessage: error.toString(),
          ));
        });

        _flutterTts.setProgressHandler((text, start, end, word) {
          _updateProgress(start, end);
        });

        emit(state.copyWith(isAvailable: true));
      } else {
        emit(state.copyWith(
          isAvailable: false,
          errorMessage: 'Text-to-speech is not available on this device',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isAvailable: false,
        errorMessage: 'Failed to initialize text-to-speech',
      ));
    }
  }

  void _updateProgress(int start, int end) {
    if (_currentText == null) return;

    final progress = end / _currentText!.length;
    final estimatedTotalSeconds = _estimateReadingTime(_currentText!);
    final totalDuration = Duration(seconds: estimatedTotalSeconds);
    final currentPosition = Duration(
      seconds: (estimatedTotalSeconds * progress).round(),
    );

    emit(state.copyWith(
      currentPosition: currentPosition,
      totalDuration: totalDuration,
    ));
  }

  int _estimateReadingTime(String text) {
    // Average TTS rate is about 150 words per minute at normal speed
    final wordCount = text.split(RegExp(r'\s+')).length;
    final wordsPerMinute = 150 * state.playbackSpeed;
    return ((wordCount / wordsPerMinute) * 60).round();
  }

  /// Prepare text for reading
  void prepareText(String text) {
    _currentText = text;
    _currentWordIndex = 0;

    final totalSeconds = _estimateReadingTime(text);
    emit(state.copyWith(
      totalDuration: Duration(seconds: totalSeconds),
      currentPosition: Duration.zero,
      status: TtsStatus.stopped,
    ));
  }

  /// Start or resume playback
  Future<void> play() async {
    if (_currentText == null || _currentText!.isEmpty) return;

    emit(state.copyWith(status: TtsStatus.loading));

    try {
      await _flutterTts.speak(_currentText!);
    } catch (e) {
      emit(state.copyWith(
        status: TtsStatus.error,
        errorMessage: 'Failed to start playback',
      ));
    }
  }

  /// Pause playback
  Future<void> pause() async {
    try {
      await _flutterTts.pause();
      emit(state.copyWith(status: TtsStatus.paused));
    } catch (e) {
      emit(state.copyWith(
        status: TtsStatus.error,
        errorMessage: 'Failed to pause playback',
      ));
    }
  }

  /// Stop playback
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _currentWordIndex = 0;
      emit(state.copyWith(
        status: TtsStatus.stopped,
        currentPosition: Duration.zero,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TtsStatus.error,
        errorMessage: 'Failed to stop playback',
      ));
    }
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  /// Set playback speed
  Future<void> setPlaybackSpeed(double speed) async {
    // Speed range: 0.5 to 2.0
    final clampedSpeed = speed.clamp(0.5, 2.0);
    await _flutterTts.setSpeechRate(clampedSpeed * 0.5); // TTS uses 0-1 range
    emit(state.copyWith(playbackSpeed: clampedSpeed));

    // Update estimated duration
    if (_currentText != null) {
      final totalSeconds = _estimateReadingTime(_currentText!);
      emit(state.copyWith(totalDuration: Duration(seconds: totalSeconds)));
    }
  }

  /// Clear any errors
  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  @override
  Future<void> close() {
    _flutterTts.stop();
    return super.close();
  }
}
