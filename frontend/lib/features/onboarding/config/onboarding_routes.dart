import 'package:go_router/go_router.dart';

import '../../../config/routes/app_routes.dart';
import '../presentation/screens/onboarding_categories_screen.dart';
import '../presentation/screens/onboarding_details_screen.dart';
import '../presentation/screens/onboarding_role_screen.dart';

class OnboardingRoutes {
  OnboardingRoutes._();

  static final routes = <RouteBase>[
    GoRoute(
      path: AppRoutes.onboardingCategories,
      builder: (_, _) => const OnboardingCategoriesScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboardingRole,
      builder: (_, _) => const OnboardingRoleScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboardingDetails,
      builder: (_, _) => const OnboardingDetailsScreen(),
    ),
  ];
}
