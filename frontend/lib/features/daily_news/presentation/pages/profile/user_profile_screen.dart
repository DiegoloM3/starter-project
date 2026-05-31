import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';

import '../../../../../core/design_system/design_system.dart';

/// User profile screen with account settings.
class UserProfileScreen extends HookWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final darkMode = useState(true);

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return Scaffold(
            backgroundColor: context.theme.scaffoldBackgroundColor,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final user = state.user;
        final email = user.email;
        final displayName = user.displayName?.trim();
        final name = displayName?.isNotEmpty == true
            ? displayName!
            : email.split('@').first;
        final photoUrl = user.photoUrl;

        return Scaffold(
          backgroundColor: context.theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: context.theme.scaffoldBackgroundColor,
            elevation: 0,
            leading: const BackButton(),
            title: Text(
              'Symmetry NEWS',
              style: context.textTheme.titleLarge?.copyWith(
                color: context.colorScheme.onSurface,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () => context.go('/search'),
                icon: Icon(Icons.search, color: context.colorScheme.onSurface),
              ),
            ],
          ),
          body: ListView(
            children: [
              // Avatar + name + email
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.outlineVariant,
                          width: 2,
                        ),
                      ),
                      padding: const EdgeInsets.all(3),
                      child: CircleAvatar(
                        radius: 44,
                        backgroundColor: context.colorScheme.surfaceContainer,
                        backgroundImage:
                            photoUrl == null || photoUrl.trim().isEmpty
                            ? null
                            : NetworkImage(photoUrl),
                        child: photoUrl == null || photoUrl.trim().isEmpty
                            ? Icon(
                                Icons.person_outline,
                                size: 40,
                                color: context.colorScheme.onSurfaceVariant,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      name,
                      style: context.textTheme.headlineSmall?.copyWith(
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // My Articles
              _SettingsRow(
                icon: Icons.article_outlined,
                label: 'My Articles',
                onTap: () {},
              ),
              const Divider(height: 1, indent: 56),
              // ACCOUNT SETTINGS header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Text(
                  'ACCOUNT SETTINGS',
                  style: context.textTheme.labelLarge?.copyWith(
                    letterSpacing: 0.8,
                    color: AppColors.primary,
                  ),
                ),
              ),
              // Notifications
              _SettingsRow(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                onTap: () {},
              ),
              const Divider(height: 1, indent: 56),
              // Dark Mode
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: Icon(
                  Icons.dark_mode_outlined,
                  color: context.colorScheme.onSurface,
                ),
                title: Text(
                  'Dark Mode',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
                ),
                trailing: Switch(
                  value: darkMode.value,
                  onChanged: (v) => darkMode.value = v,
                  activeThumbColor: context.colorScheme.onSurface,
                ),
              ),
              const Divider(height: 1, indent: 56),
              // Language
              _SettingsRow(
                icon: Icons.language_outlined,
                label: 'Language',
                trailing: Text(
                  'English',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                onTap: () {},
              ),
              const Divider(height: 1, indent: 56),
              // About
              _SettingsRow(
                icon: Icons.info_outline,
                label: 'About',
                onTap: () {},
              ),
              const Divider(height: 1, indent: 56),
              const SizedBox(height: 40),
              // Sign Out
              GestureDetector(
                onTap: () =>
                    context.read<AuthBloc>().add(const SignOutRequested()),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.logout,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'SIGN OUT',
                        style: context.textTheme.labelLarge?.copyWith(
                          letterSpacing: 0.8,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, color: context.colorScheme.onSurface),
      title: Text(
        label,
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.onSurface,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ?trailing,
          Icon(
            Icons.chevron_right,
            color: context.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
