import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/resources/data_state.dart';
import '../../domain/entities/article_comment.dart';
import '../../domain/usecases/social_interactions.dart';
import '../../domain/repository/community_social_repository.dart';

class SocialInteractionsState {
  final int likeCount;
  final bool isLiked;
  final List<ArticleCommentEntity> comments;
  final bool likesLoading;
  final bool commentsLoading;
  final bool likeBusy;
  final bool commentBusy;
  final String? error;
  final bool requiresAuth;

  const SocialInteractionsState({
    this.likeCount = 0,
    this.isLiked = false,
    this.comments = const [],
    this.likesLoading = true,
    this.commentsLoading = true,
    this.likeBusy = false,
    this.commentBusy = false,
    this.error,
    this.requiresAuth = false,
  });

  SocialInteractionsState copyWith({
    int? likeCount,
    bool? isLiked,
    List<ArticleCommentEntity>? comments,
    bool? likesLoading,
    bool? commentsLoading,
    bool? likeBusy,
    bool? commentBusy,
    String? error,
    bool clearError = false,
    bool? requiresAuth,
  }) {
    return SocialInteractionsState(
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      comments: comments ?? this.comments,
      likesLoading: likesLoading ?? this.likesLoading,
      commentsLoading: commentsLoading ?? this.commentsLoading,
      likeBusy: likeBusy ?? this.likeBusy,
      commentBusy: commentBusy ?? this.commentBusy,
      error: clearError ? null : error ?? this.error,
      requiresAuth: requiresAuth ?? this.requiresAuth,
    );
  }
}

/// Owns the two realtime Firestore listeners for one article detail page.
class SocialInteractionsCubit extends Cubit<SocialInteractionsState> {
  final String articleId;
  final CommunitySocialRepository _repository;
  final WatchArticleLikesUseCase _watchLikes;
  final WatchArticleCommentsUseCase _watchComments;
  final ToggleArticleLikeUseCase _toggleLike;
  final AddArticleCommentUseCase _addComment;
  final DeleteArticleCommentUseCase _deleteComment;
  StreamSubscription<Set<String>>? _likesSubscription;
  StreamSubscription<List<ArticleCommentEntity>>? _commentsSubscription;
  Set<String> _likeUserIds = const {};
  bool _hasLikeSnapshot = false;
  int _authStateVersion = 0;
  bool _likeBusy = false;
  bool _commentBusy = false;

  SocialInteractionsCubit({
    required this.articleId,
    required CommunitySocialRepository repository,
    required WatchArticleLikesUseCase watchLikes,
    required WatchArticleCommentsUseCase watchComments,
    required ToggleArticleLikeUseCase toggleLike,
    required AddArticleCommentUseCase addComment,
    required DeleteArticleCommentUseCase deleteComment,
  })  : _repository = repository,
        _watchLikes = watchLikes,
        _watchComments = watchComments,
        _toggleLike = toggleLike,
        _addComment = addComment,
        _deleteComment = deleteComment,
        super(const SocialInteractionsState()) {
    _subscribe();
  }

  bool get isSignedIn => _repository.currentUserId != null;

  String? get currentUserId => _repository.currentUserId;

  void _subscribe() {
    _likesSubscription = _watchLikes(articleId).listen(
      (uids) {
        if (isClosed) return;
        _likeUserIds = Set.unmodifiable(uids);
        _hasLikeSnapshot = true;
        _emitLikeState();
      },
      onError: (Object error, StackTrace stackTrace) {
        if (isClosed) return;
        emit(state.copyWith(
          likesLoading: false,
          error: 'Unable to load likes right now.',
        ));
      },
    );
    _commentsSubscription = _watchComments(articleId).listen(
      (comments) {
        if (isClosed) return;
        emit(state.copyWith(
          comments: List.unmodifiable(comments),
          commentsLoading: false,
          clearError: true,
        ));
      },
      onError: (Object error, StackTrace stackTrace) {
        if (isClosed) return;
        emit(state.copyWith(
          commentsLoading: false,
          error: 'Unable to load comments right now.',
        ));
      },
    );
  }

