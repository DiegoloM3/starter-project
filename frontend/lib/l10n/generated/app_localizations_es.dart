import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get topNewsTab => 'Destacadas';

  @override
  String get communityTab => 'Comunidad';

  @override
  String get publishAnArticle => 'Publicar un artículo';

  @override
  String get savedArticles => 'Artículos guardados';

  @override
  String get savedArticlesTitle => 'Artículos guardados';

  @override
  String get noSavedArticles => 'NO HAY ARTÍCULOS GUARDADOS';

  @override
  String get tryAgain => 'Reintentar';

  @override
  String get back => 'Atrás';

  @override
  String get articlePublished => 'Tu artículo se ha publicado.';

  @override
  String get articleSaved => 'Artículo guardado.';

  @override
  String get articlesCouldNotLoad => 'No se pudieron cargar los artículos.';

  @override
  String get noArticlesYet => 'Aún no hay artículos. ¡Sé el primer periodista en publicar uno!';

  @override
  String get writeAnArticle => 'Escribir un artículo';

  @override
  String readingTime(int minutes) {
    return '$minutes min de lectura';
  }

  @override
  String get listenToArticle => 'Escuchar este artículo';

  @override
  String get stopReading => 'Detener la lectura';

  @override
  String get readingProgress => 'Progreso de la lectura';

  @override
  String get cannotReadAloud => 'Este dispositivo no puede leer en voz alta. Revisa los ajustes de texto a voz de tu teléfono.';

  @override
  String get publishArticle => 'Publicar artículo';

  @override
  String get publishing => 'Publicando…';

  @override
  String get titleLabel => 'Título';

  @override
  String get titleHint => 'Escribe aquí tu título…';

  @override
  String get authorLabel => 'Escrito por';

  @override
  String get authorHint => 'Tu nombre';

  @override
  String get contentHint => 'Escribe aquí tu artículo… Usa la barra para texto en **negrita** y ## subtítulos.';

  @override
  String get write => 'Escribir';

  @override
  String get preview => 'Vista previa';

  @override
  String get nothingToPreview => '*Aún no hay nada que mostrar.*';

  @override
  String get bold => 'Negrita';

  @override
  String get italic => 'Cursiva';

  @override
  String get subtitle => 'Subtítulo';

  @override
  String get bulletedList => 'Lista con viñetas';

  @override
  String writingStats(int words, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      words,
      locale: localeName,
      other: '$words palabras',
      one: '1 palabra',
    );
    return '$_temp0 · $minutes min de lectura';
  }

  @override
  String charactersUsed(int length, int maxLength) {
    return '$length de $maxLength caracteres usados';
  }

  @override
  String get attachImage => 'Adjuntar imagen';

  @override
  String get changeImage => 'Cambiar imagen';

  @override
  String get articleImageHint => 'Imagen del artículo. Toca dos veces para elegir otra.';

  @override
  String get draftRestored => 'Recuperamos el artículo que dejaste a medias.';

  @override
  String get startOver => 'Empezar de nuevo';

  @override
  String get saveDraftQuestion => '¿Guardar este artículo como borrador?';

  @override
  String get saveDraftExplanation => 'Podrás terminarlo la próxima vez que toques +.';

  @override
  String get keepWriting => 'Seguir escribiendo';

  @override
  String get discard => 'Descartar';

  @override
  String get saveDraft => 'Guardar borrador';

  @override
  String get publishFailed => 'No se pudo publicar tu artículo. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get galleryUnavailable => 'No se pudo abrir la galería. Revisa los permisos de la app e inténtalo de nuevo.';

  @override
  String get retry => 'Reintentar';

  @override
  String get titleEmpty => 'Añade un título a tu artículo.';

  @override
  String titleTooLong(int maxLength) {
    final intl.NumberFormat maxLengthNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String maxLengthString = maxLengthNumberFormat.format(maxLength);

    return 'El título puede tener hasta $maxLengthString caracteres.';
  }

  @override
  String get authorEmpty => 'Firma el artículo con tu nombre.';

  @override
  String authorTooLong(int maxLength) {
    final intl.NumberFormat maxLengthNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String maxLengthString = maxLengthNumberFormat.format(maxLength);

    return 'Tu nombre puede tener hasta $maxLengthString caracteres.';
  }

  @override
  String get contentEmpty => 'Escribe tu artículo antes de publicarlo.';

  @override
  String contentTooLong(int maxLength) {
    final intl.NumberFormat maxLengthNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String maxLengthString = maxLengthNumberFormat.format(maxLength);

    return 'El artículo puede tener hasta $maxLengthString caracteres.';
  }

  @override
  String get thumbnailMissing => 'Adjunta una imagen para ilustrar tu artículo.';

  @override
  String get thumbnailUnsupportedFormat => 'Elige una imagen JPG, PNG o WebP.';

  @override
  String thumbnailTooLarge(int megabytes) {
    return 'Elige una imagen de $megabytes MB o menos.';
  }
}
