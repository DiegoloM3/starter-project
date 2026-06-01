import 'package:equatable/equatable.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/articles/domain/repository/article_repository.dart';

class GetFeedArticlesPagedParams extends Equatable {
  final List<String> categoryIds;
  final int page;
  final int pageSize;

  const GetFeedArticlesPagedParams({
    required this.categoryIds,
    required this.page,
    required this.pageSize,
  });

  @override
  List<Object?> get props => [categoryIds, page, pageSize];
}

class GetFeedArticlesPagedUseCase
    implements UseCase<DataState<List<ArticleEntity>>, GetFeedArticlesPagedParams> {
  final ArticleRepository _repository;

  GetFeedArticlesPagedUseCase(this._repository);

  @override
  Future<DataState<List<ArticleEntity>>> call(GetFeedArticlesPagedParams params) {
    return _repository.getFeedArticlesPaged(
      params.categoryIds,
      params.page,
      params.pageSize,
    );
  }
}
