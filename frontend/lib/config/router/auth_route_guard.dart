import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'route_guard.dart';

/// Route guard that checks authentication status.
///
/// This guard is reusable across any route that requires authentication.
/// It uses a callback to determine auth status and the redirect path,
/// allowing it to work with any state management solution (BLoC, Provider, etc.).
///
/// **Design Decision:**
/// Uses callbacks instead of directly depending on flutter_bloc to keep
/// the guard more flexible and testable.
///
/// **Usage:**
/// ```dart
/// final authGuard = AuthRouteGuard(
///   isAuthenticated: (context) {
///     final authState = context.read<AuthBloc>().state;
///     return authState is AuthAuthenticated;
///   },
///   redirectPath: '/login',
/// );
///
/// GoRoute(
///   path: '/protected',
///   redirect: (context, state) => authGuard.check(context, state),
///   builder: (context, state) => ProtectedPage(),
/// )
/// ```
class AuthRouteGuard implements RouteGuard {
  /// Creates an auth route guard.
  ///
  /// [isAuthenticated] is a callback that checks if the user is authenticated.
  /// [redirectPath] is the path to redirect to if not authenticated.
  AuthRouteGuard({required this.isAuthenticated, required this.redirectPath});

  /// Callback to check if user is authenticated.
  final bool Function(BuildContext context) isAuthenticated;

  /// Path to redirect to when user is not authenticated.
  final String redirectPath;

  @override
  String? check(BuildContext context, Object? state) {
    if (isAuthenticated(context)) {
      return null;
    }

    final from = state is GoRouterState ? state.uri.toString() : null;
    if (from == null || from == redirectPath) {
      return redirectPath;
    }

    return Uri(path: redirectPath, queryParameters: {'from': from}).toString();
  }
}
