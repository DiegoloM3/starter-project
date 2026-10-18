import 'package:equatable/equatable.dart';

import '../../../domain/entities/article.dart';

enum ArticleDetailStatus { idle, deleting, deleted, deleteFailure }

class ArticleDetailState extends Equatable {
  final ArticleEntity article;
  final ArticleDetailStatus status;

  const ArticleDetailState({required this.article, this.status = ArticleDetailStatus.idle});

  @override
  List<Object?> get props => [article, status];
}
