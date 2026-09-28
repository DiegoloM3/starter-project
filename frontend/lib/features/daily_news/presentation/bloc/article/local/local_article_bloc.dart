import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_entity.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/article/get_saved_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/article/remove_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/article/save_article.dart';

part 'local_article_event.dart';
part 'local_article_state.dart';

class LocalArticleBloc extends Bloc<LocalArticlesEvent, LocalArticlesState> {
  final GetSavedArticleUseCase _getSavedArticleUseCase;
  final SaveArticleUseCase _saveArticleUseCase;
  final RemoveArticleUseCase _removeArticleUseCase;

  LocalArticleBloc({
    required GetSavedArticleUseCase getSavedArticleUseCase,
    required SaveArticleUseCase saveArticleUseCase,
    required RemoveArticleUseCase removeArticleUseCase,
  })  : _getSavedArticleUseCase = getSavedArticleUseCase,
        _saveArticleUseCase = saveArticleUseCase,
        _removeArticleUseCase = removeArticleUseCase,
        super(LocalArticlesLoading()) {
    on<GetSavedArticles>(_onGetSavedArticles);
    on<RemoveArticle>(_onRemoveArticle);
    on<SaveArticle>(_onSaveArticle);
  }

  Future<void> _onGetSavedArticles(
      GetSavedArticles event, Emitter<LocalArticlesState> emit) async {
    final articles = await _getSavedArticleUseCase();
    emit(LocalArticlesDone(articles: articles));
  }

  Future<void> _onRemoveArticle(
      RemoveArticle removeArticle, Emitter<LocalArticlesState> emit) async {
    await _removeArticleUseCase(params: removeArticle.article);
    final articles = await _getSavedArticleUseCase();
    emit(LocalArticlesDone(articles: articles));
  }

  Future<void> _onSaveArticle(
      SaveArticle saveArticle, Emitter<LocalArticlesState> emit) async {
    await _saveArticleUseCase(params: saveArticle.article);
    final articles = await _getSavedArticleUseCase();
    emit(LocalArticlesDone(articles: articles));
  }
}
