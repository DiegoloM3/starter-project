import 'package:injectable/injectable.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';

@module
abstract class DailyNewsModule {
  @lazySingleton
  GetArticleUseCase getArticleUseCase(ArticleRepository repository) {
    return GetArticleUseCase(repository);
  }
}
