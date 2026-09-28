part of 'author_avatar_cubit.dart';

/// UI states emitted by [AuthorAvatarCubit].
abstract class AuthorAvatarState extends Equatable {
  const AuthorAvatarState();

  @override
  List<Object?> get props => [];
}

class AuthorAvatarLoading extends AuthorAvatarState {
  const AuthorAvatarLoading();
}

class AuthorAvatarDone extends AuthorAvatarState {
  final String photoUrl;

  const AuthorAvatarDone(this.photoUrl);

  @override
  List<Object?> get props => [photoUrl];
}

class AuthorAvatarMissing extends AuthorAvatarState {
  const AuthorAvatarMissing();
}
