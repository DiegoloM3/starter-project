import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/config/auth_routes.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/articles/config/articles_routes.dart';
import '../../features/onboarding/config/onboarding_routes.dart';
import '../../features/onboarding/presentation/bloc/onboarding_cubit.dart';
import '../../features/onboarding/presentation/bloc/onboarding_state.dart';
import '../../features/bookmarks/config/bookmarks_routes.dart';
import '../../features/search/config/search_routes.dart';
import '../../features/bookmarks/presentation/bloc/bookmarks_cubit.dart';
import '../../features/explore/config/explore_routes.dart';
import '../../features/profile/config/profile_routes.dart';
import '../../injection/injection_container.dart';
import 'app_routes.dart';
import 'app_shell.dart';

class AppRouter {
  AppRouter._();

  static GoRouter createRouter(BuildContext context) {
    return GoRouter(
      initialLocation: AppRoutes.landing,
      debugLogDiagnostics: true,
      refreshListenable: _AuthNotifier(context.read<AuthBloc>()),
      redirect: (context, state) => _redirect(context, state),
      routes: [
        ...AuthRoutes.routes,
        ...SearchRoutes.routes,
        ...ArticlesRoutes.routes,
        ...ExploreRoutes.routes,
        ...ProfileRoutes.routes,

        // ShellRoute de onboarding — provee OnboardingCubit a las 3 pantallas
        ShellRoute(
          builder: (context, state, child) => BlocProvider(
            create: (_) {
              final authState = context.read<AuthBloc>().state;
              return sl<OnboardingCubit>()
                ..currentUser =
                    authState is AuthAuthenticated ? authState.user : null;
            },
            child: BlocListener<OnboardingCubit, OnboardingState>(
              listener: (context, onboardingState) {
                if (onboardingState is OnboardingComplete) {
                  context.read<AuthBloc>().add(const CheckAuthEvent());
                }
              },
              child: child,
            ),
          ),
          routes: OnboardingRoutes.routes,
        ),

        // Un único ShellRoute que mantiene AppShell vivo entre tabs
        ShellRoute(
          builder: (context, _, child) => BlocProvider(
            create: (ctx) {
              final authState = context.read<AuthBloc>().state;
              final userId =
                  authState is AuthAuthenticated ? authState.user.id : '';
              return sl<BookmarksCubit>()..loadBookmarks(userId);
            },
            child: AppShell(child: child),
          ),
          routes: [
            ...ArticlesRoutes.shellRoutes,
            ...ExploreRoutes.shellRoutes,
            ...BookmarksRoutes.shellRoutes,
          ],
        ),
      ],
      errorBuilder: (_, state) => Scaffold(
        body: Center(
          child: Text('Ruta no encontrada: ${state.error}'),
        ),
      ),
    );
  }

  static String? _redirect(BuildContext context, GoRouterState state) {
    final authState = context.read<AuthBloc>().state;
    final location = state.matchedLocation;

    final isOnLanding = location == AppRoutes.landing;
    final isOnLogin = location == AppRoutes.login;
    final isOnboarding = location.startsWith('/onboarding');

    final isAuthenticated = authState is AuthAuthenticated;

    if (authState is AuthLoading) return null;

    if (!isAuthenticated && !isOnLanding && !isOnLogin && !isOnboarding) {
      return AppRoutes.landing;
    }

    if (authState is AuthAuthenticated && (isOnLogin || isOnLanding)) {
      final user = authState.user;
      return user.role.isEmpty ? AppRoutes.onboardingCategories : AppRoutes.feed;
    }

    if (authState is AuthAuthenticated && isOnboarding) {
      if (authState.user.role.isNotEmpty) return AppRoutes.feed;
    }

    if (authState is AuthAuthenticated && !isOnboarding) {
      if (authState.user.role.isEmpty) return AppRoutes.onboardingCategories;
    }

    return null;
  }
}

class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(AuthBloc bloc) {
    bloc.stream.listen((_) => notifyListeners());
  }
}
