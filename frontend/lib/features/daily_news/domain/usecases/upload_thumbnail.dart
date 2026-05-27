import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class UploadThumbnailParams {
  final String articleId;
  final String filePath;

  const UploadThumbnailParams({
    required this.articleId,
    required this.filePath,
  });
}

class UploadThumbnailUseCase implements UseCase<DataState<String>, UploadThumbnailParams> {
  final ArticleRepository _articleRepository;

  UploadThumbnailUseCase(this._articleRepository);

  @override
  Future<DataState<String>> call({UploadThumbnailParams? params}) {
    if (params == null) throw ArgumentError('params cannot be null');
    return _articleRepository.uploadThumbnail(
      articleId: params.articleId,
      filePath: params.filePath,
    );
  }
}
