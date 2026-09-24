import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../entities/article_failures.dart';
import '../params/update_articles_byline_params.dart';
import '../repository/journalist_article_repository.dart';

/// Rewrites the byline on everything a journalist has already written.
///
/// Changing the name on the account used to apply only to the next article:
/// the byline is copied onto each one when it is saved, so everything already
/// published kept the name it was written under. That is defensible for a
/// pen name deliberately retired, and wrong for the far commoner case — a
/// name typed in a hurry at sign-up, or simply corrected. A journalist who
/// changes the name readers see means the name readers see.
///
/// Only the byline moves. The publication date, the view count and
/// `updatedAt` are left alone: being renamed is not an edit, so it must not
/// reorder the public feed or claim the article was revised.
class UpdateArticlesBylineUseCase
    implements UseCase<DataState<int>, UpdateArticlesBylineParams> {
  final JournalistArticleRepository _articleRepository;

  const UpdateArticlesBylineUseCase(this._articleRepository);

  @override
  Future<DataState<int>> call(UpdateArticlesBylineParams params) async {
    if (params.authorName.trim().isEmpty) {
      return const DataFailed(
        ArticleValidationException([ArticleValidationError.authorRequired]),
      );
    }
    if (params.userId.trim().isEmpty) {
      return const DataFailed(
        ArticleValidationException([ArticleValidationError.userRequired]),
      );
    }

    return _articleRepository.updateAuthorName(
      userId: params.userId,
      authorName: params.authorName.trim(),
    );
  }
}
