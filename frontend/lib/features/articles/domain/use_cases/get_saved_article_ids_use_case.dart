import 'package:equatable/equatable.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/articles/domain/repository/article_repository.dart';

class GetSavedArticleIdsParams extends Equatable {
  final String userId;

  const GetSavedArticleIdsParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class GetSavedArticleIdsUseCase
    implements UseCase<DataState<List<String>>, GetSavedArticleIdsParams> {
  final ArticleRepository _repository;

  GetSavedArticleIdsUseCase(this._repository);

  @override
  Future<DataState<List<String>>> call(GetSavedArticleIdsParams params) {
    return _repository.getSavedArticleIds(params.userId);
  }
}
