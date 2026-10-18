import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/reading_history_repository.dart';

/// Records that the signed in user viewed the article, keeping only the most recent views.
class RecordArticleViewUseCase implements UseCase<DataState<void>, String> {
  final ReadingHistoryRepository _readingHistoryRepository;

  RecordArticleViewUseCase(this._readingHistoryRepository);

  @override
  Future<DataState<void>> call(String articleId) async {
    final result = await _readingHistoryRepository.recordView(articleId);
    if (result is DataFailed) return result;
    return _readingHistoryRepository.deleteViewsBeyond(ReadingHistoryLimits.maxEntries);
  }
}
