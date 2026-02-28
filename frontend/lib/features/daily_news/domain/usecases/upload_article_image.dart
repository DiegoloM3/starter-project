import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class UploadArticleImageParams {
  final String authorId;
  final String localPath;

  UploadArticleImageParams({
    required this.authorId,
    required this.localPath,
  });
}

class UploadArticleImageUseCase
    implements UseCase<String, UploadArticleImageParams> {
  final ArticleRepository _articleRepository;

  UploadArticleImageUseCase(this._articleRepository);

  @override
  Future<String> call({UploadArticleImageParams? params}) {
    final p = params!;
    return _articleRepository.uploadArticleImage(
      authorId: p.authorId,
      localPath: p.localPath,
    );
  }
}
