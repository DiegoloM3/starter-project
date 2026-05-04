import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/page_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class GetFitnessArticlesUseCase
    implements UseCase<DataState<List<ArticleEntity>>, PageParams> {
  final ArticleRepository _articleRepository;

  GetFitnessArticlesUseCase(this._articleRepository);

  @override
  Future<DataState<List<ArticleEntity>>> call({PageParams? params}) {
    return _articleRepository.getFitnessNewsArticles(
      params: params ?? const PageParams(),
    );
  }
}
