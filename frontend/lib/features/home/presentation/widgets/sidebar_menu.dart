import 'package:awesome_drawer_bar/awesome_drawer_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.entity.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/user_avatar.dart';

/// Reusable drawer menu showing auth state and app destinations.
class SidebarMenu extends StatelessWidget {
  final VoidCallback? onItemSelected;

  const SidebarMenu({
    super.key,
    this.onItemSelected,
  });

  void _closeDrawer(BuildContext context) {
    onItemSelected?.call();
    AwesomeDrawerBar.of(context)?.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E24),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              const Divider(color: Colors.white24, thickness: 1),
              const SizedBox(height: 16),
              _buildMenuItem(
                context,
                icon: Ionicons.newspaperOutline,
                title: 'Daily News',
                onTap: () => _closeDrawer(context),
              ),
              _buildMenuItem(
                context,
                icon: Ionicons.bookmarkOutline,
                title: 'Saved Articles',
                onTap: () {
                  _closeDrawer(context);
                  Navigator.pushNamed(context, '/SavedArticles');
                },
              ),
              _buildMenuItem(
                context,
                icon: Ionicons.personOutline,
                title: 'My Articles',
                onTap: () {
                  _closeDrawer(context);
                  Navigator.pushNamed(context, '/MyArticles');
                },
              ),
              _buildMenuItem(
                context,
                icon: Ionicons.createOutline,
                title: 'Write Article',
                onTap: () {
                  _closeDrawer(context);
                  Navigator.pushNamed(context, '/CreateArticle');
                },
              ),
              const Spacer(),
              const Divider(color: Colors.white24, thickness: 1),
              const SizedBox(height: 12),
              _buildAuthAction(context),
            ],
          ),
        ),
      ),
    );
  }

  void _onHeaderTapped(BuildContext context, bool isLoggedIn) {
    _closeDrawer(context);
    Navigator.pushNamed(context, isLoggedIn ? '/EditProfile' : '/Login');
  }

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoggedIn = state is Authenticated;
        final user = isLoggedIn ? state.user : null;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _onHeaderTapped(context, isLoggedIn),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    _buildAvatar(isLoggedIn, user),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isLoggedIn ? Colors.greenAccent : Colors.grey,
                          border: Border.all(
                            color: const Color(0xFF1E1E24),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLoggedIn
                            ? (user!.displayName?.isNotEmpty == true
                                ? user.displayName!
                                : 'Reader')
                            : 'Guest Reader',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Butler',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isLoggedIn ? user!.email : 'Browse news anonymously',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isLoggedIn
                    ? Colors.greenAccent.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isLoggedIn
                      ? Colors.greenAccent.withValues(alpha: 0.4)
                      : Colors.white12,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Ionicons.ellipse,
                    size: 8,
                    color: isLoggedIn ? Colors.greenAccent : Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isLoggedIn ? 'LOGGED IN' : 'NOT LOGGED IN',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: isLoggedIn ? Colors.greenAccent : Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
          ],
          ),
        );
      },
    );
  }

  Widget _buildAvatar(bool isLoggedIn, UserEntity? user) {
    return UserAvatar(
      user: user,
      isLoggedIn: isLoggedIn,
      radius: 26,
      loggedOutLetter: 'G',
      photoBackground: Colors.white12,
      fallbackBackground: Colors.white12,
      fallbackTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: Icon(icon, color: Colors.white70, size: 22),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildAuthAction(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            leading: const Icon(Ionicons.logOutOutline,
                color: Colors.redAccent, size: 22),
            title: const Text(
              'Sign Out',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () {
              _closeDrawer(context);
              context.read<AuthBloc>().add(const LogoutRequested());
            },
          );
        }

        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _closeDrawer(context);
                  Navigator.pushNamed(context, '/Login');
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  _closeDrawer(context);
                  Navigator.pushNamed(context, '/Register');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Register',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
