import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

/// The headlines of one section.
class GetArticlesUseCase
    implements UseCase<DataState<List<ArticleEntity>>, NewsCategory> {
  final ArticleRepository _articleRepository;

  const GetArticlesUseCase(this._articleRepository);

  @override
  Future<DataState<List<ArticleEntity>>> call(NewsCategory category) {
    return _articleRepository.getNewsArticles(category: category);
  }
}
