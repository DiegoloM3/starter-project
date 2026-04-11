// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get dailyNewsTitle => 'Noticias del día';

  @override
  String get articleTitle => 'Artículo';

  @override
  String get savedArticlesTitle => 'Artículos guardados';

  @override
  String get noSavedArticles => 'No hay artículos guardados';

  @override
  String get articleSavedSuccess => 'Artículo guardado exitosamente.';

  @override
  String get uploadImage => 'Subir imagen';
}
