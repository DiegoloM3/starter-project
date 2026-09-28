import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/local/local_article_state.dart';

import 'package:news_app_clean_architecture/features/news/domain/usecases/get_saved_article.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/remove_article.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/save_article.dart';

@injectable
/// UI state machine for locally saved articles.
class LocalArticleBloc extends Bloc<LocalArticlesEvent,LocalArticlesState> {
  static final _log = Logger('LocalArticleBloc');

  final GetSavedArticleUseCase _getSavedArticleUseCase;
  final SaveArticleUseCase _saveArticleUseCase;
  final RemoveArticleUseCase _removeArticleUseCase;

  LocalArticleBloc(
    this._getSavedArticleUseCase,
    this._saveArticleUseCase,
    this._removeArticleUseCase
  ) : super(const LocalArticlesLoading()){
    on <GetSavedArticles> (onGetSavedArticles);
    on <RemoveArticle> (onRemoveArticle);
    on <SaveArticle> (onSaveArticle);
  }


  Future<void> onGetSavedArticles(GetSavedArticles event,Emitter<LocalArticlesState> emit) async {
    try {
      final articles = await _getSavedArticleUseCase();
      emit(LocalArticlesDone(articles));
    } catch (e, st) {
      _log.severe('onGetSavedArticles → failed', e, st);
      emit(LocalArticlesError(e.toString()));
    }
  }

  Future<void> onRemoveArticle(RemoveArticle removeArticle,Emitter<LocalArticlesState> emit) async {
    try {
      await _removeArticleUseCase(params: removeArticle.article);
      final articles = await _getSavedArticleUseCase();
      emit(LocalArticlesDone(articles));
    } catch (e, st) {
      _log.severe('onRemoveArticle → failed', e, st);
      emit(LocalArticlesError(e.toString()));
    }
  }

  Future<void> onSaveArticle(SaveArticle saveArticle,Emitter<LocalArticlesState> emit) async {
    try {
      await _saveArticleUseCase(params: saveArticle.article);
      final articles = await _getSavedArticleUseCase();
      emit(LocalArticlesDone(articles));
    } catch (e, st) {
      _log.severe('onSaveArticle → failed', e, st);
      emit(LocalArticlesError(e.toString()));
    }
  }
}
