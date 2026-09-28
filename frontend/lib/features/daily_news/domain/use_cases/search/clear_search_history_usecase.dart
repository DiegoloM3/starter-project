

import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/search_history_repository.dart';

class ClearSearchHistoryUseCase implements UseCase<void, void> {
  final SearchHistoryRepository _repository;
  ClearSearchHistoryUseCase({required SearchHistoryRepository repository}) : _repository = repository;

  @override
  Future<void> call({void params}) => _repository.clearHistory();
}