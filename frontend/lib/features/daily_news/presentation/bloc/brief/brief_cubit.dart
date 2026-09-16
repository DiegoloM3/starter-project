import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/news_query.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_top_headlines.dart';

part 'brief_state.dart';

/// Today's Brief: pick topics, swipe through five stories, see a summary.
///
/// App-wide so the Home card can show "Brief done" after the summary, and
/// so leaving the flow mid-way keeps the progress for the day.
class BriefCubit extends Cubit<BriefState> {
  final GetTopHeadlinesUseCase _getTopHeadlines;

  static const int storyCount = 5;
  static const List<NewsCategory> topics = [
    NewsCategory.business,
    NewsCategory.technology,
    NewsCategory.sports,
    NewsCategory.health,
    NewsCategory.science,
    NewsCategory.entertainment,
  ];

  BriefCubit(this._getTopHeadlines) : super(const BriefState());

  void toggleTopic(NewsCategory topic) {
    final selected = Set.of(state.selectedTopics);
    if (!selected.remove(topic)) selected.add(topic);
    emit(state.copyWith(selectedTopics: selected));
  }

  /// "Surprise me": every topic at once.
  void selectAllTopics() => emit(state.copyWith(selectedTopics: topics.toSet()));

  /// Fetches the headlines of every chosen topic, interleaves them so the
  /// brief mixes topics, and keeps the first [storyCount].
  Future<void> start() async {
    if (state.selectedTopics.isEmpty) return;
    emit(state.copyWith(step: BriefStep.loading));

    final topics = state.selectedTopics.toList();
    final results = await Future.wait([
      for (final topic in topics)
        _getTopHeadlines(NewsQuery(category: topic)),
    ]);
    if (isClosed) return;

    final lists = [for (final r in results) r.dataOrNull ?? const <ArticleEntity>[]];
    final articles = _interleave(lists).take(storyCount).toList();
    if (articles.isEmpty) {
      final failure = results.firstWhere((r) => r.isFailure, orElse: () => results.first).failureOrNull;
      emit(state.copyWith(
        step: BriefStep.failure,
        failure: failure ?? const Failure.notFound('No stories found for those topics today.'),
      ));
      return;
    }

    emit(state.copyWith(step: BriefStep.reading, articles: articles, index: 0, readIds: const {}));
  }

  void cardShown(int index) {
    if (index < 0 || index >= state.articles.length) return;
    emit(state.copyWith(index: index, readIds: {...state.readIds, state.articles[index].id}));
  }

  void markRead(ArticleEntity article) =>
      emit(state.copyWith(readIds: {...state.readIds, article.id}));

  void finish(DateTime now) => emit(state.copyWith(step: BriefStep.summary, completedAt: now));

  /// Back to topic picking, keeping today's completion so the Home card
  /// still knows the brief was read.
  void restart() => emit(BriefState(completedAt: state.completedAt));

  /// Back to a fresh start, today's completion included: the next account
  /// gets its own brief.
  void reset() => emit(const BriefState());

  static List<ArticleEntity> _interleave(List<List<ArticleEntity>> lists) {
    final seen = <String>{};
    final out = <ArticleEntity>[];
    final longest = lists.fold(0, (max, l) => l.length > max ? l.length : max);
    for (var i = 0; i < longest; i++) {
      for (final list in lists) {
        if (i < list.length && seen.add(list[i].id)) out.add(list[i]);
      }
    }
    return out;
  }
}
