import 'package:go_router/go_router.dart';

import '../../../config/routes/app_routes.dart';
import '../presentation/screens/landing_screen.dart';
import '../presentation/screens/login_screen.dart';

class AuthRoutes {
  AuthRoutes._();

  static final routes = <RouteBase>[
    GoRoute(
      path: AppRoutes.landing,
      builder: (_, _) => const LandingScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (_, _) => const LoginScreen(),
    ),
  ];
}
