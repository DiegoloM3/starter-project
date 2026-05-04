import 'package:equatable/equatable.dart';

class ToggleFavoriteParams extends Equatable {
  final String articleId;
  final bool currentlyFavorited;

  const ToggleFavoriteParams({
    required this.articleId,
    required this.currentlyFavorited,
  });

  @override
  List<Object?> get props => [articleId, currentlyFavorited];
}
