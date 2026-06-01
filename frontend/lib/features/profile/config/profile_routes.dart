import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tortutip/config/routes/app_routes.dart';
import 'package:tortutip/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:tortutip/features/profile/presentation/screens/profile_screen.dart';
import 'package:tortutip/injection/injection_container.dart';

class ProfileRoutes {
  ProfileRoutes._();

  static final routes = <RouteBase>[
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<ProfileCubit>(),
        child: const ProfileScreen(),
      ),
    ),
  ];
}
