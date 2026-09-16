import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/config/theme/app_theme.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/session/session_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/saved_draft.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/bloc/settings/settings_cubit.dart';
import 'package:provider/single_child_widget.dart';

import 'mocks.dart';

/// Pumps [child] inside a themed [MaterialApp], optionally wrapped in bloc
/// providers, so widgets can read the palette and their cubits.
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  List<SingleChildWidget> providers = const [],
  Size? size,
}) async {
  if (size != null) useScreen(tester, size);
  await tester.pumpWidget(
    _wrapProviders(
      providers,
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: child),
      ),
    ),
  );
}
/// Sizes the test window like a phone (logical pixels) for the rest of the
/// test; the default 800×600 window cuts most screens short.
void useScreen(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}
/// Pumps a small [GoRouter] whose routes are given by path, so screens that
/// call `context.go` / `context.push` can be exercised and their navigation
/// asserted through the returned router.
Future<GoRouter> pumpRoutedApp(
  WidgetTester tester, {
  required Map<String, WidgetBuilder> routes,
  required String initialLocation,
  List<SingleChildWidget> providers = const [],
}) async {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      for (final entry in routes.entries)
        GoRoute(path: entry.key, builder: (context, _) => entry.value(context)),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    _wrapProviders(
      providers,
      MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
    ),
  );
  return router;
}
Widget _wrapProviders(List<SingleChildWidget> providers, Widget child) {
  if (providers.isEmpty) return child;
  return MultiBlocProvider(providers: providers, child: child);
}
/// Current location of a [GoRouter], for navigation assertions.
String locationOf(GoRouter router) =>
    router.routerDelegate.currentConfiguration.uri.toString();
/// A [SessionCubit] fed by a controller the test drives.

class SessionHarness {
  final MockWatchAuthStateUseCase watchAuthState = MockWatchAuthStateUseCase();
  final MockSignOutUseCase signOut = MockSignOutUseCase();
  final StreamController<UserEntity?> users = StreamController<UserEntity?>.broadcast();
  late final SessionCubit cubit;

  SessionHarness() {
    when(() => watchAuthState(any())).thenAnswer((_) => users.stream);
    when(() => signOut(any())).thenAnswer((_) async => const DataSuccess(null));
    cubit = SessionCubit(watchAuthState, signOut);
  }

  /// Emits a signed-in user. In a widget test follow it with `tester.pump()`;
  /// in a plain test with [flush].
  void signIn(UserEntity user) => users.add(user);

  void signOutUser() => users.add(null);

  Future<void> dispose() async {
    await cubit.close();
    await users.close();
  }
}

/// A [SettingsCubit] fed by a controller the test drives.
class SettingsHarness {
  final MockWatchSettingsUseCase watchSettings = MockWatchSettingsUseCase();
  final MockSaveSettingsUseCase saveSettings = MockSaveSettingsUseCase();
  final StreamController<AppSettings> settings = StreamController<AppSettings>.broadcast();
  late final SettingsCubit cubit;

  SettingsHarness() {
    when(() => watchSettings(any())).thenAnswer((_) => settings.stream);
    when(() => saveSettings(any())).thenAnswer((_) async => const DataSuccess(null));
    cubit = SettingsCubit(watchSettings, saveSettings);
  }

  Future<void> dispose() async {
    await cubit.close();
    await settings.close();
  }
}

/// Lets queued stream events reach their listeners by draining the event
/// queue, without waiting real time (plain tests only; inside `testWidgets`
/// use `tester.pump()` instead).
Future<void> flush() => pumpEventQueue();

/// Registers the fallback values mocktail needs for `any()` on these types.
void registerCommonFallbacks() {
  registerFallbackValue(const NoParams());
  registerFallbackValue(AppSettings.defaults);
  registerFallbackValue(const SavedDraft());
}
