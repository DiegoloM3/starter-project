import 'package:equatable/equatable.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/articles/domain/repository/article_repository.dart';

class GetRelatedArticlesParams extends Equatable {
  final String categoryId;
  final String excludeArticleId;

  const GetRelatedArticlesParams({
    required this.categoryId,
    required this.excludeArticleId,
  });

  @override
  List<Object?> get props => [categoryId, excludeArticleId];
}

class GetRelatedArticlesUseCase
    implements UseCase<DataState<List<ArticleEntity>>, GetRelatedArticlesParams> {
  final ArticleRepository _repository;
  GetRelatedArticlesUseCase(this._repository);

  @override
  Future<DataState<List<ArticleEntity>>> call(GetRelatedArticlesParams params) {
    return _repository.getRelatedArticles(
        params.categoryId, params.excludeArticleId);
  }
}
