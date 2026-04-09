import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/config/routes/paths.dart';
import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/features/login/presentation/bloc/login_bloc.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

class GoRouterConfig {
  GoRouterConfig({required GlobalKey<NavigatorState> navigatorKey}) {
    _goRouter = _routes(navigatorKey);
  }

  late final GoRouter _goRouter;

  GoRouter get routes => _goRouter;

  GoRouter _routes(GlobalKey<NavigatorState> navigatorKey) => GoRouter(
        navigatorKey: navigatorKey,
        initialLocation: '/',
        routes: AppRoutes.list,
        refreshListenable: GoRouterRefreshStream(sl<LoginBloc>()
            .stream
            .distinct((prev, curr) => prev.runtimeType == curr.runtimeType)),
        redirect: (context, state) {
          final loginState = context.read<LoginBloc>().state;

          if ((loginState is! LoggedIn && loginState is! LoginInitial) &&
              !(state.fullPath == Paths.login.path ||
                  state.fullPath == Paths.register.path)) {
            return Paths.login.path;
          } else if (loginState is LoggedIn &&
              (state.fullPath == Paths.login.path ||
                  state.fullPath == Paths.initial.path ||
                  state.fullPath == Paths.register.path)) {
            return Paths.dailyNews.path;
          } else {
            return null;
          }
        },
      );
}

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
