import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/article.dart';
import '../repository/reading_history_repository.dart';

/// The most recently viewed articles, newest first.
class GetReadingHistoryUseCase implements UseCase<DataState<List<ArticleEntity>>, NoParams> {
  final ReadingHistoryRepository _readingHistoryRepository;

  GetReadingHistoryUseCase(this._readingHistoryRepository);

  @override
  Future<DataState<List<ArticleEntity>>> call(NoParams params) {
    return _readingHistoryRepository.getRecentlyViewed(ReadingHistoryLimits.maxEntries);
  }
}
