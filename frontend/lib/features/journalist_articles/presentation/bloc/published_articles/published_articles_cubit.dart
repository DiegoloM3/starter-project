import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/published_article.dart';
import '../../../domain/params/get_published_articles_params.dart';
import '../../../domain/use_cases/get_published_articles.dart';
import 'published_articles_state.dart';

class PublishedArticlesCubit extends Cubit<PublishedArticlesState> {
  static const int _pageSize = GetPublishedArticlesParams.defaultPageSize;

  final GetPublishedArticlesUseCase _getPublishedArticlesUseCase;

  PublishedArticlesCubit(this._getPublishedArticlesUseCase) : super(const PublishedArticlesLoading());

  /// Loads the first page. An already visible list stays on screen until the new one arrives.
  Future<void> loadArticles() async {
    if (state is PublishedArticlesError) emit(const PublishedArticlesLoading());
    final result = await _getPublishedArticlesUseCase(params: const GetPublishedArticlesParams(pageSize: _pageSize));
    final page = result.data;
    emit(page == null
        ? PublishedArticlesError(result.error!)
        : PublishedArticlesLoaded(articles: page, hasMore: _isFullPage(page)));
  }

  Future<void> loadMoreArticles() async {
    final current = state;
    if (current is! PublishedArticlesLoaded || !current.hasMore || current.isLoadingMore) return;
    emit(current.startLoadingMore());
    final result = await _getPublishedArticlesUseCase(
      params: GetPublishedArticlesParams(pageSize: _pageSize, startAfter: current.articles.last),
    );
    final page = result.data;
    emit(page == null
        ? current.stopLoadingMore()
        : PublishedArticlesLoaded(articles: [...current.articles, ...page], hasMore: _isFullPage(page)));
  }

  /// A full page means the backend may have more articles after it.
  bool _isFullPage(List<PublishedArticleEntity> page) => page.length == _pageSize;
}
