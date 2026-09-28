import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_author_profile.dart';

part 'author_avatar_state.dart';

/// Resolves one author's avatar for display in article cards.
///
/// Reads go through the repository cache, so many cards by the same author
/// share a single Firestore read per cache window. Any failure (or a
/// missing profile/photo) ends in [AuthorAvatarMissing], and callers render
/// the silhouette fallback for every non-[AuthorAvatarDone] state.
@injectable
class AuthorAvatarCubit extends Cubit<AuthorAvatarState> {
  final GetAuthorProfile _getAuthorProfile;

  AuthorAvatarCubit(this._getAuthorProfile)
      : super(const AuthorAvatarLoading());

  /// Loads the avatar for [authorId], emitting done or missing states.
  Future<void> load(String authorId) async {
    if (authorId.trim().isEmpty) {
      emit(const AuthorAvatarMissing());
      return;
    }
    emit(const AuthorAvatarLoading());

    final result = await _getAuthorProfile(
      params: GetAuthorProfileParams(authorId: authorId),
    );

    final photoUrl =
        result is DataSuccess ? result.data?.photoUrl : null;
    if (photoUrl?.isNotEmpty == true) {
      emit(AuthorAvatarDone(photoUrl!));
    } else {
      emit(const AuthorAvatarMissing());
    }
  }
}
