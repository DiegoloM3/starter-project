import 'package:equatable/equatable.dart';

import 'article_narration.dart';

/// Which sentence of [narration] the device is reading aloud.
class ArticleNarrationProgressEntity extends Equatable {
  final ArticleNarrationEntity narration;

  /// Index in [ArticleNarrationEntity.sentences].
  final int sentenceIndex;

  const ArticleNarrationProgressEntity({required this.narration, required this.sentenceIndex});

  /// From 0 (nothing read yet) to 1 (reading the last sentence).
  double get fractionRead => (sentenceIndex + 1) / narration.sentences.length;

  @override
  List<Object?> get props => [narration, sentenceIndex];
}
