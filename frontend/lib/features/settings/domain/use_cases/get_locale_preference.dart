import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/locale_preference.dart';
import 'package:news_app_clean_architecture/features/settings/domain/repository/settings_repository.dart';

class GetLocalePreferenceUseCase
    implements UseCase<DataState<LocalePreference>, NoParams> {
  final SettingsRepository _repository;

  GetLocalePreferenceUseCase(this._repository);

  @override
  Future<DataState<LocalePreference>> call({NoParams? params}) {
    return _repository.getLocalePreference();
  }
}
