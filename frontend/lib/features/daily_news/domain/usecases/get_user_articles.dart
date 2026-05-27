import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/stream_usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class GetUserArticlesUseCase
    implements StreamUseCase<DataState<List<ArticleEntity>>, String> {
  final ArticleRepository _articleRepository;

  GetUserArticlesUseCase(this._articleRepository);

  @override
  Stream<DataState<List<ArticleEntity>>> call({String? params}) {
    if (params == null) throw ArgumentError('params cannot be null');
    return _articleRepository.getUserArticles(params);
  }
}
