import 'package:equatable/equatable.dart';

abstract class CreateArticleState extends Equatable {
  const CreateArticleState();

  @override
  List<Object?> get props => [];
}

class CreateArticleInitial extends CreateArticleState {
  const CreateArticleInitial();
}

class CreateArticleSubmitting extends CreateArticleState {
  const CreateArticleSubmitting();
}

class CreateArticleSuccess extends CreateArticleState {
  const CreateArticleSuccess();
}

class CreateArticleFailure extends CreateArticleState {
  final String message;

  const CreateArticleFailure(this.message);

  @override
  List<Object?> get props => [message];
}

