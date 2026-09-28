import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_entity.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/search/get_search_history_usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/search/remove_search_term_usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/search/save_search_term_usecase.dart';

part 'article_search_event.dart';
part 'article_search_state.dart';


class ArticleSearchBloc extends Bloc<ArticleSearchEvent, ArticleSearchState> {
  final List<ArticleEntity> _allArticles;
  final GetSearchHistoryUseCase _getSearchHistoryUseCase;
  final SaveSearchTermUseCase _saveSearchTermUseCase;
  final RemoveSearchTermUseCase _removeSearchTermUseCase;

  ArticleSearchBloc({
    required List<ArticleEntity> articles,
    required GetSearchHistoryUseCase getSearchHistoryUseCase,
    required SaveSearchTermUseCase saveSearchTermUseCase,
    required RemoveSearchTermUseCase removeSearchTermUseCase,
  })  : _allArticles = articles,
        _getSearchHistoryUseCase = getSearchHistoryUseCase,
        _saveSearchTermUseCase = saveSearchTermUseCase,
        _removeSearchTermUseCase = removeSearchTermUseCase,
        super(const ArticleSearchShowingHistory(history: [])) {
    on<LoadSearchHistory>(_onLoadSearchHistory);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<SearchSubmitted>(_onSearchSubmitted);
    on<RemoveSearchHistoryItem>(_onRemoveSearchHistoryItem);
  }

  Future<void> _onLoadSearchHistory(LoadSearchHistory event, Emitter<ArticleSearchState> emit) async {
    final history = await _getSearchHistoryUseCase();
    emit(ArticleSearchShowingHistory(history: history));
  }

  void _onSearchQueryChanged(SearchQueryChanged event, Emitter<ArticleSearchState> emit) {
    if (event.query.isEmpty) {
      add(const LoadSearchHistory());
      return;
    }
    emit(ArticleSearchShowingResults(query: event.query, results: _filterArticles(event.query)));
  }

  Future<void> _onSearchSubmitted(SearchSubmitted event, Emitter<ArticleSearchState> emit) async {
    if (event.query.trim().isEmpty) return;
    await _saveSearchTermUseCase(params: event.query.trim());
    emit(ArticleSearchShowingResults(query: event.query, results: _filterArticles(event.query)));
  }

  Future<void> _onRemoveSearchHistoryItem(RemoveSearchHistoryItem event, Emitter<ArticleSearchState> emit) async {
    await _removeSearchTermUseCase(params: event.term);
    final history = await _getSearchHistoryUseCase();
    emit(ArticleSearchShowingHistory(history: history));
  }

  List<ArticleEntity> _filterArticles(String query) {
  final lowerQuery = query.toLowerCase();
  
  return _allArticles.where((article) {
    final title = article.title?.toLowerCase() ?? '';
    final description = article.description?.toLowerCase() ?? '';
    return title.contains(lowerQuery) || description.contains(lowerQuery);
  }).toList();
}
}