import 'package:equatable/equatable.dart';

/// Input of `IncrementArticleViewCountUseCase`.
class IncrementArticleViewCountParams extends Equatable {
  final String articleId;

  const IncrementArticleViewCountParams(this.articleId);

  @override
  List<Object?> get props => [articleId];
}
