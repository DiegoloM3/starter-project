import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/page.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/page_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class GetArticlesUseCase
    implements UseCase<DataState<PageEntity<ArticleEntity>>, PageParams> {
  final ArticleRepository _articleRepository;

  GetArticlesUseCase(this._articleRepository);

  @override
  Future<DataState<PageEntity<ArticleEntity>>> call(PageParams params) async =>
      _articleRepository.getNewsArticles(
        page: params.page,
        size: params.size,
        total: params.total,
      );
}
