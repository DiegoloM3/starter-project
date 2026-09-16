import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_lens.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/editor_suggestions.dart';

/// The editorial assistant: a language model behind our own backend.
abstract interface class ArticleAssistantRepository {
  /// Headlines, teaser and category for a draft being written.
  Future<DataState<EditorSuggestions>> suggest(ArticleDraft draft);

  /// A different way to read a published article.
  Future<DataState<ArticleLensResult>> apply(ArticleLens lens, ArticleEntity article);
}
