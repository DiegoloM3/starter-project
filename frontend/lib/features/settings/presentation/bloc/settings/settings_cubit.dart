import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';
import 'package:news_app_clean_architecture/features/settings/domain/use_cases/save_settings.dart';
import 'package:news_app_clean_architecture/features/settings/domain/use_cases/watch_settings.dart';

part 'settings_state.dart';

/// App-wide preferences: theme, text size and the default feed filters.
///
/// Changes are applied optimistically so the UI answers at once; the watched
/// stream then confirms them, and a rejected save is rolled back and reported
/// through [SettingsState.saveFailure].
class SettingsCubit extends Cubit<SettingsState> {
  final WatchSettingsUseCase _watchSettings;
  final SaveSettingsUseCase _saveSettings;
  StreamSubscription<AppSettings>? _subscription;

  SettingsCubit(this._watchSettings, this._saveSettings)
      : super(const SettingsState()) {
    _subscription = _watchSettings(const NoParams()).listen(
      (settings) => emit(state.copyWith(settings: settings)),
    );
  }

  Future<void> setThemeMode(AppThemeMode mode) =>
      _save(state.settings.copyWith(themeMode: mode));

  Future<void> setTextSize(TextSizePreference size) =>
      _save(state.settings.copyWith(textSize: size));

  Future<void> increaseTextSize() => setTextSize(state.settings.textSize.larger);

  Future<void> decreaseTextSize() => setTextSize(state.settings.textSize.smaller);

  Future<void> setDefaultCategory(NewsCategory category) =>
      _save(state.settings.copyWith(defaultCategory: category));

  Future<void> setSpeechRate(SpeechRatePreference rate) =>
      _save(state.settings.copyWith(speechRate: rate));

  Future<void> _save(AppSettings next) async {
    if (next == state.settings) return;

    final previous = state.settings;
    emit(state.copyWith(settings: next));

    final result = await _saveSettings(next);
    if (result is DataFailed<void> && !isClosed) {
      emit(state.copyWith(settings: previous, saveFailure: result.failure));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
