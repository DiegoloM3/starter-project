import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/theme_preference.dart';
import 'package:news_app_clean_architecture/features/settings/domain/repository/settings_repository.dart';

class SaveThemePreferenceUseCase implements UseCase<DataState<void>, ThemePreferenceEntity> {
  final SettingsRepository _settingsRepository;

  SaveThemePreferenceUseCase(this._settingsRepository);

  @override
  Future<DataState<void>> call({ThemePreferenceEntity? params}) {
    return _settingsRepository.saveThemePreference(params!);
  }
}
