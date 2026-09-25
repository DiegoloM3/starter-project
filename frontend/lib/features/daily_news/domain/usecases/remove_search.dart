import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/search_history_repository.dart';

class RemoveSearchUseCase implements UseCase<void, String> {
  final SearchHistoryRepository _repository;

  RemoveSearchUseCase(this._repository);

  @override
  Future<void> call({String? params}) async {
    if (params == null) return;
    await _repository.removeSearch(params);
  }
}
