import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';
import 'package:news_app_clean_architecture/features/settings/domain/repository/settings_repository.dart';

class SaveSettingsUseCase implements UseCase<DataState<void>, AppSettings> {
  final SettingsRepository _settingsRepository;

  const SaveSettingsUseCase(this._settingsRepository);

  @override
  Future<DataState<void>> call(AppSettings params) {
    return _settingsRepository.saveSettings(params);
  }
}
