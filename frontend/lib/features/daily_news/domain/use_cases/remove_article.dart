import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

/// Drops one article from the kept ones.
class RemoveArticleUseCase implements UseCase<DataState<void>, ArticleEntity> {
  final ArticleRepository _articleRepository;

  const RemoveArticleUseCase(this._articleRepository);

  @override
  Future<DataState<void>> call(ArticleEntity article) {
    return _articleRepository.removeArticle(article);
  }
}
