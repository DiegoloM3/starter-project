import 'package:equatable/equatable.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/profile/domain/repository/profile_repository.dart';

class GetPublishedArticlesParams extends Equatable {
  final String authorId;
  final int limit;

  const GetPublishedArticlesParams({
    required this.authorId,
    required this.limit,
  });

  @override
  List<Object?> get props => [authorId, limit];
}

class GetPublishedArticlesUseCase
    implements
        UseCase<DataState<List<ArticleEntity>>, GetPublishedArticlesParams> {
  final ProfileRepository _repository;

  GetPublishedArticlesUseCase(this._repository);

  @override
  Future<DataState<List<ArticleEntity>>> call(
    GetPublishedArticlesParams params,
  ) {
    return _repository.getPublishedArticles(params.authorId, params.limit);
  }
}
