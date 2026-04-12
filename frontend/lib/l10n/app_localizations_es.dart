// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Noticias del Día';

  @override
  String get myArticles => 'Mis Artículos';

  @override
  String get savedArticles => 'Artículos Guardados';

  @override
  String get publishArticle => 'Publicar Artículo';

  @override
  String get editArticle => 'Editar Artículo';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String signedInAs(String name) {
    return 'Conectado como $name';
  }

  @override
  String signInFailed(String error) {
    return 'Error al iniciar sesión: $error';
  }

  @override
  String get publish => 'Publicar';

  @override
  String get publishing => 'Publicando…';

  @override
  String get saveChanges => 'Guardar Cambios';

  @override
  String get saving => 'Guardando…';

  @override
  String get titleLabel => 'Título';

  @override
  String get descriptionLabel => 'Descripción';

  @override
  String get contentLabel => 'Contenido';

  @override
  String get authorLabel => 'Autor';

  @override
  String get sourceLabel => 'Fuente (opcional)';

  @override
  String fieldRequired(String field) {
    return '$field es obligatorio';
  }

  @override
  String get pickThumbnail => 'Toca para elegir una imagen';

  @override
  String get thumbnailSelected => 'Imagen seleccionada. Toca para cambiar';

  @override
  String get tapToChange => 'Toca para cambiar';

  @override
  String get pleaseSelectThumbnail => 'Selecciona una imagen de portada';

  @override
  String get articlePublished => 'Artículo publicado exitosamente';

  @override
  String get articleUpdated => 'Artículo actualizado exitosamente';

  @override
  String publishFailed(String reason) {
    return 'Error: $reason';
  }

  @override
  String get noArticlesYet => 'Aún no hay artículos';

  @override
  String get tapPublishHint =>
      'Toca Publicar para compartir tu primera historia.';

  @override
  String noMatchFor(String query) {
    return 'Ningún artículo coincide con \"$query\"';
  }

  @override
  String get deleteArticle => '¿Eliminar artículo?';

  @override
  String get deleteConfirm => 'Esta acción no se puede deshacer.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get publishNewArticle => 'Publicar un nuevo artículo';

  @override
  String get editThisArticle => 'Editar este artículo';

  @override
  String get saveArticle => 'Guardar artículo';

  @override
  String get removeFromSaved => 'Quitar de guardados';

  @override
  String get clearSearch => 'Limpiar búsqueda';

  @override
  String get searchHint => 'Buscar título, descripción, autor…';

  @override
  String get searchLabel =>
      'Busca tus artículos por título, descripción o autor';

  @override
  String get retry => 'Reintentar';

  @override
  String get onboardingTitle1 => '¡Bienvenido, Periodista!';

  @override
  String get onboardingBody1 =>
      'Esta app te permite leer las últimas noticias del mundo y publicar tus propios artículos para que todos los vean.';

  @override
  String get onboardingTitle2 => 'Publica tus Historias';

  @override
  String get onboardingBody2 =>
      'Toca el botón + o visita \"Mis Artículos\" para escribir, editar y gestionar tus publicaciones con imágenes y sincronización en tiempo real.';

  @override
  String get onboardingTitle3 => 'Funciona Sin Internet';

  @override
  String get onboardingBody3 =>
      'Tus artículos se guardan localmente para que puedas verlos sin conexión. Las ediciones se sincronizan automáticamente cuando vuelvas a estar en línea.';

  @override
  String get skip => 'Omitir';

  @override
  String get next => 'Siguiente';

  @override
  String get getStarted => 'Comenzar';

  @override
  String get articleSaved => 'Artículo guardado exitosamente.';

  @override
  String get noSavedArticles => 'NO HAY ARTÍCULOS GUARDADOS';

  @override
  String get publishArticleA11y => 'Publicar artículo';

  @override
  String get publishingA11y => 'Publicando artículo, por favor espera';

  @override
  String get loginSubtitle =>
      'Inicia sesión con tu cuenta de Google para empezar a publicar artículos.';

  @override
  String get signInWithGoogle => 'Iniciar sesión con Google';

  @override
  String get signingIn => 'Iniciando sesión…';

  @override
  String get changeLanguage => 'Idioma';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';
}
