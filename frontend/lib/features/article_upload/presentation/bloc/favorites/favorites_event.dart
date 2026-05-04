import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';

sealed class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

final class LoadFavoritesEvent extends FavoritesEvent {
  const LoadFavoritesEvent();
}

final class ToggleFavoriteEvent extends FavoritesEvent {
  final String articleId;
  const ToggleFavoriteEvent(this.articleId);

  @override
  List<Object?> get props => [articleId];
}

final class FavoriteIdsUpdatedEvent extends FavoritesEvent {
  final List<String> ids;
  const FavoriteIdsUpdatedEvent(this.ids);

  @override
  List<Object?> get props => [ids];
}

final class FavoritesFailedEvent extends FavoritesEvent {
  final AppException error;
  const FavoritesFailedEvent(this.error);

  @override
  List<Object?> get props => [error];
}
