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

  @override
  String get newNewsTitle => 'Nueva Noticia';

  @override
  String get editNewsTitle => 'Editar Noticia';

  @override
  String get formTitleLabel => 'Título';

  @override
  String get formSectionLabel => 'Sección';

  @override
  String get formImagesLabel => 'Imágenes';

  @override
  String get formBodyLabel => 'Contenido';

  @override
  String get formTitleHint => 'Escribe el título de la noticia...';

  @override
  String get formBodyHint => 'Escribe el contenido de la noticia aquí...';

  @override
  String formImageHintCreate(int max) {
    return 'Agrega hasta $max fotos';
  }

  @override
  String formImageHintEdit(int count, int max) {
    return '$count de $max fotos';
  }

  @override
  String get publishButton => 'Publicar Noticia';

  @override
  String get saveChangesButton => 'Guardar Cambios';

  @override
  String get discardChangesTitle => '¿Descartar cambios?';

  @override
  String get discardChangesBody =>
      'Tienes cambios sin guardar. ¿Deseas descartarlos?';

  @override
  String get discardAction => 'Descartar';

  @override
  String get deleteNewsTitle => '¿Eliminar noticia?';

  @override
  String get deleteNewsBody => 'Esta acción no se puede deshacer.';

  @override
  String get deleteAction => 'Eliminar';

  @override
  String get imageSourceCamera => 'Cámara';

  @override
  String get imageSourceGallery => 'Galería';

  @override
  String get genericError => 'Ocurrió un error';
}
