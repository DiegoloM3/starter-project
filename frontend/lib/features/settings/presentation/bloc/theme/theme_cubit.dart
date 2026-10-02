import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/theme_preference.dart';
import 'package:news_app_clean_architecture/features/settings/domain/use_cases/get_theme_preference.dart';
import 'package:news_app_clean_architecture/features/settings/domain/use_cases/save_theme_preference.dart';

/// Theme the app is shown with.
class ThemeCubit extends Cubit<AppTheme> {
  final GetThemePreferenceUseCase _getThemePreferenceUseCase;
  final SaveThemePreferenceUseCase _saveThemePreferenceUseCase;

  ThemeCubit(this._getThemePreferenceUseCase, this._saveThemePreferenceUseCase)
      : super(ThemePreferenceEntity.defaultPreference.theme);

  /// Keeps the default theme when the saved preference cannot be read.
  Future<void> loadTheme() async {
    final dataState = await _getThemePreferenceUseCase();
    if (dataState is DataSuccess) emit(dataState.data!.theme);
  }

  /// Shows the new theme at once and keeps it for the next time the app opens.
  Future<void> selectTheme(AppTheme theme) async {
    emit(theme);
    await _saveThemePreferenceUseCase(params: ThemePreferenceEntity(theme));
  }
}
