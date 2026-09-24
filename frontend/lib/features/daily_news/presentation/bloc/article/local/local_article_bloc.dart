import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_state.dart';

import '../../../../domain/entities/article.dart';
import '../../../../domain/use_cases/get_saved_articles.dart';
import '../../../../domain/use_cases/remove_article.dart';
import '../../../../domain/use_cases/save_article.dart';

/// The articles the reader kept.
///
/// Saving and removing both end by re-reading the list, so what the Saved tab
/// shows is always what is actually stored rather than what this bloc assumed
/// the write did.
class LocalArticleBloc extends Bloc<LocalArticlesEvent, LocalArticlesState> {
  final GetSavedArticlesUseCase _getSavedArticles;
  final SaveArticleUseCase _saveArticle;
  final RemoveArticleUseCase _removeArticle;

  LocalArticleBloc(
    this._getSavedArticles,
    this._saveArticle,
    this._removeArticle,
  ) : super(const LocalArticlesLoading()) {
    on<GetSavedArticles>(onGetSavedArticles);
    on<RemoveArticle>(onRemoveArticle);
    on<SaveArticle>(onSaveArticle);
  }

  Future<void> onGetSavedArticles(
    GetSavedArticles event,
    Emitter<LocalArticlesState> emit,
  ) {
    return _emitSavedArticles(emit);
  }

  Future<void> onRemoveArticle(
    RemoveArticle event,
    Emitter<LocalArticlesState> emit,
  ) async {
    final result = await _removeArticle(event.article);

    return _emitWriteResult(result, emit);
  }

  Future<void> onSaveArticle(
    SaveArticle event,
    Emitter<LocalArticlesState> emit,
  ) async {
    final result = await _saveArticle(event.article);

    return _emitWriteResult(result, emit);
  }

  /// A failed write is reported; a successful one is followed by a re-read,
  /// because the list on screen has just changed.
  Future<void> _emitWriteResult(
    DataState<void> result,
    Emitter<LocalArticlesState> emit,
  ) {
    if (result is DataFailed) {
      emit(LocalArticlesError(result.error!));

      return Future.value();
    }

    return _emitSavedArticles(emit);
  }

  Future<void> _emitSavedArticles(Emitter<LocalArticlesState> emit) async {
    final result = await _getSavedArticles(const NoParams());

    if (result is DataSuccess<List<ArticleEntity>>) {
      emit(LocalArticlesDone(result.data ?? const []));
      return;
    }

    emit(LocalArticlesError(
      result.error ?? Exception('The saved articles could not be read.'),
    ));
  }
}
