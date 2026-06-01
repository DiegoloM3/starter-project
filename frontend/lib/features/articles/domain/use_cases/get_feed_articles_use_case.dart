import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/articles/domain/repository/article_repository.dart';

class GetFeedArticlesUseCase
    implements UseCase<DataState<List<ArticleEntity>>, List<String>> {
  final ArticleRepository _repository;
  GetFeedArticlesUseCase(this._repository);

  @override
  Future<DataState<List<ArticleEntity>>> call(List<String> params) {
    return _repository.getFeedArticles(params);
  }
}
