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

  @override
  String get myNewsTab => 'Mis Noticias';

  @override
  String get worldNewsTab => 'Noticias del Mundo';

  @override
  String get newsLoadError => 'Error al cargar noticias';

  @override
  String get retryAction => 'Reintentar';

  @override
  String get noNewsAvailable => 'No hay noticias disponibles';

  @override
  String get profileButtonLabel => 'Perfil';

  @override
  String get addNewsButtonLabel => 'Agregar noticia';

  @override
  String get searchNewsHint => 'Buscar noticias...';

  @override
  String get cancelAction => 'Cancelar';

  @override
  String get searchButtonLabel => 'Buscar';

  @override
  String get sectionAll => 'Todos';

  @override
  String get sectionPolitics => 'Política';

  @override
  String get sectionWeather => 'Clima';

  @override
  String get sectionSports => 'Deportes';

  @override
  String get sectionArts => 'Artes';

  @override
  String get sectionCrime => 'Policiaca';
}
