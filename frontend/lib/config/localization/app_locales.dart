import 'package:flutter/widgets.dart';

/// Which language the app runs in, decided from the device's own setting.
///
/// The policy is the one recorded as decision #59: Spanish on a Spanish
/// device, English everywhere else.
///
/// Flutter's default resolution does not implement that. Android hands over a
/// whole ordered *list* of languages, and the default walks it until it finds
/// one the app supports — so a phone set to French, with Spanish still sitting
/// further down the list from before, came up in Spanish. The person had
/// changed their phone to French and the app ignored them, because a language
/// they were no longer using happened to be one of the two it speaks.
///
/// Only the first entry is read here: that is the language of the device, and
/// anything but Spanish falls back to English rather than to whatever else
/// the list happens to contain.
abstract final class AppLocales {
  static const Locale english = Locale('en');
  static const Locale spanish = Locale('es');

  /// Answers [MaterialApp.localeListResolutionCallback].
  static Locale resolve(List<Locale>? preferred, Iterable<Locale> supported) {
    if (preferred == null || preferred.isEmpty) {
      return english;
    }

    return preferred.first.languageCode == spanish.languageCode
        ? spanish
        : english;
  }
}
