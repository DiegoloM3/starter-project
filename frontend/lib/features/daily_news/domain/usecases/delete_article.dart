import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/firestore_article_repository.dart';

class DeleteArticleUseCase implements UseCase<DataState<bool>, String> {
  final FirestoreArticleRepository _repository;

  DeleteArticleUseCase(this._repository);

  @override
  Future<DataState<bool>> call({String? params}) {
    return _repository.deleteArticle(params!);
  }
}
