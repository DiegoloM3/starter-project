import 'package:equatable/equatable.dart';

/// Input of `DeleteArticleUseCase`.
class DeleteArticleParams extends Equatable {
  final String articleId;

  const DeleteArticleParams(this.articleId);

  @override
  List<Object?> get props => [articleId];
}
