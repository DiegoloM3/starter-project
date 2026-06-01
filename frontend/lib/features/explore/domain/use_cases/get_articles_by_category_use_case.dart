import 'package:equatable/equatable.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/explore/domain/repository/explore_repository.dart';

class GetArticlesByCategoryParams extends Equatable {
  final String categoryId;
  final int page;
  final int pageSize;

  const GetArticlesByCategoryParams({
    required this.categoryId,
    this.page = 0,
    this.pageSize = 10,
  });

  @override
  List<Object?> get props => [categoryId, page, pageSize];
}

class GetArticlesByCategoryUseCase
    implements
        UseCase<DataState<List<ArticleEntity>>, GetArticlesByCategoryParams> {
  final ExploreRepository _repository;

  GetArticlesByCategoryUseCase(this._repository);

  @override
  Future<DataState<List<ArticleEntity>>> call(
      GetArticlesByCategoryParams params) {
    return _repository.getArticlesByCategory(
      params.categoryId,
      params.page,
      params.pageSize,
    );
  }
}
