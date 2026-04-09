import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/create_article_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class CreateArticleUseCase
    implements UseCase<DataState<void>, CreateArticleParams> {
  final ArticleRepository _articleRepository;

  CreateArticleUseCase(this._articleRepository);

  @override
  Future<DataState<void>> call(CreateArticleParams params) async =>
      _articleRepository.createArticle(
        article: params.article,
        image: params.file,
      );
}
