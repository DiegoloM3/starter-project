import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/domain/entities/generated_article.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/domain/repository/firebase_article_repository.dart';

class GenerateArticleContentUseCase
    implements UseCase<GeneratedArticle, String> {
  final FirebaseArticleRepository _repository;

  GenerateArticleContentUseCase(this._repository);

  @override
  Future<GeneratedArticle> call({String? params}) {
    return _repository.generateArticleContent(params!);
  }
}
