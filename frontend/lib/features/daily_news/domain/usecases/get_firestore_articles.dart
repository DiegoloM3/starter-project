import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/firestore_article_repository.dart';

class GetFirestoreArticlesUseCase
    implements UseCase<DataState<List<ArticleEntity>>, void> {
  final FirestoreArticleRepository _repository;

  GetFirestoreArticlesUseCase(this._repository);

  @override
  Future<DataState<List<ArticleEntity>>> call({void params}) {
    return _repository.getFirestoreArticles();
  }
}
