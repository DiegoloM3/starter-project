import 'package:equatable/equatable.dart';

import '../entities/journalist_article.dart';

/// Input of `PublishArticleUseCase`: the draft to make public and the moment
/// it becomes public.
///
/// The moment is part of the input (instead of being read from the clock
/// inside the use case) so that the business rule stays deterministic and
/// testable.
class PublishArticleParams extends Equatable {
  final JournalistArticleEntity article;
  final DateTime publishedAt;

  PublishArticleParams(this.article, {DateTime? publishedAt})
      : publishedAt = publishedAt ?? DateTime.now();

  @override
  List<Object?> get props => [article, publishedAt];
}
