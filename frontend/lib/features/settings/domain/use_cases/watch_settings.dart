import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';
import 'package:news_app_clean_architecture/features/settings/domain/repository/settings_repository.dart';

class WatchSettingsUseCase implements StreamUseCase<AppSettings, NoParams> {
  final SettingsRepository _settingsRepository;

  const WatchSettingsUseCase(this._settingsRepository);

  @override
  Stream<AppSettings> call(NoParams params) {
    return _settingsRepository.watchSettings();
  }
}
