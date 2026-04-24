import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:news_app_clean_architecture/core/error/app_failure.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';

part 'my_articles_state.freezed.dart';

@freezed
class MyArticlesState with _$MyArticlesState {
  const factory MyArticlesState.initial() = MyArticlesInitial;
  const factory MyArticlesState.loading() = MyArticlesLoading;
  const factory MyArticlesState.success(List<UserArticleEntity> articles) =
      MyArticlesSuccess;
  const factory MyArticlesState.failure(AppFailure failure) = MyArticlesFailure;
}
