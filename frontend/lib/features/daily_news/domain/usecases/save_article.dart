import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/local_article_repository.dart';

class SaveArticleUseCase
    implements UseCase<DataState<bool>, ArticleEntity> {
  final LocalArticleRepository _repository;

  SaveArticleUseCase(this._repository);

  @override
  Future<DataState<bool>> call({ArticleEntity? params}) {
    return _repository.saveArticle(params!);
  }
}
