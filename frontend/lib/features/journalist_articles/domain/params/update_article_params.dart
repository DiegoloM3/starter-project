import 'package:equatable/equatable.dart';

import '../entities/journalist_article.dart';

/// Input of `UpdateArticleUseCase`: the already stored article carrying the
/// edits made by its author.
class UpdateArticleParams extends Equatable {
  final JournalistArticleEntity article;

  const UpdateArticleParams(this.article);

  @override
  List<Object?> get props => [article];
}
