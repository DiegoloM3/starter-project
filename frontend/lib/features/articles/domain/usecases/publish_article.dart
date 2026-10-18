import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/article.dart';
import '../exceptions/article_exceptions.dart';
import '../params/publish_article_params.dart';
import 'mock/mock_articles.dart';

class PublishArticleUseCase implements UseCase<DataState<ArticleEntity>, PublishArticleParams> {
  @override
  Future<DataState<ArticleEntity>> call(PublishArticleParams params) async {
    final errors = params.validationErrors;
    if (errors.isNotEmpty) return DataFailed(ArticleValidationException(errors));

    await Future.delayed(mockNetworkDelay);
    return DataSuccess(_buildPublishedArticle(params));
  }

  ArticleEntity _buildPublishedArticle(PublishArticleParams params) {
    final now = DateTime.now();
    return ArticleEntity(
      id: 'mock-article-${now.microsecondsSinceEpoch}',
      title: params.draft.title,
      description: params.draft.description,
      content: params.draft.content,
      thumbnailURL: mockImageURL,
      topics: params.draft.topics.toList(),
      publishedAt: now,
      authorId: mockJournalistId,
      authorName: mockJournalistName,
    );
  }
}
