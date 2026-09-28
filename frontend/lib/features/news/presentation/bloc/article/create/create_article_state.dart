part of 'create_article_bloc.dart';

/// UI states emitted by [CreateArticleBloc].
abstract class CreateArticleState extends Equatable {
  const CreateArticleState();

  @override
  List<Object?> get props => [];
}

class CreateArticleIdle extends CreateArticleState {
  const CreateArticleIdle();
}

class CreateArticleLoading extends CreateArticleState {
  const CreateArticleLoading();
}

class CreateArticleSuccess extends CreateArticleState {
  const CreateArticleSuccess();
}

class CreateArticleError extends CreateArticleState {
  final String message;
  const CreateArticleError(this.message);

  @override
  List<Object?> get props => [message];
}
