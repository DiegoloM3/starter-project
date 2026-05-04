import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/locale_preference.dart';

sealed class LocaleEvent extends Equatable {
  const LocaleEvent();

  @override
  List<Object?> get props => [];
}

/// Fired once at app startup to hydrate the bloc with the persisted choice.
final class LocaleInitialized extends LocaleEvent {
  const LocaleInitialized();
}

/// Fired by the SettingsPage when the user picks a different language.
final class LocalePreferenceChanged extends LocaleEvent {
  final LocalePreference preference;

  const LocalePreferenceChanged(this.preference);

  @override
  List<Object?> get props => [preference];
}
