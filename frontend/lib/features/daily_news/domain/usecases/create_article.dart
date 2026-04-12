import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/firestore_article_repository.dart';

class CreateArticleParams {
  final ArticleEntity article;
  final List<String> imagePaths;

  const CreateArticleParams({
    required this.article,
    required this.imagePaths,
  });
}

class CreateArticleUseCase
    implements UseCase<DataState<ArticleEntity>, CreateArticleParams> {
  final FirestoreArticleRepository _repository;

  CreateArticleUseCase(this._repository);

  @override
  Future<DataState<ArticleEntity>> call({CreateArticleParams? params}) {
    return _repository.createArticle(
      params!.article,
      params.imagePaths,
    );
  }
}
