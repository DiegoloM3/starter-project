part of 'edit_article_bloc.dart';

/// UI states emitted by [EditArticleBloc].
abstract class EditArticleState extends Equatable {
  const EditArticleState();

  @override
  List<Object?> get props => [];
}

class EditArticleIdle extends EditArticleState {
  const EditArticleIdle();
}

class EditArticleLoading extends EditArticleState {
  const EditArticleLoading();
}

class EditArticleSaved extends EditArticleState {
  const EditArticleSaved();
}

class EditArticleDeleted extends EditArticleState {
  const EditArticleDeleted();
}

class EditArticleError extends EditArticleState {
  final String message;
  const EditArticleError(this.message);

  @override
  List<Object?> get props => [message];
}
