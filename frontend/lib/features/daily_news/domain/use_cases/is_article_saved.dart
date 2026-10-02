import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class IsArticleSavedUseCase implements UseCase<DataState<bool>, ArticleEntity> {
  final ArticleRepository _articleRepository;

  IsArticleSavedUseCase(this._articleRepository);

  @override
  Future<DataState<bool>> call({ArticleEntity? params}) => _articleRepository.isArticleSaved(params!);
}
