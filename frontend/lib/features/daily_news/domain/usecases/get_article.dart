import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/remote_news_repository.dart';

class GetArticleUseCase
    implements UseCase<DataState<List<ArticleEntity>>, int> {
  final RemoteNewsRepository _repository;

  GetArticleUseCase(this._repository);

  @override
  Future<DataState<List<ArticleEntity>>> call({int? params}) {
    return _repository.getNewsArticles(page: params ?? 1);
  }
}
