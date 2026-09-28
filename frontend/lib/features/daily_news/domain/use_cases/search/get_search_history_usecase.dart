

import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/search_history_repository.dart';

class GetSearchHistoryUseCase implements UseCase<List<String>, void> {
  final SearchHistoryRepository _repository;
  GetSearchHistoryUseCase({required SearchHistoryRepository repository}) : _repository = repository;

  @override
  Future<List<String>> call({void params}) => _repository.getHistory();
}