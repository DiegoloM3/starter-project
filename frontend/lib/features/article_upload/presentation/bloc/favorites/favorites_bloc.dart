import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/toggle_favorite_params.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/toggle_favorite.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/watch_favorite_ids.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

/// Reads `FirebaseAuth.currentUser?.uid` synchronously to short-circuit the
/// favorites stream when the user is not authenticated and to scope the
/// toggle write to the current user. A dedicated CurrentUserService would
/// be pure indirection.
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final WatchFavoriteIdsUseCase _watchFavoriteIdsUseCase;
  final ToggleFavoriteUseCase _toggleFavoriteUseCase;
  final FirebaseAuth _firebaseAuth;

  StreamSubscription<List<String>>? _favoritesSub;

  FavoritesBloc(
    this._watchFavoriteIdsUseCase,
    this._toggleFavoriteUseCase,
    this._firebaseAuth,
  ) : super(const FavoritesState()) {
    on<LoadFavoritesEvent>(_onLoad);
    on<ToggleFavoriteEvent>(_onToggle);
    on<FavoriteIdsUpdatedEvent>(
      (e, emit) => emit(state.copyWith(favoriteIds: Set.from(e.ids))),
    );
    on<FavoritesFailedEvent>(
      (e, emit) => emit(state.copyWith(error: e.error)),
    );
  }

  Future<void> _onLoad(
    LoadFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) return;
    _favoritesSub?.cancel();
    _favoritesSub =
        _watchFavoriteIdsUseCase.call(params: uid).listen(
      (ids) => add(FavoriteIdsUpdatedEvent(ids)),
      onError: (Object e, StackTrace st) =>
          add(FavoritesFailedEvent(_mapStreamError(e, st))),
    );
  }

  AppException _mapStreamError(Object e, StackTrace st) {
    if (e is AppException) return e;
    return FirestoreException(
      message: e.toString(),
      cause: e,
      stackTrace: st,
    );
  }

  Future<void> _onToggle(
    ToggleFavoriteEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    // Capturing prevState here is the canonical optimistic-UI rollback pattern:
    // emit the desired state synchronously, then restore prevState on failure
    // so the UI never gets stuck in an intermediate optimistic state.
    final prevState = state;

    final currentlyFavorited = state.favoriteIds.contains(event.articleId);
    final optimisticIds = currentlyFavorited
        ? ({...state.favoriteIds}..remove(event.articleId))
        : {...state.favoriteIds, event.articleId};

    emit(state.copyWith(favoriteIds: optimisticIds, error: null));

    final result = await _toggleFavoriteUseCase.call(
      params: ToggleFavoriteParams(
        articleId: event.articleId,
        currentlyFavorited: currentlyFavorited,
      ),
    );

    if (result is DataFailed) {
      emit(prevState.copyWith(error: result.error));
    }
  }

  @override
  Future<void> close() {
    _favoritesSub?.cancel();
    return super.close();
  }
}
