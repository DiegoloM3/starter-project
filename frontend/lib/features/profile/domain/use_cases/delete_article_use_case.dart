import 'package:equatable/equatable.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/profile/domain/repository/profile_repository.dart';

class DeleteArticleParams extends Equatable {
  final String articleId;
  final String userId;

  const DeleteArticleParams({required this.articleId, required this.userId});

  @override
  List<Object?> get props => [articleId, userId];
}

class DeleteArticleUseCase
    implements UseCase<DataState<bool>, DeleteArticleParams> {
  final ProfileRepository _repository;

  DeleteArticleUseCase(this._repository);

  @override
  Future<DataState<bool>> call(DeleteArticleParams params) {
    return _repository.deleteArticle(params.articleId, params.userId);
  }
}
