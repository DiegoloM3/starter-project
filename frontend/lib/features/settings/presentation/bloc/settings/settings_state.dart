part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  final AppSettings settings;

  /// Set when the last save was rejected; cleared by the next change.
  final Failure? saveFailure;

  const SettingsState({
    this.settings = AppSettings.defaults,
    this.saveFailure,
  });

  SettingsState copyWith({AppSettings? settings, Failure? saveFailure}) {
    return SettingsState(
      settings: settings ?? this.settings,
      saveFailure: saveFailure,
    );
  }

  @override
  List<Object?> get props => [settings, saveFailure];
}
