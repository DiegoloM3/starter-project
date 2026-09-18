import 'package:equatable/equatable.dart';

import '../../domain/entities/publishable_article.dart';

enum PublishedArticlesStatus { initial, loading, success, failure }

class PublishedArticlesState extends Equatable {
  final PublishedArticlesStatus status;
  final List<PublishableArticle> articles;
  final String? failureMessage;

  const PublishedArticlesState({
    this.status = PublishedArticlesStatus.initial,
    this.articles = const [],
    this.failureMessage,
  });

  bool get isLoading => status == PublishedArticlesStatus.loading;
  bool get isSuccess => status == PublishedArticlesStatus.success;
  bool get isFailure => status == PublishedArticlesStatus.failure;

  @override
  List<Object?> get props => [status, articles, failureMessage];
}
