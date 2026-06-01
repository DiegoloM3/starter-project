import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tortutip/config/routes/app_routes.dart';
import 'package:tortutip/features/search/presentation/bloc/search_cubit.dart';
import 'package:tortutip/features/search/presentation/screens/search_screen.dart';
import 'package:tortutip/injection/injection_container.dart';

class SearchRoutes {
  SearchRoutes._();

  static final routes = <RouteBase>[
    GoRoute(
      path: AppRoutes.search,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: BlocProvider(
          create: (_) => sl<SearchCubit>(),
          child: const SearchScreen(),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final slide = Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          );
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slide, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 250),
      ),
    ),
  ];
}
