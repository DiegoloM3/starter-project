import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/recommendations/domain/repository/recommendation_repository.dart';

class RecommendForUserUseCase
    implements UseCase<DataState<List<ArticleEntity>>, int> {
  final RecommendationRepository _repository;

  RecommendForUserUseCase(this._repository);

  @override
  Future<DataState<List<ArticleEntity>>> call({int? params}) {
    return _repository.recommendForUser(limit: params ?? 20);
  }
}
