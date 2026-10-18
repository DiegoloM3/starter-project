import 'package:flutter/material.dart';

import '../../../../../config/routes/routes.dart';
import '../../../domain/entities/user.dart';
import '../../widgets/role_badge.dart';
import '../../widgets/user_avatar.dart';

/// Profile tab of the signed in user. Followers and history arrive with the social features.
class ProfileScreen extends StatelessWidget {
  final UserEntity user;

  const ProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
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
      body: ListView(
        children: [
          const SizedBox(height: 32),
          Center(child: UserAvatar(user: user)),
          const SizedBox(height: 16),
          Text(
            user.fullName,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Center(child: RoleBadge(role: user.role)),
          if (user.bio.isNotEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(user.bio, textAlign: TextAlign.center, style: textTheme.bodyLarge),
            ),
          ],
        ],
      ),
    );
  }
}
