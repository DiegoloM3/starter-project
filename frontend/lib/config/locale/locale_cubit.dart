import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The app's language. Same reasoning as ThemeCubit for skipping the
/// use_case/repository layers: in-memory UI state with no I/O behind it.
/// Starts in English, the language the app is written in.
class LocaleCubit extends Cubit<Locale> {
  static const supportedLocales = [Locale('en'), Locale('es')];

  LocaleCubit() : super(supportedLocales.first);

  void select(Locale locale) => emit(locale);
}
