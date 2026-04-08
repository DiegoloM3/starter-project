import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/repository/upload_article_repository.dart';

class GetMyUploadedArticlesUseCase
    implements UseCase<DataState<List<ArticleEntity>>, void> {
  final UploadArticleRepository _uploadArticleRepository;

  GetMyUploadedArticlesUseCase(this._uploadArticleRepository);

  @override
  Future<DataState<List<ArticleEntity>>> call({void params}) {
    return _uploadArticleRepository.getMyUploadedArticles();
  }
}
