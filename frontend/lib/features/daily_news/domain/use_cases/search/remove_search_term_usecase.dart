import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/search_history_repository.dart';

class RemoveSearchTermUseCase implements UseCase<void, String> {
  final SearchHistoryRepository _repository;
  RemoveSearchTermUseCase({required SearchHistoryRepository repository}) : _repository = repository;

  @override
  Future<void> call({String? params}) => _repository.removeTerm(params!);
}