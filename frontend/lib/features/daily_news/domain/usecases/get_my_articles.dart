import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class GetMyArticlesParams {
  final String authorId;

  GetMyArticlesParams(this.authorId);
}

class GetMyArticlesUseCase
    implements UseCase<DataState<List<ArticleEntity>>, GetMyArticlesParams> {
  final ArticleRepository _articleRepository;

  GetMyArticlesUseCase(this._articleRepository);

  @override
  Future<DataState<List<ArticleEntity>>> call({
    GetMyArticlesParams? params,
  }) {
    return _articleRepository.getArticlesByAuthor(params!.authorId);
  }
}

