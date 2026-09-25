import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

/// `context.l10n.profileTitle` instead of
/// `AppLocalizations.of(context).profileTitle` on every string.
extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
