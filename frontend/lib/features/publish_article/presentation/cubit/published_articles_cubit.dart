import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/use_cases/get_published_articles_use_case.dart';
import 'published_articles_state.dart';

class PublishedArticlesCubit extends Cubit<PublishedArticlesState> {
  final GetPublishedArticlesUseCase _getPublishedArticles;

  PublishedArticlesCubit(this._getPublishedArticles)
      : super(const PublishedArticlesState());

  Future<void> load() async {
    if (state.isLoading) return;

    emit(const PublishedArticlesState(
      status: PublishedArticlesStatus.loading,
    ));

    try {
      final articles = await _getPublishedArticles();
      if (isClosed) return;
      emit(PublishedArticlesState(
        status: PublishedArticlesStatus.success,
        articles: articles,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(const PublishedArticlesState(
        status: PublishedArticlesStatus.failure,
        failureMessage: 'Unable to load published articles.',
      ));
    }
  }
}
