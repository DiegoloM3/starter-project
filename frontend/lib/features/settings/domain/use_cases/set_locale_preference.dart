import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/locale_preference.dart';
import 'package:news_app_clean_architecture/features/settings/domain/repository/settings_repository.dart';

class SetLocalePreferenceUseCase
    implements UseCase<DataState<void>, LocalePreference> {
  final SettingsRepository _repository;

  SetLocalePreferenceUseCase(this._repository);

  @override
  Future<DataState<void>> call({LocalePreference? params}) {
    assert(params != null, 'LocalePreference must not be null');
    return _repository.setLocalePreference(params!);
  }
}
