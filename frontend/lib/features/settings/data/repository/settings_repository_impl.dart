import 'dart:async';

import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/settings/data/data_sources/local/settings_local_data_source.dart';
import 'package:news_app_clean_architecture/features/settings/data/models/app_settings_model.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';
import 'package:news_app_clean_architecture/features/settings/domain/repository/settings_repository.dart';

/// Settings belong to the signed-in account. When the session changes, the
/// stream re-emits what that account had chosen, or the defaults for one that
/// never chose anything; signing out shows the defaults.
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource _local;
  final AuthRepository _auth;
  final StreamController<AppSettings> _changes = StreamController<AppSettings>.broadcast();
  late final StreamSubscription<UserEntity?> _session;

  SettingsRepositoryImpl(this._local, this._auth) {
    _session = _auth.watchAuthState().listen((user) => _changes.add(_read(_scopeOf(user))));
  }

  static const String guestScope = 'guest';

  static String _scopeOf(UserEntity? user) => user?.id ?? guestScope;

  String get _scope => _scopeOf(_auth.currentUser);

  AppSettings _read(String scope) => _local.read(scope).toEntity();

  @override
  Stream<AppSettings> watchSettings() async* {
    yield _read(_scope);
    yield* _changes.stream;
  }

  @override
  Future<AppSettings> getSettings() => Future.value(_read(_scope));

  @override
  Future<DataState<void>> saveSettings(AppSettings settings) => runGuarded(
        () async {
          await _local.write(_scope, AppSettingsModel.fromEntity(settings));
          _changes.add(settings);
        },
        onError: (_) => const Failure.unknown("Your settings couldn't be saved."),
      );

  /// The app keeps one instance for its whole life; tests close it.
  Future<void> dispose() async {
    await _session.cancel();
    await _changes.close();
  }
}
