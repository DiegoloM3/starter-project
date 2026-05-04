import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/locale_preference.dart';
import 'package:news_app_clean_architecture/features/settings/domain/use_cases/get_locale_preference.dart';
import 'package:news_app_clean_architecture/features/settings/domain/use_cases/set_locale_preference.dart';
import 'locale_event.dart';
import 'locale_state.dart';

/// Owns the global locale choice. Lives at the root of the widget tree so
/// `MaterialApp.router` can rebuild whenever the user picks a new language.
class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  final GetLocalePreferenceUseCase _getPreference;
  final SetLocalePreferenceUseCase _setPreference;

  LocaleBloc(this._getPreference, this._setPreference)
      : super(const LocaleState()) {
    on<LocaleInitialized>(_onInitialized);
    on<LocalePreferenceChanged>(_onChanged);
  }

  Future<void> _onInitialized(
    LocaleInitialized event,
    Emitter<LocaleState> emit,
  ) async {
    final result = await _getPreference.call(params: const NoParams());
    if (result is DataSuccess<LocalePreference>) {
      emit(state.copyWith(preference: result.data));
    }
    // On failure: keep the system default. A locale lookup failure is not
    // worth surfacing — the app stays usable in the device language.
  }

  Future<void> _onChanged(
    LocalePreferenceChanged event,
    Emitter<LocaleState> emit,
  ) async {
    // Optimistic: emit the new state before persistence finishes so the UI
    // flips immediately. If the write fails the state is still correct for
    // the current session; persistence will retry on next change.
    emit(state.copyWith(preference: event.preference));
    await _setPreference.call(params: event.preference);
  }
}
