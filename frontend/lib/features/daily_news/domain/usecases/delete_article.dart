import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class DeleteArticleUseCase implements UseCase<DataState<void>, String> {
  final ArticleRepository _articleRepository;

  DeleteArticleUseCase(this._articleRepository);

  @override
  Future<DataState<void>> call({String? params}) {
    if (params == null) throw ArgumentError('params cannot be null');
    return _articleRepository.deleteArticle(params);
  }
}
