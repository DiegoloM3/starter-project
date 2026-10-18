import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/routes/routes.dart';
import '../../../../articles/presentation/widgets/recently_viewed_section.dart';
import '../../bloc/user_profile/user_profile_cubit.dart';
import '../../widgets/profile_content.dart';

/// Profile tab of the signed in user. It expects a UserProfileCubit of that user and a
/// ReadingHistoryCubit above it.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            tooltip: 'Configuración',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.settings),
          ),
        ],
      ),
      body: ProfileContent(
        action: OutlinedButton(onPressed: () => _editProfile(context), child: const Text('EDITAR PERFIL')),
        extraSection: RecentlyViewedSection(
          onArticleTap: (article) => Navigator.of(context).pushNamed(AppRoutes.articleDetail, arguments: article),
        ),
      ),
    );
  }

  Future<void> _editProfile(BuildContext context) async {
    final profileCubit = context.read<UserProfileCubit>();
    final user = profileCubit.state.user;
    if (user == null) return;
    final wasSaved = await Navigator.of(context).pushNamed(AppRoutes.editProfile, arguments: user);
    if (wasSaved == true) profileCubit.load();
  }
}
