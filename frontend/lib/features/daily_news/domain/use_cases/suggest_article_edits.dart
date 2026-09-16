import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/editor_suggestions.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_assistant_repository.dart';

/// Asks the desk editor for headlines, a teaser and a category. A draft
/// that is too short to judge is refused locally, so no request is wasted.
class SuggestArticleEditsUseCase implements UseCase<DataState<EditorSuggestions>, ArticleDraft> {
  final ArticleAssistantRepository _assistant;

  const SuggestArticleEditsUseCase(this._assistant);

  static const int minimumWords = 40;

  @override
  Future<DataState<EditorSuggestions>> call(ArticleDraft params) {
    if (params.trimmedContent.length > ArticleLimits.contentMaxLength) {
      return Future.value(
        const DataFailed(Failure.validation('The article is longer than the editor can read.')),
      );
    }
    if (wordCount(params.trimmedContent) < minimumWords) {
      return Future.value(DataFailed(Failure.validation(
        'Write at least $minimumWords words so the editor has something to work with.',
      )));
    }
    return _assistant.suggest(params);
  }

  static int wordCount(String text) =>
      text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
}
