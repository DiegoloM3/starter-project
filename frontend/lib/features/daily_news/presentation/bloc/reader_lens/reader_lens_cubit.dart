import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_lens.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/apply_article_lens.dart';

part 'reader_lens_state.dart';

/// Which lens the Reader is looking through. Answers are cached per lens, so
/// switching back and forth costs one request per lens at most.
class ReaderLensCubit extends Cubit<ReaderLensState> {
  final ApplyArticleLensUseCase _applyLens;
  final ArticleEntity _article;

  ReaderLensCubit(this._applyLens, {required ArticleEntity article})
      : _article = article,
        super(const ReaderLensState());

  /// Tapping the active lens returns to the original text.
  Future<void> toggle(ArticleLens lens) async {
    if (state.active == lens) {
      emit(state.copyWith(clearActive: true));
      return;
    }
    if (state.results.containsKey(lens)) {
      emit(state.copyWith(active: lens));
      return;
    }

    emit(state.copyWith(active: lens, loading: lens));
    final result = await _applyLens(ApplyArticleLensParams(lens: lens, article: _article));
    if (isClosed || state.active != lens) return;

    emit(switch (result) {
      DataSuccess(:final data) => state.copyWith(
          clearLoading: true,
          results: {...state.results, lens: data},
        ),
      DataFailed(:final failure) => state.copyWith(clearActive: true, clearLoading: true, failure: failure),
    });
  }

  void showOriginal() => emit(state.copyWith(clearActive: true, clearLoading: true));
}
