import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/pages/login_screen.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/pages/register_screen.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/pages/welcome_screen.dart';

/// Path constants and route configuration for auth feature.
///
/// Follows modular routing pattern where each feature defines its own routes.
/// Uses extension methods for type-safe, decoupled navigation between features.
abstract final class AuthRoutes {
  AuthRoutes._();

  // ══════════════════════════════════════════════════════════════════
  // Path Constants
  // ══════════════════════════════════════════════════════════════════

  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/login/register';

  // ══════════════════════════════════════════════════════════════════
  // Route Configuration
  // ══════════════════════════════════════════════════════════════════

  /// Get auth feature routes.
  ///
  /// Auth pages use navigation extensions instead of callbacks,
  /// eliminating cross-feature coupling at the route level.
  ///
  /// [parentNavigatorKey] allows the app to control which navigator
  /// displays the auth routes. When provided, auth pages render on
  /// top of the current navigation (e.g. shell), enabling back navigation.
  ///
  /// Routes use relative paths and are designed to be nested as sub-routes
  /// of a shell branch (e.g. under the feed route at '/').
  static List<RouteBase> getRoutes({
    GlobalKey<NavigatorState>? parentNavigatorKey,
    void Function(BuildContext context)? onGuestContinue,
  }) {
    return [
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        parentNavigatorKey: parentNavigatorKey,
        builder: (context, _) =>
            WelcomeScreen(onGuestPressed: () => onGuestContinue?.call(context)),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        parentNavigatorKey: parentNavigatorKey,
        builder: (_, _) => const LoginScreen(),
        routes: [
          GoRoute(
            path: 'register',
            name: 'register',
            parentNavigatorKey: parentNavigatorKey,
            builder: (_, _) => const RegisterScreen(),
          ),
        ],
      ),
    ];
  }
}

// ══════════════════════════════════════════════════════════════════
// Navigation Extensions
// ══════════════════════════════════════════════════════════════════

/// Extension for type-safe navigation to auth screens.
///
/// This pattern eliminates string-based navigation and reduces coupling.
/// Features can navigate to auth without knowing internal route paths.
///
/// Example:
/// ```dart
/// // Instead of: context.go('/login')
/// context.goToLogin();
///
/// // Instead of: context.go('/register')
/// context.goToRegister();
/// ```
extension AuthNavigation on BuildContext {
  /// Navigate to welcome page.
  void goToWelcome() => go(AuthRoutes.welcome);

  /// Navigate to login page.
  void goToLogin() => go(AuthRoutes.login);

  /// Navigate to register page.
  void goToRegister() => go(AuthRoutes.register);
}
