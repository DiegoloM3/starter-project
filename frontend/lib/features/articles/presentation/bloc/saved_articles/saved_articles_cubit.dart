import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/resources/data_state.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../../domain/entities/article.dart';
import '../../../domain/usecases/get_saved_articles.dart';
import '../../../domain/usecases/remove_saved_article.dart';
import '../../../domain/usecases/save_article.dart';
import 'saved_articles_state.dart';

class SavedArticlesCubit extends Cubit<SavedArticlesState> {
  final GetSavedArticlesUseCase _getSavedArticlesUseCase;
  final SaveArticleUseCase _saveArticleUseCase;
  final RemoveSavedArticleUseCase _removeSavedArticleUseCase;

  SavedArticlesCubit(this._getSavedArticlesUseCase, this._saveArticleUseCase, this._removeSavedArticleUseCase)
    : super(const SavedArticlesState());

  Future<void> load() async {
    emit(SavedArticlesState(status: SavedArticlesStatus.loading, articles: state.articles));
    final result = await _getSavedArticlesUseCase(const NoParams());
    if (result is DataSuccess) {
      emit(SavedArticlesState(status: SavedArticlesStatus.success, articles: result.data!));
    } else {
      emit(SavedArticlesState(status: SavedArticlesStatus.failure, articles: state.articles));
    }
  }

  /// Shows the change at once and restores the previous articles if it fails.
  Future<void> toggle(ArticleEntity article) async {
    final previousArticles = state.articles;
    final isSaved = state.isSaved(article.id);
    emit(
      SavedArticlesState(
        status: SavedArticlesStatus.success,
        articles: isSaved ? _without(article) : [article, ...previousArticles],
      ),
    );

    final result = isSaved ? await _removeSavedArticleUseCase(article.id) : await _saveArticleUseCase(article.id);
    if (result is DataFailed) {
      emit(SavedArticlesState(status: SavedArticlesStatus.toggleFailure, articles: previousArticles));
    }
  }

  List<ArticleEntity> _without(ArticleEntity article) {
    return state.articles.where((savedArticle) => savedArticle.id != article.id).toList();
  }
}
