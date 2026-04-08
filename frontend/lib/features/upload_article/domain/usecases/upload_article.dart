import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/entities/upload_article.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/repository/upload_article_repository.dart';

class UploadArticleUseCase
    implements UseCase<DataState<ArticleEntity>, UploadArticleEntity> {
  final UploadArticleRepository _uploadArticleRepository;

  UploadArticleUseCase(this._uploadArticleRepository);

  @override
  Future<DataState<ArticleEntity>> call({UploadArticleEntity? params}) {
    if (params == null) {
      throw ArgumentError('UploadArticleEntity params cannot be null');
    }

    return _uploadArticleRepository.uploadArticle(params);
  }
}
