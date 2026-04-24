import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_saved_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/remove_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/save_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_state.dart';

class LocalArticleBloc extends Bloc<LocalArticlesEvent, LocalArticlesState> {
  LocalArticleBloc(
    this._getSavedArticleUseCase,
    this._saveArticleUseCase,
    this._removeArticleUseCase,
  ) : super(const LocalArticlesLoading()) {
    on<GetSavedArticles>(onGetSavedArticles);
    on<RemoveArticle>(onRemoveArticle);
    on<SaveArticle>(onSaveArticle);
  }
  final GetSavedArticleUseCase _getSavedArticleUseCase;
  final SaveArticleUseCase _saveArticleUseCase;
  final RemoveArticleUseCase _removeArticleUseCase;

  Future<void> onGetSavedArticles(
    GetSavedArticles event,
    Emitter<LocalArticlesState> emit,
  ) async {
    final result = await _getSavedArticleUseCase(const NoParams());
    result.fold(
      (failure) => emit(LocalArticlesError(failure)),
      (articles) => emit(LocalArticlesDone(articles)),
    );
  }

  Future<void> onRemoveArticle(
    RemoveArticle removeArticle,
    Emitter<LocalArticlesState> emit,
  ) async {
    final removal = await _removeArticleUseCase(removeArticle.article!);
    await removal.fold(
      (failure) async => emit(LocalArticlesError(failure)),
      (_) async {
        final reload = await _getSavedArticleUseCase(const NoParams());
        reload.fold(
          (failure) => emit(LocalArticlesError(failure)),
          (articles) => emit(LocalArticlesDone(articles)),
        );
      },
    );
  }

  Future<void> onSaveArticle(
    SaveArticle saveArticle,
    Emitter<LocalArticlesState> emit,
  ) async {
    final creation = await _saveArticleUseCase(saveArticle.article!);
    await creation.fold(
      (failure) async => emit(LocalArticlesError(failure)),
      (_) async {
        final reload = await _getSavedArticleUseCase(const NoParams());
        reload.fold(
          (failure) => emit(LocalArticlesError(failure)),
          (articles) => emit(LocalArticlesDone(articles)),
        );
      },
    );
  }
}
