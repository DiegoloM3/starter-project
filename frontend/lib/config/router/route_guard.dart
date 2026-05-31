import 'package:flutter/widgets.dart';

/// Abstract interface for route guards.
///
/// Route guards are reusable, testable objects that encapsulate
/// authorization logic for routes. They can be composed and combined
/// to create complex authorization rules.
///
/// Example:
/// ```dart
/// class AdminRouteGuard implements RouteGuard {
///   @override
///   String? check(BuildContext context, Object? state) {
///     final user = context.read<AuthBloc>().state.user;
///     return user?.isAdmin == true ? null : '/unauthorized';
///   }
/// }
/// ```
abstract class RouteGuard {
  /// Checks if navigation to a route should be allowed.
  ///
  /// Returns `null` if access is granted.
  /// Returns a redirect path (String) if access is denied.
  ///
  /// The [context] provides access to BuildContext for reading BLoCs/providers.
  /// The [state] contains route information (path parameters, query params, etc).
  String? check(BuildContext context, Object? state);
}
