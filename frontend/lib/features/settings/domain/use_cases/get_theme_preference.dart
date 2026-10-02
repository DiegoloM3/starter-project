import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/theme_preference.dart';
import 'package:news_app_clean_architecture/features/settings/domain/repository/settings_repository.dart';

class GetThemePreferenceUseCase implements UseCase<DataState<ThemePreferenceEntity>, void> {
  final SettingsRepository _settingsRepository;

  GetThemePreferenceUseCase(this._settingsRepository);

  @override
  Future<DataState<ThemePreferenceEntity>> call({void params}) {
    return _settingsRepository.getThemePreference();
  }
}
