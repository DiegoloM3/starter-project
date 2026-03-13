import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/repository/user_article_repository.dart';

/// Use case for getting articles filtered by category.
class GetArticlesByCategoryUseCase
    implements UseCase<DataState<List<UserArticleEntity>>, String> {
  final UserArticleRepository _userArticleRepository;

  GetArticlesByCategoryUseCase(this._userArticleRepository);

  @override
  Future<DataState<List<UserArticleEntity>>> call({String? params}) async {
    if (params == null || params.isEmpty) {
      return DataFailed(Exception('Category cannot be null or empty'));
    }
    return await _userArticleRepository.getArticlesByCategory(params);
  }
}
