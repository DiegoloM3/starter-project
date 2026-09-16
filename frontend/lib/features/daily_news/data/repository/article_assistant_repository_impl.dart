import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/assistant_functions_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article_lens_result_model.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/editor_suggestions_model.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_lens.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/editor_suggestions.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_assistant_repository.dart';
import 'package:news_app_clean_architecture/shared/firebase/data/data_sources/firebase_failure_mapper.dart';

class ArticleAssistantRepositoryImpl implements ArticleAssistantRepository {
  final AssistantFunctionsService _service;

  const ArticleAssistantRepositoryImpl(this._service);

  static const Map<ArticleLens, String> _taskFor = {
    ArticleLens.brief: 'brief',
    ArticleLens.plain: 'plain',
  };

  @override
  Future<DataState<EditorSuggestions>> suggest(ArticleDraft draft) {
    return _guard(() async {
      final raw = await _service.call(
        task: 'suggest',
        title: draft.trimmedTitle,
        content: draft.trimmedContent,
      );
      final model = EditorSuggestionsModel.fromRawData(raw);
      if (model.headlines.isEmpty) throw const _EmptyAnswer();
      return model.toEntity();
    });
  }

  @override
  Future<DataState<ArticleLensResult>> apply(ArticleLens lens, ArticleEntity article) {
    return _guard(() async {
      final raw = await _service.call(
        task: _taskFor[lens]!,
        title: article.title,
        content: article.content,
      );
      final model = ArticleLensResultModel.fromRawData(lens, raw);
      if (model.isEmpty) throw const _EmptyAnswer();
      return model.toEntity();
    });
  }

  Future<DataState<T>> _guard<T>(Future<T> Function() operation) => runGuarded(
        operation,
        onError: (error) => error is _EmptyAnswer
            ? const Failure.server('The editor gave an empty answer. Try again.')
            : FirebaseFailureMapper.map(error),
      );
}

class _EmptyAnswer implements Exception {
  const _EmptyAnswer();
}
