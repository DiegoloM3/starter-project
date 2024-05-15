import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class GetArticlesFromFirestoreUseCase implements UseCase<DataState<List<ArticleEntity>>, void> {
  final ArticleRepository _articleRepository;

  GetArticlesFromFirestoreUseCase(this._articleRepository);

  @override
  Future<DataState<List<ArticleEntity>>> call({void params}) {
    return _articleRepository.getArticlesFromFirestore();
  }
}