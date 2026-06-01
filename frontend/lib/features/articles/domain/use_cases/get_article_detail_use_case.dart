import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/articles/domain/repository/article_repository.dart';

class GetArticleDetailUseCase
    implements UseCase<DataState<ArticleEntity>, String> {
  final ArticleRepository _repository;
  GetArticleDetailUseCase(this._repository);

  @override
  Future<DataState<ArticleEntity>> call(String params) {
    return _repository.getArticleDetail(params);
  }
}
