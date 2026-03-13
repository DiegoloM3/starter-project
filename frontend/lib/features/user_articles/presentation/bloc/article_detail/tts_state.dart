import 'package:equatable/equatable.dart';

/// TTS playback status
enum TtsStatus {
  stopped,
  playing,
  paused,
  loading,
  error,
}

/// State for text-to-speech functionality
class TtsState extends Equatable {
  final TtsStatus status;
  final Duration currentPosition;
  final Duration totalDuration;
  final double playbackSpeed;
  final String? errorMessage;
  final bool isAvailable;

  const TtsState({
    this.status = TtsStatus.stopped,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.playbackSpeed = 1.0,
    this.errorMessage,
    this.isAvailable = true,
  });

  /// Check if TTS is currently playing
  bool get isPlaying => status == TtsStatus.playing;

  /// Check if TTS is paused
  bool get isPaused => status == TtsStatus.paused;

  /// Check if TTS can be played
  bool get canPlay =>
      isAvailable &&
      (status == TtsStatus.stopped || status == TtsStatus.paused);

  /// Progress percentage (0.0 to 1.0)
  double get progress => totalDuration.inMilliseconds > 0
      ? currentPosition.inMilliseconds / totalDuration.inMilliseconds
      : 0.0;

  /// Formatted current position (mm:ss)
  String get formattedPosition => _formatDuration(currentPosition);

  /// Formatted total duration (mm:ss)
  String get formattedDuration => _formatDuration(totalDuration);

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  List<Object?> get props => [
        status,
        currentPosition,
        totalDuration,
        playbackSpeed,
        errorMessage,
        isAvailable,
      ];

  TtsState copyWith({
    TtsStatus? status,
    Duration? currentPosition,
    Duration? totalDuration,
    double? playbackSpeed,
    String? errorMessage,
    bool? isAvailable,
    bool clearError = false,
  }) {
    return TtsState(
      status: status ?? this.status,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
