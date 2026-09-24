import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';

import '../../../domain/entities/journalist_stats.dart';
import '../../../domain/params/get_my_articles_params.dart';
import '../../../domain/use_cases/get_journalist_stats.dart';
import 'journalist_stats_state.dart';

/// Puts the summary of a journalist's work on their account screen.
///
/// It asks for the numbers and reports what came back. Working them out is
/// [GetJournalistStatsUseCase]'s job, not this one's.
class JournalistStatsCubit extends Cubit<JournalistStatsState> {
  final GetJournalistStatsUseCase _getJournalistStats;

  JournalistStatsCubit(this._getJournalistStats)
      : super(const JournalistStatsState());

  Future<void> loadFor(String userId) async {
    emit(const JournalistStatsState(status: JournalistStatsStatus.loading));

    final result = await _getJournalistStats(
      GetMyArticlesParams(userId: userId),
    );

    if (result is DataSuccess<JournalistStatsEntity>) {
      emit(JournalistStatsState(
        status: JournalistStatsStatus.ready,
        stats: result.data!,
      ));
      return;
    }

    // A summary nobody asked for is not worth an error message on the
    // account screen; the rest of it still works without these numbers.
    emit(const JournalistStatsState(status: JournalistStatsStatus.failure));
  }

  /// Forgets the numbers, for when somebody signs out and a different person
  /// may sign in on the same device.
  void clear() => emit(const JournalistStatsState());
}
