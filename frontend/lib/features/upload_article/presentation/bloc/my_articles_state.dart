import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/entities/user_article.dart';

enum ArticlesFilter { mine, all }

sealed class MyArticlesState extends Equatable {
  final ArticlesFilter filter;
  const MyArticlesState(this.filter);

  @override
  List<Object?> get props => [filter];
}

class MyArticlesInitial extends MyArticlesState {
  const MyArticlesInitial(super.filter);
}

class MyArticlesLoading extends MyArticlesState {
  const MyArticlesLoading(super.filter);
}

class MyArticlesLoaded extends MyArticlesState {
  final List<UserArticleEntity> articles;
  const MyArticlesLoaded(super.filter, this.articles);

  @override
  List<Object?> get props => [filter, articles];
}

class MyArticlesFailure extends MyArticlesState {
  final String message;
  const MyArticlesFailure(super.filter, this.message);

  @override
  List<Object?> get props => [filter, message];
}
