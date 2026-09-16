part of 'brief_cubit.dart';

enum BriefStep { picking, loading, reading, summary, failure }

class BriefState extends Equatable {
  final BriefStep step;
  final Set<NewsCategory> selectedTopics;
  final List<ArticleEntity> articles;
  final int index;
  final Set<String> readIds;
  final DateTime? completedAt;
  final Failure? failure;

  const BriefState({
    this.step = BriefStep.picking,
    this.selectedTopics = const {},
    this.articles = const [],
    this.index = 0,
    this.readIds = const {},
    this.completedAt,
    this.failure,
  });

  bool get canStart => selectedTopics.isNotEmpty;

  int get readCount => readIds.length;

  /// Reading time of the whole brief, never less than one minute.
  int get totalMinutes {
    final minutes = articles.fold(0, (sum, a) => sum + a.readingTimeMinutes);
    return minutes < 1 ? 1 : minutes;
  }

  bool isCompletedOn(DateTime day) {
    final done = completedAt;
    return done != null && done.year == day.year && done.month == day.month && done.day == day.day;
  }

  BriefState copyWith({
    BriefStep? step,
    Set<NewsCategory>? selectedTopics,
    List<ArticleEntity>? articles,
    int? index,
    Set<String>? readIds,
    DateTime? completedAt,
    Failure? failure,
  }) {
    return BriefState(
      step: step ?? this.step,
      selectedTopics: selectedTopics ?? this.selectedTopics,
      articles: articles ?? this.articles,
      index: index ?? this.index,
      readIds: readIds ?? this.readIds,
      completedAt: completedAt ?? this.completedAt,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [step, selectedTopics, articles, index, readIds, completedAt, failure];
}
