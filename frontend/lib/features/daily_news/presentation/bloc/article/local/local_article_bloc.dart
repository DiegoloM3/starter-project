import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_state.dart';

import '../../../../domain/usecases/get_saved_article.dart';
import '../../../../domain/usecases/remove_article.dart';
import '../../../../domain/usecases/save_article.dart';

class LocalArticleDeps {
  final GetSavedArticleUseCase getSaved;
  final SaveArticleUseCase save;
  final RemoveArticleUseCase remove;

  const LocalArticleDeps({
    required this.getSaved,
    required this.save,
    required this.remove,
  });
}

class LocalArticleBloc extends Bloc<LocalArticlesEvent, LocalArticlesState> {
  final LocalArticleDeps _deps;

  LocalArticleBloc(this._deps) : super(const LocalArticlesLoading()) {
    on<GetSavedArticles>(_onGetSavedArticles);
    on<RemoveArticle>(_onRemoveArticle);
    on<SaveArticle>(_onSaveArticle);
  }

  Future<void> _onGetSavedArticles(
      GetSavedArticles event, Emitter<LocalArticlesState> emit) async {
    final articles = await _deps.getSaved();
    emit(LocalArticlesDone(articles));
  }

  Future<void> _onRemoveArticle(
      RemoveArticle event, Emitter<LocalArticlesState> emit) async {
    await _deps.remove(params: event.article);
    final articles = await _deps.getSaved();
    emit(LocalArticlesDone(articles));
  }

  Future<void> _onSaveArticle(
      SaveArticle event, Emitter<LocalArticlesState> emit) async {
    await _deps.save(params: event.article);
    final articles = await _deps.getSaved();
    emit(LocalArticlesDone(articles));
  }
}
