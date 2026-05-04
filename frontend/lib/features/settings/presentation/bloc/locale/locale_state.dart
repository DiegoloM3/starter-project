import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/locale_preference.dart';

class LocaleState extends Equatable {
  final LocalePreference preference;

  const LocaleState({this.preference = LocalePreference.system});

  LocaleState copyWith({LocalePreference? preference}) =>
      LocaleState(preference: preference ?? this.preference);

  @override
  List<Object?> get props => [preference];
}
