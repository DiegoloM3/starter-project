import 'package:equatable/equatable.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/articles/domain/repository/article_repository.dart';

class SaveArticleParams extends Equatable {
  final String userId;
  final String articleId;

  const SaveArticleParams({required this.userId, required this.articleId});

  @override
  List<Object?> get props => [userId, articleId];
}

class SaveArticleUseCase implements UseCase<DataState<bool>, SaveArticleParams> {
  final ArticleRepository _repository;
  SaveArticleUseCase(this._repository);

  @override
  Future<DataState<bool>> call(SaveArticleParams params) {
    return _repository.saveArticle(params.userId, params.articleId);
  }
}
