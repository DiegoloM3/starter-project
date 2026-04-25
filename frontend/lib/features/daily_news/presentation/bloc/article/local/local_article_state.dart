import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:news_app_clean_architecture/core/error/app_failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

part 'local_article_state.freezed.dart';

@freezed
class LocalArticlesState with _$LocalArticlesState {
  const factory LocalArticlesState.loading() = LocalArticlesLoading;
  const factory LocalArticlesState.done(List<ArticleEntity> articles) =
      LocalArticlesDone;
  const factory LocalArticlesState.error(AppFailure failure) =
      LocalArticlesError;
}
