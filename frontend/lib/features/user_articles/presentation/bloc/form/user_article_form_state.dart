import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';

abstract class UserArticleFormState extends Equatable {
  const UserArticleFormState();

  @override
  List<Object?> get props => [];
}

class UserArticleFormIdle extends UserArticleFormState {
  const UserArticleFormIdle();
}

class UserArticleFormSubmitting extends UserArticleFormState {
  const UserArticleFormSubmitting();
}

class UserArticleFormSuccess extends UserArticleFormState {
  final UserArticleEntity article;

  const UserArticleFormSuccess(this.article);

  @override
  List<Object?> get props => [article];
}

class UserArticleFormError extends UserArticleFormState {
  final String message;

  const UserArticleFormError(this.message);

  @override
  List<Object?> get props => [message];
}
