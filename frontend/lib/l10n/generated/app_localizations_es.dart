// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'App de Noticias';

  @override
  String get navHome => 'Inicio';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get homeTitle => 'Noticias del día';

  @override
  String get filterAll => 'Todo';

  @override
  String get filterForYou => 'Para ti';

  @override
  String get filterForYouEmpty =>
      'Guarda algunos artículos y te recomendaremos más como esos.';

  @override
  String get filterForYouLoading => 'Buscando recomendaciones…';

  @override
  String get filterHealth => 'Salud';

  @override
  String get filterNews => 'Noticias';

  @override
  String get filterCommunity => 'Comunidad';

  @override
  String get searchHint => 'Buscar artículos…';

  @override
  String get feedEmpty => 'No se encontraron artículos.';

  @override
  String get semanticSearchUnavailable =>
      'Búsqueda semántica no disponible — mostrando coincidencias por palabra clave.';

  @override
  String get myArticlesTitle => 'Mis artículos';

  @override
  String get savedArticlesTitle => 'Artículos guardados';

  @override
  String get articleNewsApiTitle => 'Artículo de NewsAPI';

  @override
  String get articleCommunityTitle => 'Artículo de la comunidad';

  @override
  String get savedArticlesEmpty => 'Aún no hay artículos guardados.';

  @override
  String get removeAction => 'Quitar';

  @override
  String get articleDetailNotFound => 'Artículo no encontrado.';

  @override
  String get articleDetailLoadError =>
      'No se pudo cargar el artículo. Regresa e inténtalo de nuevo.';

  @override
  String get articleSavedSuccess => 'Artículo guardado correctamente.';

  @override
  String get newArticleTitle => 'Nuevo artículo';

  @override
  String get editArticleTitle => 'Editar artículo';

  @override
  String get saveDraftAction => 'Guardar borrador';

  @override
  String get publishedSnack => 'Publicado';

  @override
  String get savedSnack => 'Guardado';

  @override
  String get publishingOverlay => 'Publicando tu artículo…';

  @override
  String get deleteArticleTitle => '¿Eliminar artículo?';

  @override
  String deleteArticleConfirm(String title) {
    return '¿Seguro que quieres eliminar \"$title\"?';
  }

  @override
  String get deleteDraftTitle => '¿Eliminar borrador?';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get draftBadge => 'Borrador';

  @override
  String get thumbnailPickerTitle => 'Elige una miniatura';

  @override
  String get thumbnailFromGallery => 'Desde galería';

  @override
  String get thumbnailFromCamera => 'Desde cámara';

  @override
  String get fieldCategory => 'Categoría';

  @override
  String get fieldTags => 'Etiquetas';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get menuMyArticles => 'Mis artículos';

  @override
  String get menuSignOut => 'Cerrar sesión';

  @override
  String get authSignInTitle => 'Iniciar sesión';

  @override
  String get authSignInAction => 'Entrar';

  @override
  String get authSignUpTitle => 'Crear cuenta';

  @override
  String get authSignUpAction => 'Crear cuenta';

  @override
  String get authEmailLabel => 'Correo';

  @override
  String get authPasswordLabel => 'Contraseña';

  @override
  String get authDisplayNameLabel => 'Nombre de usuario';

  @override
  String get authForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get authResetPasswordTitle => 'Restablecer contraseña';

  @override
  String get authResetPasswordSend => 'Enviar correo';

  @override
  String get authResetPasswordSent => 'Correo de restablecimiento enviado';

  @override
  String get authNoAccount => '¿No tienes cuenta?';

  @override
  String get authHaveAccount => '¿Ya tienes cuenta?';

  @override
  String get authGoogleSignIn => 'Iniciar sesión con Google';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsLanguageSection => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Predeterminado del sistema';

  @override
  String get settingsLanguageSystemSubtitle =>
      'Seguir el idioma del dispositivo';

  @override
  String get settingsPermissionsSection => 'Permisos que usa la app';

  @override
  String get settingsPermissionsHelp =>
      'Estos permisos se solicitan solo cuando una función específica los necesita.';

  @override
  String get permissionCameraTitle => 'Cámara';

  @override
  String get permissionCameraReason =>
      'Tomar una foto para usarla como miniatura de tu artículo.';

  @override
  String get permissionPhotosTitle => 'Galería';

  @override
  String get permissionPhotosReason =>
      'Elegir una foto existente como miniatura de tu artículo.';

  @override
  String get permissionInternetTitle => 'Internet';

  @override
  String get permissionInternetReason =>
      'Obtener noticias, sincronizar tus artículos y realizar búsqueda semántica.';
}
