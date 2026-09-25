import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/search_history_entity.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/search_history_repository.dart';

class GetRecentSearchesUseCase
    implements UseCase<List<SearchHistoryEntity>, void> {
  final SearchHistoryRepository _repository;

  GetRecentSearchesUseCase(this._repository);

  @override
  Future<List<SearchHistoryEntity>> call({void params}) {
    return _repository.getRecentSearches();
  }
}
