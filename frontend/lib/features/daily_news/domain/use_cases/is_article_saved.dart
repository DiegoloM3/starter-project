import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class IsArticleSavedUseCase implements UseCase<bool, ArticleEntity> {
  final ArticleRepository _repository;

  IsArticleSavedUseCase(this._repository);

  @override
  Future<bool> call({ArticleEntity? params}) {
    assert(params != null, 'ArticleEntity must not be null');
    return _repository.isArticleSaved(params!);
  }
}
