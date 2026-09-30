import 'package:equatable/equatable.dart';

import '../../../domain/entities/article_narration_progress.dart';

sealed class ArticleNarrationState extends Equatable {
  const ArticleNarrationState();

  @override
  List<Object?> get props => [];
}

final class ArticleNarrationIdle extends ArticleNarrationState {
  const ArticleNarrationIdle();
}

final class ArticleNarrationReading extends ArticleNarrationState {
  /// The sentence being read, or `null` while the voice is being prepared.
  final ArticleNarrationProgressEntity? progress;

  const ArticleNarrationReading({this.progress});

  @override
  List<Object?> get props => [progress];
}

/// The device has no usable text-to-speech engine.
final class ArticleNarrationUnavailable extends ArticleNarrationState {
  const ArticleNarrationUnavailable();
}
