import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/search_history_repository.dart';

class SaveSearchUseCase implements UseCase<void, String> {
  final SearchHistoryRepository _repository;

  SaveSearchUseCase(this._repository);

  @override
  Future<void> call({String? params}) async {
    final text = params?.trim() ?? '';
    if (text.isEmpty) return;
    await _repository.saveSearch(text);
  }
}
