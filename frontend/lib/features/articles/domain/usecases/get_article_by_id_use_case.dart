import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_entity.dart';
import 'package:news_app_clean_architecture/features/articles/domain/repositories/article_repository.dart';

class GetArticleByIdParams {
  final String id;

  const GetArticleByIdParams({required this.id});
}

class GetArticleByIdUseCase
    implements UseCase<DataState<ArticleEntity>, GetArticleByIdParams> {
  final ArticleRepository _articleRepository;

  GetArticleByIdUseCase(this._articleRepository);

  @override
  Future<DataState<ArticleEntity>> call({GetArticleByIdParams? params}) {
    return _articleRepository.getArticleById(params!.id);
  }
}
