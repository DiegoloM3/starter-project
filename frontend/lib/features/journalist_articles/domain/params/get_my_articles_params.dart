import 'package:equatable/equatable.dart';

import '../entities/article_status.dart';

/// Input of `GetMyArticlesUseCase`: the author whose articles are listed, plus
/// the optional filters offered by the "My articles" screen.
class GetMyArticlesParams extends Equatable {
  final String userId;

  /// When null, drafts and published articles are returned together.
  final ArticleStatus? status;

  /// When null or blank, no text filter is applied.
  final String? searchQuery;

  const GetMyArticlesParams({
    required this.userId,
    this.status,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [userId, status, searchQuery];
}
