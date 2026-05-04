import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/settings/data/data_sources/local/locale_preferences_service.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/locale_preference.dart';
import 'package:news_app_clean_architecture/features/settings/domain/repository/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final LocalePreferencesService _service;

  SettingsRepositoryImpl(this._service);

  @override
  Future<DataState<LocalePreference>> getLocalePreference() async {
    try {
      final code = await _service.getLanguageCode();
      return DataSuccess(LocalePreference.fromLanguageCode(code));
    } on AppException catch (e) {
      return DataFailed(e);
    } catch (e, st) {
      return DataFailed(
        UnknownException(message: e.toString(), cause: e, stackTrace: st),
      );
    }
  }

  @override
  Future<DataState<void>> setLocalePreference(
      LocalePreference preference) async {
    try {
      await _service.setLanguageCode(preference.languageCode);
      return const DataSuccess(null);
    } on AppException catch (e) {
      return DataFailed(e);
    } catch (e, st) {
      return DataFailed(
        UnknownException(message: e.toString(), cause: e, stackTrace: st),
      );
    }
  }
}
