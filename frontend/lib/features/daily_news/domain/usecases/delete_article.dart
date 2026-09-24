import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_upload_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class DeleteArticleUseCase
    implements UseCase<DataState<void>, DeleteArticleParams> {
  final ArticleRepository _repository;

  DeleteArticleUseCase(this._repository);

  @override
  Future<DataState<void>> call({DeleteArticleParams? params}) async {
    if (params == null) {
      throw Exception('Params cannot be null');
    }
    return await _repository.deleteArticle(params);
  }
}
