import 'package:equatable/equatable.dart';

/// Input of `GetArticleByIdUseCase`.
class GetArticleByIdParams extends Equatable {
  final String articleId;

  const GetArticleByIdParams(this.articleId);

  @override
  List<Object?> get props => [articleId];
}
