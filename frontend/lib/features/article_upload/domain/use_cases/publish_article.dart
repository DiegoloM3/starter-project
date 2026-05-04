import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/repository/article_upload_repository.dart';

class PublishArticleUseCase
    extends UseCase<DataState<JournalistArticleEntity>, PublishArticleParams> {
  final ArticleUploadRepository _repository;

  PublishArticleUseCase(this._repository);

  @override
  Future<DataState<JournalistArticleEntity>> call(
      {PublishArticleParams? params}) {
    assert(params != null, 'PublishArticleParams must not be null');
    return _repository.publish(params!);
  }
}
