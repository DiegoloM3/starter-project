import 'package:flutter/material.dart';

import '../../../../../config/routes/routes.dart';
import '../../../../articles/presentation/widgets/recently_viewed_section.dart';
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
        extraSection: RecentlyViewedSection(
          onArticleTap: (article) => Navigator.of(context).pushNamed(AppRoutes.articleDetail, arguments: article),
        ),
      ),
    );
  }
}
