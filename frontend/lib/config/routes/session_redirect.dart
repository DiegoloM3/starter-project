import 'package:news_app_clean_architecture/config/routes/app_routes.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/session/session_cubit.dart';

/// Decides where the router must send the user given the session state.
///
/// Kept as a pure function so the rule is unit-testable without a router:
/// unknown session → splash; signed out → the welcome flow; signed in →
/// never the welcome flow.
abstract final class SessionRedirect {
  static String? resolve({
    required SessionState session,
    required String location,
  }) {
    return switch (session) {
      SessionUnknown() => location == AppRoutes.splash ? null : AppRoutes.splash,
      SessionUnauthenticated() =>
        AppRoutes.public.contains(location) ? null : AppRoutes.welcome,
      SessionAuthenticated() =>
        (location == AppRoutes.splash || AppRoutes.public.contains(location))
            ? AppRoutes.home
            : null,
    };
  }
}
