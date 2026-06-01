import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tortutip/config/routes/app_routes.dart';
import 'package:tortutip/features/categories/domain/entities/category_entity.dart';
import 'package:tortutip/features/explore/presentation/bloc/explore_cubit.dart';
import 'package:tortutip/features/explore/presentation/bloc/category_list_cubit.dart';
import 'package:tortutip/features/explore/presentation/screens/explore_screen.dart';
import 'package:tortutip/features/explore/presentation/screens/category_list_screen.dart';
import 'package:tortutip/injection/injection_container.dart';

class ExploreRoutes {
  ExploreRoutes._();

  // Fuera del shell — sin TabBar
  static final routes = <RouteBase>[
    GoRoute(
      path: '/explore/category/:categoryId',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<CategoryListCubit>(),
        child: CategoryListScreen(
            category: state.extra as CategoryEntity),
      ),
    ),
  ];

  // Inside the shell — with TabBar
  static final shellRoutes = <RouteBase>[
    GoRoute(
      path: AppRoutes.explore,
      pageBuilder: (context, _) => NoTransitionPage(
        child: BlocProvider(
          create: (_) => sl<ExploreCubit>(),
          child: const ExploreScreen(),
        ),
      ),
    ),
  ];
}
