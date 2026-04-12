import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/usecases/delete_article.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/usecases/get_all_articles.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/usecases/load_next_page.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/usecases/sync_articles.dart';
import 'package:news_app_clean_architecture/features/articles_upload/presentation/bloc/articles_list/articles_list_event.dart';
import 'package:news_app_clean_architecture/features/articles_upload/presentation/bloc/articles_list/articles_list_state.dart';

class ArticlesListBloc extends Bloc<ArticlesListEvent, ArticlesListState> {
  final GetAllArticlesUseCase _getAllArticles;
  final DeleteArticleUseCase _deleteArticle;
  final SyncArticlesUseCase? _syncArticles;
  final LoadNextPageUseCase? _loadNextPage;
  final int _pageSize;

  ArticlesListBloc(
    this._getAllArticles,
    this._deleteArticle, {
    SyncArticlesUseCase? syncArticles,
    LoadNextPageUseCase? loadNextPage,
    int pageSize = 20,
  })  : _syncArticles = syncArticles,
        _loadNextPage = loadNextPage,
        _pageSize = pageSize,
        super(const ArticlesListInitial()) {
    on<FetchArticles>(_onFetch);
    on<DeleteArticleRequested>(_onDelete);
    on<SearchQueryChanged>(_onSearchChanged);
    on<LoadMoreArticles>(_onLoadMore);
  }

  Future<void> _onFetch(
    FetchArticles event,
    Emitter<ArticlesListState> emit,
  ) async {
    final previousQuery =
        state is ArticlesListLoaded ? (state as ArticlesListLoaded).query : '';
    emit(const ArticlesListLoading());

    final cacheResult = await _getAllArticles();
    if (cacheResult is DataSuccess && cacheResult.data != null) {
      emit(ArticlesListLoaded(
        cacheResult.data!,
        query: previousQuery,
        hasMore: cacheResult.data!.length >= _pageSize,
      ));
    }

    if (_syncArticles != null) {
      final remoteResult = await _syncArticles();
      if (remoteResult is DataSuccess && remoteResult.data != null) {
        emit(ArticlesListLoaded(
          remoteResult.data!,
          query: previousQuery,
          hasMore: remoteResult.data!.length >= _pageSize,
        ));
      } else if (cacheResult is! DataSuccess) {
        emit(ArticlesListError(
          _errorMessage(remoteResult.error),
        ));
      }
    } else if (cacheResult is! DataSuccess) {
      emit(ArticlesListError(
        _errorMessage(cacheResult.error),
      ));
    }
  }

  Future<void> _onDelete(
    DeleteArticleRequested event,
    Emitter<ArticlesListState> emit,
  ) async {
    final result = await _deleteArticle(params: event.articleId);
    if (result is DataSuccess) {
      add(const FetchArticles());
    } else {
      emit(ArticlesListError(_errorMessage(result.error)));
    }
  }

  void _onSearchChanged(
    SearchQueryChanged event,
    Emitter<ArticlesListState> emit,
  ) {
    final current = state;
    if (current is ArticlesListLoaded) {
      emit(current.copyWith(query: event.query));
    }
  }

  Future<void> _onLoadMore(
    LoadMoreArticles event,
    Emitter<ArticlesListState> emit,
  ) async {
    final current = state;
    if (current is! ArticlesListLoaded || !current.hasMore) return;
    if (current.allArticles.isEmpty || _loadNextPage == null) return;

    final lastDate = current.allArticles.last.publishedAt;
    final result = await _loadNextPage(params: lastDate);
    if (result is DataSuccess && result.data != null) {
      final merged = [...current.allArticles, ...result.data!];
      emit(current.copyWith(
        allArticles: merged,
        hasMore: result.data!.length >= _pageSize,
      ));
    }
  }

  String _errorMessage(Object? error) {
    if (error == null) return 'Unknown error';
    return error.toString();
  }
}
