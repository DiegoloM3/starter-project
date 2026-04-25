import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/domain/repository/firebase_article_repository.dart';

class DeleteFirebaseArticleUseCase implements UseCase<void, String> {
  final FirebaseArticleRepository _repository;

  DeleteFirebaseArticleUseCase(this._repository);

  @override
  Future<void> call({String? params}) {
    return _repository.deleteArticle(params!);
  }
}
