import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/news/domain/entities/article.entity.dart';
import 'package:news_app_clean_architecture/features/news/domain/repository/user_article_repository.dart';

/// Single operation: returns every user-created article, newest first.
class GetAllUserArticles
    implements UseCase<DataState<List<ArticleEntity>>, void> {
  final UserArticleRepository _userArticleRepository;

  GetAllUserArticles(this._userArticleRepository);

  @override
  Future<DataState<List<ArticleEntity>>> call({void params}) async {
    return await _userArticleRepository.getAllUserArticles();
  }
}
