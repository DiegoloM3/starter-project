import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_entity.dart';
import 'package:news_app_clean_architecture/features/articles/domain/repositories/article_repository.dart';

class GetArticlesParams {
  final String? category;

  const GetArticlesParams({this.category});
}

class GetArticlesUseCase
    implements UseCase<DataState<List<ArticleEntity>>, GetArticlesParams> {
  final ArticleRepository _articleRepository;

  GetArticlesUseCase(this._articleRepository);

  @override
  Future<DataState<List<ArticleEntity>>> call({GetArticlesParams? params}) {
    return _articleRepository.getArticles(category: params?.category);
  }
}