  void _emitLikeState({String? userId, bool? likeBusy}) {
    if (isClosed) return;
    final uid = userId ?? _repository.currentUserId;
    emit(state.copyWith(
      likeCount: _likeUserIds.length,
      isLiked: uid != null && _likeUserIds.contains(uid),
      likesLoading: _hasLikeSnapshot ? false : state.likesLoading,
      likeBusy: likeBusy,
      clearError: true,
    ));
  }

  /// Recomputes the current user's like from the latest shared likes snapshot.
  ///
  /// Auth changes do not necessarily produce another Firestore snapshot, so
  /// this must be called by the detail screen when its auth state changes.
  void refreshLikeState({String? userId}) {
    if (isClosed) return;
    _authStateVersion++;
    _emitLikeState(userId: userId);
  }

  Future<void> toggleLike() async {
    if (_likeBusy || isClosed) return;
    if (_repository.currentUserId == null) {
      emit(state.copyWith(
        error: 'Sign in to like this article.',
        requiresAuth: true,
      ));
      return;
    }
    final userId = _repository.currentUserId;
    final isLiked =
        _hasLikeSnapshot ? _likeUserIds.contains(userId) : state.isLiked;
    final authStateVersion = _authStateVersion;
    _likeBusy = true;
    emit(state.copyWith(likeBusy: true, clearError: true, requiresAuth: false));
    final result = await _toggleLike(articleId, isLiked: isLiked);
    _likeBusy = false;
    if (isClosed) return;
    if (authStateVersion != _authStateVersion ||
        userId != _repository.currentUserId) {
      _emitLikeState(likeBusy: false);
      return;
    }
    if (result is DataSuccess<void>) {
      emit(state.copyWith(likeBusy: false, clearError: true));
    } else {
      emit(state.copyWith(
        likeBusy: false,
        error: result.error?.message ?? 'Unable to update like.',
      ));
    }
  }

  Future<void> addComment(String body) async {
    if (_commentBusy || isClosed) return;
    if (_repository.currentUserId == null) {
      emit(state.copyWith(
        error: 'Sign in to comment on this article.',
        requiresAuth: true,
      ));
      return;
    }
    _commentBusy = true;
    emit(state.copyWith(
      commentBusy: true,
      clearError: true,
      requiresAuth: false,
    ));
    final result = await _addComment(articleId, body);
    _commentBusy = false;
    if (isClosed) return;
    if (result is DataSuccess<void>) {
      emit(state.copyWith(commentBusy: false, clearError: true));
    } else {
      emit(state.copyWith(
        commentBusy: false,
        error: result.error?.message ?? 'Unable to add comment.',
      ));
    }
  }

  Future<void> deleteComment(ArticleCommentEntity comment) async {
    if (isClosed) return;
    if (_repository.currentUserId == null) {
      emit(state.copyWith(
        error: 'Sign in to delete comments.',
        requiresAuth: true,
      ));
      return;
    }
    if (_repository.currentUserId != comment.authorUid) {
      emit(state.copyWith(error: 'You can only delete your own comments.'));
      return;
    }
    final result = await _deleteComment(articleId, comment.id);
    if (isClosed) return;
    if (result is DataSuccess<void>) {
      emit(state.copyWith(clearError: true));
    } else {
      emit(state.copyWith(
        error: result.error?.message ?? 'Unable to delete comment.',
      ));
    }
  }

  void clearError() {
    if (isClosed) return;
    emit(state.copyWith(clearError: true, requiresAuth: false));
  }

  void clearAuthRequirement() {
    if (isClosed) return;
    emit(state.copyWith(clearError: true, requiresAuth: false));
  }

  @override
  Future<void> close() async {
    await _likesSubscription?.cancel();
    await _commentsSubscription?.cancel();
    return super.close();
  }
}
