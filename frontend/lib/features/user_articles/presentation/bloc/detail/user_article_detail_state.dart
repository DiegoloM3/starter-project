import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';

abstract class UserArticleDetailState extends Equatable {
  const UserArticleDetailState();

  @override
  List<Object?> get props => [];
}

class UserArticleDetailLoading extends UserArticleDetailState {
  const UserArticleDetailLoading();
}

class UserArticleDetailLoaded extends UserArticleDetailState {
  final UserArticleEntity article;

  const UserArticleDetailLoaded(this.article);

  @override
  List<Object?> get props => [article];
}

class UserArticleDetailDeleted extends UserArticleDetailState {
  const UserArticleDetailDeleted();
}

class UserArticleDetailError extends UserArticleDetailState {
  final String message;

  const UserArticleDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
