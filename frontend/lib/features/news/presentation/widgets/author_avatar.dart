import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/avatar/author_avatar_cubit.dart';

/// Small circular author avatar shared by article cards and the detail view.
///
/// Resolves the photo live from the author's public profile (`users/{uid}`)
/// through a cached read; while loading, on error, or when the author has
/// no photo — including daily news, which carries no author id at all — it
/// shows a neutral person silhouette.
///
/// The cubit is supplied by the caller (constructor or ancestor provider):
/// this widget never touches the service locator itself, keeping it reusable
/// and testable per 3.4.1/3.4.2. [cubitFactory] is a convenience for list
/// items where an ancestor provider per row is impractical; tests pass a
/// fake factory, production passes `() => sl<AuthorAvatarCubit>()` from the
/// composition root.
class AuthorAvatar extends StatelessWidget {
  final String? authorId;
  final double radius;
  final AuthorAvatarCubit Function()? cubitFactory;

  const AuthorAvatar({
    super.key,
    this.authorId,
    this.radius = 12,
    this.cubitFactory,
  });

  @override
  Widget build(BuildContext context) {
    if (authorId?.isNotEmpty != true) {
      return _silhouette();
    }
    final factory = cubitFactory;
    if (factory != null) {
      return BlocProvider(
        create: (_) => factory()..load(authorId!),
        child: BlocBuilder<AuthorAvatarCubit, AuthorAvatarState>(
          builder: (context, state) => _buildFromState(state),
        ),
      );
    }
    // No factory: use an ancestor cubit when one is provided; otherwise
    // degrade to the silhouette instead of throwing ProviderNotFound (3.4).
    // This keeps list rows and tests that haven't wired the cubit green
    // while production pages pass a factory for live resolution.
    AuthorAvatarCubit? ancestor;
    try {
      ancestor = context.read<AuthorAvatarCubit>();
    } catch (_) {
      ancestor = null;
    }
    if (ancestor == null) {
      return _silhouette();
    }
    return BlocBuilder<AuthorAvatarCubit, AuthorAvatarState>(
      builder: (context, state) => _buildFromState(state),
    );
  }

  Widget _buildFromState(AuthorAvatarState state) {
    if (state is AuthorAvatarDone) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.black12,
        // Decode bound: avatars render at ≤48px radius; never decode the
        // full upload for a thumbnail.
        backgroundImage: ResizeImage(
          CachedNetworkImageProvider(state.photoUrl),
          width: 144,
        ),
      );
    }
    return _silhouette();
  }

  Widget _silhouette() {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.black12,
      child: Icon(
        Icons.person,
        size: radius,
        color: Colors.white70,
      ),
    );
  }
}
