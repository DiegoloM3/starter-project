import 'package:equatable/equatable.dart';

import '../../../domain/entities/article.dart';

enum ArticlesStatus { initial, loading, success, failure }

class ArticlesState extends Equatable {
  final ArticlesStatus status;
  final List<ArticleEntity> articles;

  const ArticlesState({this.status = ArticlesStatus.initial, this.articles = const []});

  @override
  List<Object?> get props => [status, articles];
}
