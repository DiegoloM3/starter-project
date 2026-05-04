import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';

final class FavoritesState extends Equatable {
  final Set<String> favoriteIds;
  final AppException? error;

  const FavoritesState({
    this.favoriteIds = const {},
    this.error,
  });

  FavoritesState copyWith({
    Set<String>? favoriteIds,
    Object? error = _sentinel,
  }) {
    return FavoritesState(
      favoriteIds: favoriteIds ?? this.favoriteIds,
      error: error == _sentinel ? this.error : error as AppException?,
    );
  }

  @override
  List<Object?> get props => [favoriteIds, error];
}

const _sentinel = Object();
