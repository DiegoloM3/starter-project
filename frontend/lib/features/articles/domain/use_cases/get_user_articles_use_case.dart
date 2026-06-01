import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/articles/domain/repository/article_repository.dart';

class GetUserArticlesUseCase
    implements UseCase<DataState<List<ArticleEntity>>, String> {
  final ArticleRepository _repository;
  GetUserArticlesUseCase(this._repository);

  @override
  Future<DataState<List<ArticleEntity>>> call(String params) {
    return _repository.getUserArticles(params);
  }
}
