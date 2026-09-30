import 'package:flutter/widgets.dart';

import 'generated/app_localizations.dart';

export 'generated/app_localizations.dart';

extension AppLocalizationsOfContext on BuildContext {
  /// The texts of the app in the phone's language (English or Spanish, English otherwise).
  AppLocalizations get l10n => AppLocalizations.of(this);
}
