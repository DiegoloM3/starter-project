// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get landingTagline => 'BIENESTAR · CONOCIMIENTO · COMUNIDAD';

  @override
  String get landingHeroLine1 => 'Un tip al día.';

  @override
  String get landingHeroLine2 => 'Una vida mejor.';

  @override
  String get landingTermsPrefix => 'Si continuas, aceptas los ';

  @override
  String get landingTermsOfService => 'Terminos del servicio';

  @override
  String get landingTermsMiddle =>
      ' de TortuTip y confirmas que has leido nuestra ';

  @override
  String get landingPrivacyPolicy => 'Politica de privacidad';

  @override
  String get loginTitle => 'Bienvenido a TortuTip';

  @override
  String get loginSubtitle => 'Protegemos tu privacidad. Solo Google.';

  @override
  String get onboardingCategoriesTitle => 'Personaliza tu feed';

  @override
  String get onboardingCategoriesSubtitle =>
      'Selecciona los temas que más te interesan para adaptar tu experiencia un 1% cada día.';

  @override
  String get onboardingNext => 'Siguiente →';

  @override
  String get onboardingRoleWriter => 'Compartir tips';

  @override
  String get onboardingRoleReader => 'Leer tips';

  @override
  String get onboardingDetailsTitle => 'Cuéntanos un poco más';

  @override
  String get onboardingDetailsGender => 'Género';

  @override
  String get onboardingDetailsAgeRange => 'Rango de edad';

  @override
  String get onboardingGenderFemale => 'Femenino';

  @override
  String get onboardingGenderMale => 'Masculino';

  @override
  String get onboardingGenderOther => 'Otros';

  @override
  String get onboardingGenderPreferNotToSay => 'Prefiero no decirlo';

  @override
  String get onboardingFinish => 'Finalizar →';

  @override
  String get feedTitle => 'TortuTip';

  @override
  String get feedNoArticles => 'No hay artículos disponibles';

  @override
  String get feedStartOver => 'Iniciar de nuevo';

  @override
  String get feedReadAll => '¡Has leído todo!';

  @override
  String get feedReadAllSubtitle => 'Empieza de nuevo con un orden aleatorio';

  @override
  String get articleDetailTitle => 'Detalle';

  @override
  String get articleDetailRetry => 'Reintentar';

  @override
  String get createArticleDiscardTitle => '¿Descartar artículo?';

  @override
  String get createArticleDiscardContent =>
      'Tu artículo se perderá si sales ahora.';

  @override
  String get createArticleKeepEditing => 'Seguir editando';

  @override
  String get createArticleDiscard => 'Descartar';

  @override
  String get createArticleCameraOption => 'Cámara';

  @override
  String get createArticleLibraryOption => 'Biblioteca de fotos';

  @override
  String get createArticleNotAuthError => 'Error: usuario no autenticado';

  @override
  String get createArticlePreview => 'Vista previa';

  @override
  String get createArticlePublish => 'Publicar';

  @override
  String get createArticleUpdate => 'Actualizar';

  @override
  String get createArticleChooseCategory => 'Elegir Categoría';

  @override
  String get createArticleTitleHint => 'Escribe tu título...';

  @override
  String get createArticleBodyHint =>
      'Empieza tu camino aquí... comparte tu sabiduría con el mundo.';

  @override
  String get categoryListTitle => 'Categoría';

  @override
  String get categoryListEmpty => 'Sin artículos';

  @override
  String get categoryListEmptySubtitle =>
      'Aún no hay artículos publicados en esta categoría.';

  @override
  String get categoryListLoadMore => 'Cargar más';

  @override
  String get bookmarksTitle => 'Mis Marcadores';

  @override
  String get bookmarksEmpty => 'Aún no tienes marcadores';

  @override
  String get bookmarksEmptySubtitle =>
      'Guarda artículos que te interesen para leerlos después.';

  @override
  String get bookmarksLoadMore => 'Cargar más';

  @override
  String get bookmarksRemoved => 'Eliminado de marcadores';

  @override
  String get bookmarksUndo => 'Deshacer';

  @override
  String get profileTitle => 'Mi Perfil';

  @override
  String get profileUpdated => 'Perfil actualizado';

  @override
  String get profileMyTips => 'Mis Tips';

  @override
  String get editProfileTitle => 'Editar Perfil';

  @override
  String get editProfileCamera => 'Cámara';

  @override
  String get editProfileGallery => 'Galería';

  @override
  String get editProfileSignOutTitle => 'Cerrar sesión';

  @override
  String get editProfileSignOutContent =>
      '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get editProfileSignOutConfirm => 'Cerrar sesión';

  @override
  String get editProfileDeleteAccountTitle => 'Eliminar cuenta';

  @override
  String get editProfileDeleteAccountConfirm => 'Eliminar';

  @override
  String get editProfileCancel => 'Cancelar';

  @override
  String get editProfileNameHint => 'Tu nombre';

  @override
  String get editProfileBioHint => 'Cuéntanos sobre ti';

  @override
  String get editProfileSaveChanges => 'Guardar Cambios';

  @override
  String get articleMenuView => 'Ver';

  @override
  String get articleMenuEdit => 'Editar';

  @override
  String get articleMenuDelete => 'Eliminar';

  @override
  String get articleDeleteTitle => 'Eliminar artículo';

  @override
  String get articleDeleteContent =>
      '¿Seguro que quieres eliminar este artículo? Esta acción no se puede deshacer.';

  @override
  String get articleDeleteCancel => 'Cancelar';

  @override
  String get searchRecentSearches => 'Búsquedas recientes';

  @override
  String get searchStartSearching => 'Empieza a buscar...';

  @override
  String get searchNoArticles => 'No se encontraron artículos';

  @override
  String get searchNoCategories => 'No se encontraron categorías';

  @override
  String get searchCancel => 'Cancelar';

  @override
  String get searchBarHint => 'Buscar artículos, categorías...';

  @override
  String get feedCardUnknownAuthor => 'Autor desconocido';

  @override
  String feedCardReadTime(int minutes) {
    return '$minutes min de lectura';
  }

  @override
  String get feedCardReadMore => 'Saber más →';

  @override
  String get feedForYou => 'Para ti';

  @override
  String get articleSaved => 'Guardado';

  @override
  String get articleSave => 'Guardar';

  @override
  String get coverVerticalLabel => 'PORTADA VERTICAL\n(FEED)';

  @override
  String get coverHorizontalLabel => 'PORTADA HORIZONTAL\n(ARTÍCULO)';

  @override
  String get errorGeneric => 'Algo salió mal. Inténtalo de nuevo';

  @override
  String get errorNoConnection => 'Sin conexión. Inténtalo de nuevo';

  @override
  String get discard => 'Descartar';

  @override
  String get bookmarksExploreAction => 'Explorar artículos';

  @override
  String get bookmarksSectionLabel => '— GUARDADOS';

  @override
  String get bookmarksSectionTitle => 'Mis Marcadores';

  @override
  String get bookmarksSectionSubtitle =>
      'Los artículos que has guardado para leer más tarde.';

  @override
  String get bookmarksRetry => 'Reintentar';

  @override
  String get feedRetry => 'Reintentar';

  @override
  String get exploreKaiaTitle => 'Kaia, tu tortuga 🐢';

  @override
  String get exploreCategoriesTitle => 'Categorías';

  @override
  String get exploreSearchHint => 'Buscar artículos...';

  @override
  String exploreStreakDays(int days) {
    return 'Día $days de racha';
  }

  @override
  String get exploreStreakMotivation => '🔥 ¡Sigue así!';

  @override
  String get searchEmptyTitle => 'No se encontraron resultados';

  @override
  String get searchEmptySubtitle =>
      'Prueba con otras palabras clave o explora una categoría';

  @override
  String get searchEmptyExploreLabel => 'Explorar categorías';

  @override
  String get articleDetailRelated => 'Más como esto';

  @override
  String get categoryListSectionLabel => '— CATEGORÍA';

  @override
  String searchTabArticles(int count) {
    return 'Artículos ($count)';
  }

  @override
  String searchTabCategories(int count) {
    return 'Categorías ($count)';
  }

  @override
  String get searchFilterAll => 'Todos';

  @override
  String get tortuFeedTitle => 'Darle de comer a Tortu';

  @override
  String get tortuFeedComeBackTomorrow =>
      'Vuelve mañana para seguir alimentando a Tortu 🐢';

  @override
  String get tortuFeedSlideHint => 'Desliza →';

  @override
  String get tortuFeedCompleted => '¡Tip aprendido!';

  @override
  String get tortuFeedHappy => 'Tortu está feliz +1%';

  @override
  String get createArticlePublishedSuccess => '¡Artículo publicado con éxito!';
}
