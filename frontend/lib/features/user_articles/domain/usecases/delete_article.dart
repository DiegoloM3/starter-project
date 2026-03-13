import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/repository/user_article_repository.dart';

/// Use case for deleting an article.
class DeleteArticleUseCase implements UseCase<DataState<void>, String> {
  final UserArticleRepository _userArticleRepository;

  DeleteArticleUseCase(this._userArticleRepository);

  @override
  Future<DataState<void>> call({String? params}) async {
    if (params == null || params.isEmpty) {
      return DataFailed(Exception('Article ID cannot be null or empty'));
    }
    return await _userArticleRepository.deleteArticle(params);
  }
}
