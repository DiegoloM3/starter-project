import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/user_article_repository.dart';

/// Articles written by the signed-in journalist.
class GetMyArticlesUseCase
    implements UseCase<DataState<List<ArticleEntity>>, NoParams> {
  final UserArticleRepository _userArticleRepository;
  final AuthRepository _authRepository;

  const GetMyArticlesUseCase(this._userArticleRepository, this._authRepository);

  @override
  Future<DataState<List<ArticleEntity>>> call(NoParams params) {
    final user = _authRepository.currentUser;
    if (user == null) {
      return Future.value(const DataFailed(Failure.unauthenticated()));
    }
    return _userArticleRepository.getArticlesByAuthor(user.id);
  }
}
