import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

/// The localisation wiring every test `MaterialApp` needs.
///
/// Screens read their text through `AppLocalizations.of(context)`, which
/// throws when no delegate provided it. The real app sets this up once in
/// `main.dart`; a widget test builds its own app, so it has to say the same
/// thing. Tests run under `en`, so assertions stay in English.
const testLocalizationDelegates = AppLocalizations.localizationsDelegates;
const testSupportedLocales = AppLocalizations.supportedLocales;
