import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_upload_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class UploadArticleUseCase
    implements UseCase<DataState<ArticleEntity>, CreateArticleParams> {
  final ArticleRepository _repository;

  UploadArticleUseCase(this._repository);

  @override
  Future<DataState<ArticleEntity>> call({CreateArticleParams? params}) async {
    if (params == null) {
      throw Exception('Params cannot be null');
    }
    return await _validateAndUpload(params);
  }

  Future<DataState<ArticleEntity>> _validateAndUpload(
    CreateArticleParams params,
  ) async {
    final validation = _validate(params);
    if (validation != null) {
      throw Exception(validation);
    }

    return await _repository.uploadArticle(params);
  }

  String? _validate(CreateArticleParams params) {
    if (!_isValidTitle(params.title)) {
      return 'Title must be between 5 and 200 characters';
    }

    if (!_isValidContent(params.content)) {
      return 'Content must be at least 20 characters';
    }

    if (!_isValidAuthor(params.author)) {
      return 'Author must be between 2 and 100 characters';
    }

    return null;
  }

  bool _isValidTitle(String title) {
    return title.isNotEmpty && title.length >= 5 && title.length <= 200;
  }

  bool _isValidContent(String content) {
    return content.isNotEmpty && content.length >= 20;
  }

  bool _isValidAuthor(String author) {
    return author.isNotEmpty && author.length >= 2 && author.length <= 100;
  }
}
