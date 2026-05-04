import 'package:equatable/equatable.dart';

class DeleteArticleParams extends Equatable {
  final String articleId;

  const DeleteArticleParams({required this.articleId});

  @override
  List<Object?> get props => [articleId];
}
