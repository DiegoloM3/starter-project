import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../entities/journalist_article.dart';
import '../entities/journalist_stats.dart';
import '../params/get_my_articles_params.dart';
import '../repository/journalist_article_repository.dart';

/// Summarises what one journalist has written.
///
/// It reads the same articles "My articles" lists rather than a stored
/// counter, so the two can never disagree. The counting itself belongs to
/// [JournalistStatsEntity]; this use case only fetches what is counted.
class GetJournalistStatsUseCase
    implements UseCase<DataState<JournalistStatsEntity>, GetMyArticlesParams> {
  final JournalistArticleRepository _articleRepository;

  const GetJournalistStatsUseCase(this._articleRepository);

  @override
  Future<DataState<JournalistStatsEntity>> call(
    GetMyArticlesParams params,
  ) async {
    final result = await _articleRepository.getUserArticles(
      userId: params.userId,
    );

    if (result is DataSuccess<List<JournalistArticleEntity>>) {
      return DataSuccess(
        JournalistStatsEntity.of(
          result.data ?? const <JournalistArticleEntity>[],
        ),
      );
    }

    return DataFailed(
      result.error ?? Exception('The article summary could not be read.'),
    );
  }
}
