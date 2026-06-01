import 'package:equatable/equatable.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/profile/domain/repository/profile_repository.dart';

class GetSavedArticlesParams extends Equatable {
  final String userId;
  final int limit;

  const GetSavedArticlesParams({required this.userId, required this.limit});

  @override
  List<Object?> get props => [userId, limit];
}

class GetSavedArticlesUseCase
    implements UseCase<DataState<List<ArticleEntity>>, GetSavedArticlesParams> {
  final ProfileRepository _repository;

  GetSavedArticlesUseCase(this._repository);

  @override
  Future<DataState<List<ArticleEntity>>> call(
    GetSavedArticlesParams params,
  ) {
    return _repository.getSavedArticles(params.userId, params.limit);
  }
}
