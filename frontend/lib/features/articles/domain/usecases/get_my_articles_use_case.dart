import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_entity.dart';
import 'package:news_app_clean_architecture/features/articles/domain/repositories/article_repository.dart';

class GetMyArticlesParams {
  final String authorId;
  final String? status;

  const GetMyArticlesParams({required this.authorId, this.status});
}

class GetMyArticlesUseCase
    implements UseCase<DataState<List<ArticleEntity>>, GetMyArticlesParams> {
  final ArticleRepository _articleRepository;

  GetMyArticlesUseCase(this._articleRepository);

  @override
  Future<DataState<List<ArticleEntity>>> call({GetMyArticlesParams? params}) {
    return _articleRepository.getMyArticles(
      params!.authorId,
      status: params.status,
    );
  }
}
