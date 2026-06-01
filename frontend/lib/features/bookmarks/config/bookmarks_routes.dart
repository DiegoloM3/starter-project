import 'package:go_router/go_router.dart';
import 'package:tortutip/config/routes/app_routes.dart';
import 'package:tortutip/features/bookmarks/presentation/screens/bookmarks_screen.dart';

class BookmarksRoutes {
  BookmarksRoutes._();

  static final shellRoutes = <RouteBase>[
    GoRoute(
      path: AppRoutes.bookmarks,
      pageBuilder: (_, _) =>
          const NoTransitionPage(child: BookmarksScreen()),
    ),
  ];
}
