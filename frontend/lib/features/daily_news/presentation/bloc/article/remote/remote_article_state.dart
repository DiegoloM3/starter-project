import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:news_app_clean_architecture/core/error/app_failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

part 'remote_article_state.freezed.dart';

@freezed
class RemoteArticlesState with _$RemoteArticlesState {
  const factory RemoteArticlesState.loading() = RemoteArticlesLoading;
  const factory RemoteArticlesState.done(List<ArticleEntity> articles) =
      RemoteArticlesDone;
  const factory RemoteArticlesState.error(AppFailure failure) =
      RemoteArticlesError;
}
