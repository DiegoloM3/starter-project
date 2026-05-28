import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';

abstract class ArticleActionState extends Equatable {
  const ArticleActionState();

  @override
  List<Object?> get props => [];
}

class ArticleActionInitial extends ArticleActionState {
  const ArticleActionInitial();
}

class ArticleActionInProgress extends ArticleActionState {
  const ArticleActionInProgress();
}

class ArticleActionDeleteSuccess extends ArticleActionState {
  const ArticleActionDeleteSuccess();
}

class ArticleActionFailure extends ArticleActionState {
  final AppException error;

  const ArticleActionFailure(this.error);

  @override
  List<Object?> get props => [error];
}
