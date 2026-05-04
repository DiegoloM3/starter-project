import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/l10n/generated/app_localizations.dart';

/// Wraps a widget under test in a [MaterialApp] configured with the same
/// localization delegates as production. Use for any widget that calls
/// `AppLocalizations.of(context)` directly or transitively.
///
/// Defaults to English so test assertions can match the en.arb strings.
Widget wrapWithLocalizations(Widget child, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}
