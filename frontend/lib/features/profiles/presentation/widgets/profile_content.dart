import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routes/routes.dart';
import '../../../articles/presentation/widgets/article_list_tile.dart';
import '../bloc/user_profile/user_profile_cubit.dart';
import '../bloc/user_profile/user_profile_state.dart';
import 'profile_header.dart';

/// Body shared by the own profile and the profiles of other users. [action] goes below the
/// header, such as the follow button, and [extraSection] above the articles.
class ProfileContent extends StatelessWidget {
  final Widget? action;
  final Widget? extraSection;

  const ProfileContent({super.key, this.action, this.extraSection});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserProfileCubit, UserProfileState>(
      listenWhen: (_, state) => state.followFailed,
      listener:
          (context, _) => ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('No se pudo actualizar el seguimiento. Inténtalo de nuevo.'))),
      builder:
          (context, state) =>
              RefreshIndicator(onRefresh: context.read<UserProfileCubit>().load, child: _buildBody(context, state)),
    );
  }

  Widget _buildBody(BuildContext context, UserProfileState state) {
    final user = state.user;
    if (user == null) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          if (state.status == UserProfileStatus.failure)
            Column(
              children: [
                const Text('No se pudo cargar el perfil.'),
                TextButton(onPressed: context.read<UserProfileCubit>().load, child: const Text('Reintentar')),
              ],
            )
          else
            const Center(child: CircularProgressIndicator()),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 32),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: ProfileHeader(user: user, stats: state.stats),
        ),
        if (action != null) ...[const SizedBox(height: 20), Center(child: action)],
        if (extraSection != null) extraSection!,
        if (state.articles.isNotEmpty) ..._buildArticles(context, state),
      ],
    );
  }

  List<Widget> _buildArticles(BuildContext context, UserProfileState state) {
    return [
      const SizedBox(height: 32),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'ARTÍCULOS (${state.articles.length})',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.5),
        ),
      ),
      const SizedBox(height: 8),
      const Divider(),
      for (final article in state.articles) ...[
        ArticleListTile(
          article: article,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.articleDetail, arguments: article),
        ),
        const Divider(indent: 16, endIndent: 16),
      ],
    ];
  }
}
