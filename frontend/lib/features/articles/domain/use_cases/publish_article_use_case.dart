import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/articles/domain/params/publish_article_params.dart';
import 'package:tortutip/features/articles/domain/repository/article_repository.dart';

class PublishArticleUseCase
    implements UseCase<DataState<ArticleEntity>, PublishArticleParams> {
  final ArticleRepository _repository;
  PublishArticleUseCase(this._repository);

  @override
  Future<DataState<ArticleEntity>> call(PublishArticleParams params) {
    return _repository.publishArticle(params);
  }
}
