import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/articles/domain/params/update_article_params.dart';
import 'package:tortutip/features/articles/domain/repository/article_repository.dart';

class UpdateArticleUseCase
    implements UseCase<DataState<ArticleEntity>, UpdateArticleParams> {
  final ArticleRepository _repository;

  UpdateArticleUseCase(this._repository);

  @override
  Future<DataState<ArticleEntity>> call(UpdateArticleParams params) =>
      _repository.updateArticle(params);
}
