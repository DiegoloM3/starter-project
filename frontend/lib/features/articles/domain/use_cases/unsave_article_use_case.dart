import 'package:equatable/equatable.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/articles/domain/repository/article_repository.dart';

class UnsaveArticleParams extends Equatable {
  final String userId;
  final String articleId;

  const UnsaveArticleParams({required this.userId, required this.articleId});

  @override
  List<Object?> get props => [userId, articleId];
}

class UnsaveArticleUseCase
    implements UseCase<DataState<bool>, UnsaveArticleParams> {
  final ArticleRepository _repository;

  UnsaveArticleUseCase(this._repository);

  @override
  Future<DataState<bool>> call(UnsaveArticleParams params) {
    return _repository.unsaveArticle(params.userId, params.articleId);
  }
}
