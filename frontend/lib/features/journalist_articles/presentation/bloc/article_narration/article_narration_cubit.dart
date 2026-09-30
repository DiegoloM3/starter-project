import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';

import '../../../domain/entities/article_narration_progress.dart';
import '../../../domain/entities/published_article.dart';
import '../../../domain/use_cases/read_article_aloud.dart';
import '../../../domain/use_cases/stop_reading_aloud.dart';
import 'article_narration_state.dart';

class ArticleNarrationCubit extends Cubit<ArticleNarrationState> {
  final ReadArticleAloudUseCase _readArticleAloudUseCase;
  final StopReadingAloudUseCase _stopReadingAloudUseCase;

  ArticleNarrationCubit(this._readArticleAloudUseCase, this._stopReadingAloudUseCase)
      : super(const ArticleNarrationIdle());

  /// Starts reading [article] aloud, following each sentence, or stops if it is already being read.
  Future<void> toggleReading(PublishedArticleEntity article) async {
    if (state is ArticleNarrationReading) {
      await _stopReadingAloudUseCase();
      return;
    }
    emit(const ArticleNarrationReading());
    await for (final result in _readArticleAloudUseCase(params: article)) {
      if (isClosed) return;
      emit(_stateOf(result));
    }
    if (!isClosed && state is ArticleNarrationReading) emit(const ArticleNarrationIdle());
  }

  /// Leaving the article stops the voice.
  @override
  Future<void> close() async {
    if (state is ArticleNarrationReading) await _stopReadingAloudUseCase();
    return super.close();
  }

  ArticleNarrationState _stateOf(DataState<ArticleNarrationProgressEntity> result) {
    if (result is DataFailed) return const ArticleNarrationUnavailable();
    return ArticleNarrationReading(progress: result.data);
  }
}
