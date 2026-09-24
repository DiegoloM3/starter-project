import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

/// The headlines of the section the reader is looking at.
class RemoteArticlesBloc
    extends Bloc<RemoteArticlesEvent, RemoteArticlesState> {
  final GetArticlesUseCase _getArticles;

  RemoteArticlesBloc(this._getArticles) : super(const RemoteArticlesLoading()) {
    on<GetArticles>(onGetArticles);
  }

  Future<void> onGetArticles(
    GetArticles event,
    Emitter<RemoteArticlesState> emit,
  ) async {
    emit(RemoteArticlesLoading(category: event.category));

    final result = await _getArticles(event.category);

    if (result is DataSuccess<List<ArticleEntity>>) {
      // A section with no headlines is an answer, not a failure. Treating it
      // as one left the feed loading forever whenever the API came back
      // empty, because neither branch emitted anything.
      emit(RemoteArticlesDone(
        result.data ?? const [],
        category: event.category,
      ));
      return;
    }

    emit(RemoteArticlesError(
      result.error ?? Exception('The news could not be loaded.'),
      category: event.category,
    ));
  }
}
