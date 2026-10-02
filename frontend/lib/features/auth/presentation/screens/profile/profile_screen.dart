import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/config/theme/user_avatar.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/session/session_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/session/session_state.dart';

/// Account of the signed-in journalist, with the button to log out.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        shape: Border(bottom: BorderSide(color: context.palette.divider)),
      ),
      body: BlocBuilder<SessionCubit, SessionState>(
        builder: (context, state) {
          if (state is! SessionSignedIn) return const SizedBox.shrink();
          return _ProfileDetails(user: state.user);
        },
      ),
    );
  }
}

class _ProfileDetails extends StatelessWidget {
  final UserEntity user;

  const _ProfileDetails({required this.user});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ListView(
      // The bottom padding keeps the content above the translucent navigation bar.
      padding: EdgeInsets.fromLTRB(16, 32, 16, MediaQuery.paddingOf(context).bottom + 16),
      children: [
        Center(child: UserAvatar(initials: user.initials)),
        const SizedBox(height: 16),
        Text(
          user.name,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Text(
          user.email,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: palette.textSecondary),
        ),
        const SizedBox(height: 24),
        _buildAccountDetails(palette),
        const SizedBox(height: 24),
        const _LogOutButton(),
      ],
    );
  }

  Widget _buildAccountDetails(AppPalette palette) {
    return Material(
      color: palette.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _AccountDetailTile(icon: Ionicons.personOutline, label: 'Name', value: user.name),
          Divider(height: 1, color: palette.divider),
          _AccountDetailTile(icon: Ionicons.mailOutline, label: 'Email', value: user.email),
        ],
      ),
    );
  }
}

class _AccountDetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _AccountDetailTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: palette.primarySoft, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 20, color: palette.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: palette.textSecondary)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogOutButton extends StatelessWidget {
  const _LogOutButton();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return OutlinedButton.icon(
      onPressed: context.read<SessionCubit>().signOut,
      style: OutlinedButton.styleFrom(
        foregroundColor: palette.error,
        minimumSize: const Size.fromHeight(52),
        side: BorderSide(color: palette.error.withValues(alpha: 0.3), width: 1.5),
        textStyle: const TextStyle(fontFamily: 'Muli', fontSize: 15, fontWeight: FontWeight.w800),
      ),
      icon: const Icon(Ionicons.logOutOutline, size: 20),
      label: const Text('Log out'),
    );
  }
}
