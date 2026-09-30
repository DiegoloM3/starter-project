import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';

/// A [MaterialApp] with the app's texts, in English unless another [locale] is given.
Widget localizedApp({required Widget home, Locale locale = const Locale('en'), ThemeData? theme}) {
  return MaterialApp(
    theme: theme,
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}
