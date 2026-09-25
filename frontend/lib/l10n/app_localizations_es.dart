// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get tabNews => 'Noticias';

  @override
  String get tabMyArticles => 'Mis artículos';

  @override
  String get tabSaved => 'Guardados';

  @override
  String get tabProfile => 'Perfil';

  @override
  String get newArticle => 'Nuevo artículo';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Borrar';

  @override
  String get save => 'Guardar';

  @override
  String get back => 'Volver';

  @override
  String get continueAction => 'Continuar';

  @override
  String get genericError => 'Algo salió mal. Probá de nuevo.';

  @override
  String byAuthor(String author) {
    return 'Por $author';
  }

  @override
  String get savedArticlesTitle => 'Artículos guardados';

  @override
  String get articleSaved => 'Artículo guardado.';

  @override
  String get articleRemovedFromSaved => 'Artículo quitado de guardados.';

  @override
  String get myArticlesTitle => 'Mis artículos';

  @override
  String get tapToWriteYourOwn => 'Tocá para escribir el tuyo';

  @override
  String get deleteArticleTitle => 'Borrar artículo';

  @override
  String get cannotBeUndone => 'Esta acción no se puede deshacer.';

  @override
  String get editArticle => 'Editar artículo';

  @override
  String get publish => 'Publicar';

  @override
  String get chooseCoverImage => 'Elegí una imagen de portada';

  @override
  String get discardChangesTitle => '¿Descartar los cambios?';

  @override
  String get unsavedChangesMessage =>
      'Tenés cambios sin guardar en este artículo.';

  @override
  String get keepEditing => 'Seguir editando';

  @override
  String get discard => 'Descartar';

  @override
  String get bylineLabel => 'Tu nombre (firma)';

  @override
  String get titleLabel => 'Título';

  @override
  String get summaryLabel => 'Resumen corto';

  @override
  String get fullContentLabel => 'Contenido completo';

  @override
  String get requiredField => 'Obligatorio';

  @override
  String minimumCharacters(int count) {
    return 'Mínimo $count caracteres';
  }

  @override
  String get articleSaveFailed =>
      'No se pudo guardar tu artículo. Probá de nuevo.';

  @override
  String get bold => 'Negrita';

  @override
  String get subheading => 'Subtítulo';

  @override
  String get bulletList => 'Lista con viñetas';

  @override
  String get numberedList => 'Lista numerada';

  @override
  String get quote => 'Cita';

  @override
  String wordCount(int count) {
    return '$count palabras';
  }

  @override
  String get write => 'Escribir';

  @override
  String get preview => 'Vista previa';

  @override
  String get nothingToPreview => 'Todavía no hay nada para mostrar.';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get theme => 'Tema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get language => 'Idioma';

  @override
  String get guest => 'Invitado';

  @override
  String get yourAccount => 'Tu cuenta';

  @override
  String get signedIn => 'Sesión iniciada';

  @override
  String get articlesOnlyOnThisPhone =>
      'Tus artículos solo están en este celular.';

  @override
  String get keepYourArticles => 'No pierdas tus artículos';

  @override
  String get guestExplanation =>
      'Estás escribiendo como invitado, así que tus artículos solo están en este celular. Conectá una cuenta para no perderlos si reinstalás la app o cambiás de celular.';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get continueWithEmail => 'Continuar con email';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get showPassword => 'Mostrar contraseña';

  @override
  String get hidePassword => 'Ocultar contraseña';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get nameLabel => 'Tu nombre';

  @override
  String get editName => 'Editar nombre';

  @override
  String get nameUpdated => 'Nombre actualizado.';

  @override
  String get confirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get passwordsDontMatch => 'Las contraseñas no coinciden';

  @override
  String get enterValidEmail => 'Ingresá un email válido';

  @override
  String get atLeastSixCharacters => 'Al menos 6 caracteres';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get signOutQuestion => '¿Cerrar sesión?';

  @override
  String get signOutWarning =>
      'Vas a seguir como invitado en este celular. Podés volver a entrar cuando quieras para ver tus artículos.';

  @override
  String get accountConnected =>
      'Cuenta conectada. Tus artículos están a salvo.';

  @override
  String get signedInToAccount => 'Entraste a tu cuenta.';

  @override
  String get signedOutAsGuest => 'Cerraste sesión. Ahora sos invitado.';

  @override
  String get accountDeleted => 'Se borraron tu cuenta y tus artículos.';

  @override
  String get alreadyHaveAccountTitle => 'Ya tenés una cuenta';

  @override
  String get alreadyHaveAccountMessage =>
      'Esta forma de entrar ya pertenece a una cuenta. ¿Querés cambiar a esa? Los artículos que escribiste como invitado en este celular no se pasan.';

  @override
  String get switchAccount => 'Cambiar';

  @override
  String get manageAccount => 'Administrar cuenta';

  @override
  String get signedInWith => 'Entraste con';

  @override
  String get guestOnThisPhone =>
      'Invitado en este celular (todavía sin cuenta)';

  @override
  String get signInGoogle => 'Google';

  @override
  String get signInEmailAndPassword => 'Email y contraseña';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get deleteMyData => 'Borrar mis datos';

  @override
  String get deleteAccount => 'Borrar cuenta';

  @override
  String get deleteMyDataQuestion => '¿Borrar mis datos?';

  @override
  String get deleteAccountQuestion => '¿Borrar la cuenta?';

  @override
  String get deleteMyDataDescription =>
      'Borra todos los artículos que escribiste en este celular, con sus fotos.';

  @override
  String get deleteAccountDescription =>
      'Borra tu cuenta, todos los artículos que escribiste y sus fotos.';

  @override
  String get deleteMyDataWarning =>
      'Se van a borrar todos los artículos que escribiste en este celular y sus fotos. No se puede deshacer.';

  @override
  String get deleteAccountWarning =>
      'Se van a borrar tu cuenta, todos los artículos que escribiste y sus fotos. No se puede deshacer. Vas a seguir como invitado.';

  @override
  String get confirmItsYou => 'Confirmá que sos vos';

  @override
  String get errorWrongCredentials => 'Email o contraseña incorrectos.';

  @override
  String get errorDifferentAccount =>
      'Esa es otra cuenta. Elegí la que estás usando.';

  @override
  String get errorWeakPassword =>
      'Elegí una contraseña más segura (al menos 6 caracteres).';

  @override
  String get errorInvalidEmail => 'Ese email no parece correcto.';

  @override
  String get errorOtherSignInMethod =>
      'Este email ya entra de otra forma. Probá con esa opción.';

  @override
  String get errorMethodNotAvailable =>
      'Esta forma de entrar no está disponible ahora.';

  @override
  String get errorNetwork =>
      'Sin conexión. Revisá tu internet y probá de nuevo.';

  @override
  String get errorTooManyAttempts =>
      'Demasiados intentos. Esperá un momento y probá de nuevo.';

  @override
  String get privacyAccountTitle => 'Tu cuenta';

  @override
  String get privacyAccountBody =>
      'Cada instalación empieza con un id anónimo, así la app sabe qué artículos son tuyos sin preguntarte quién sos. Si conectás una cuenta, también guardamos tu email y, con Google, tu nombre y tu foto de perfil.';

  @override
  String get privacyArticlesTitle => 'Artículos que publicás';

  @override
  String get privacyArticlesBody =>
      'Se guardan el título, el resumen, el cuerpo, la firma y la foto de portada de tus artículos para mostrarlos en la app. Los artículos son públicos: cualquiera que use la app puede leerlos.';

  @override
  String get privacySavedTitle => 'Noticias guardadas';

  @override
  String get privacySavedBody =>
      'Las noticias que guardás quedan en una base de datos solo en este celular. Nunca salen de tu dispositivo, y quitarlas de Guardados las borra.';

  @override
  String get privacyFeedTitle => 'Noticias';

  @override
  String get privacyFeedBody =>
      'Los titulares vienen de NewsAPI. La app le pide las últimas noticias sin mandar nada sobre vos.';

  @override
  String get privacyStorageTitle => 'Dónde se guarda';

  @override
  String get privacyStorageBody =>
      'Tu cuenta, tus artículos y tus fotos se guardan en Google Firebase (Authentication, Cloud Firestore y Cloud Storage).';

  @override
  String get privacyNeverTitle => 'Lo que nunca hacemos';

  @override
  String get privacyNeverBody =>
      'Sin publicidad, sin analytics ni seguimiento, y tus datos nunca se venden ni se comparten con nadie.';

  @override
  String get privacyDeletingTitle => 'Borrar tus datos';

  @override
  String get privacyDeletingBody =>
      'Perfil > Administrar cuenta > Borrar cuenta elimina tu cuenta, todos los artículos que escribiste y sus fotos, en el momento.';

  @override
  String get latest => 'LO ÚLTIMO';

  @override
  String get featuredStories => 'DESTACADAS';

  @override
  String get todaysStories => 'HISTORIAS DEL DÍA';

  @override
  String get readStory => 'Leer';

  @override
  String get shareAction => 'Compartir';

  @override
  String get saveAction => 'Guardar';

  @override
  String get removeFromSaved => 'Quitar de guardados';

  @override
  String get allCaughtUp => 'Estás al día';

  @override
  String get allCaughtUpDetail =>
      'No hay más noticias en esta sección por ahora.';

  @override
  String get newsLoadFailed => 'No se pudieron cargar las noticias.';

  @override
  String get tryAgain => 'Reintentar';

  @override
  String get categoryTop => 'Portada';

  @override
  String get categoryBusiness => 'Economía';

  @override
  String get categoryTechnology => 'Tecnología';

  @override
  String get categoryScience => 'Ciencia';

  @override
  String get categoryHealth => 'Salud';

  @override
  String get categorySports => 'Deportes';

  @override
  String get categoryEntertainment => 'Espectáculos';

  @override
  String get justNow => 'Recién';

  @override
  String minutesAgo(int count) {
    return 'hace $count min';
  }

  @override
  String hoursAgo(int count) {
    return 'hace $count h';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count días',
      one: 'Ayer',
    );
    return '$_temp0';
  }

  @override
  String get savedEmptyTitle => 'Todavía no guardaste nada';

  @override
  String get savedEmptyDetail =>
      'Tocá el marcador de cualquier noticia para leerla después.';

  @override
  String get readFullArticle => 'Leer la nota completa';

  @override
  String fullStoryOn(String source) {
    return 'Este es el comienzo de la nota. El texto completo está en $source.';
  }

  @override
  String get couldNotOpenArticle => 'No se pudo abrir la nota.';

  @override
  String get welcomeTagline =>
      'Las noticias del día, y un lugar para publicar las tuyas.';

  @override
  String get welcomeSignInHint =>
      'Entrá para tener tus artículos en cualquier celular.';

  @override
  String get continueAsGuest => 'Seguir como invitado';

  @override
  String get connectLater => 'Podés conectar una cuenta después desde Perfil.';

  @override
  String get noAccountSignUpWithEmail =>
      '¿No tenés cuenta? Registrate con tu email';

  @override
  String get noNewStories => 'No hay noticias nuevas por ahora';

  @override
  String get refreshFailed => 'No se pudieron actualizar las noticias.';

  @override
  String get searchHint => 'Buscar noticias';

  @override
  String get searchAction => 'Buscar';

  @override
  String get clearSearch => 'Borrar';

  @override
  String get searchPromptTitle => 'Buscá noticias';

  @override
  String get searchPromptDetail =>
      'Encontrá notas sobre cualquier tema, de miles de medios.';

  @override
  String noResultsFor(String query) {
    return 'No hay resultados para “$query”';
  }

  @override
  String get noResultsDetail => 'Probá con otras palabras, o con menos.';

  @override
  String get searchFailed => 'No se pudo buscar ahora.';

  @override
  String get recentSearches => 'Búsquedas recientes';

  @override
  String get removeFromHistory => 'Quitar del historial';

  @override
  String offlineBanner(String time) {
    return 'Sin conexión · noticias de las $time';
  }

  @override
  String get offlineNothingUpdated => 'Sin conexión. No se actualizó nada.';

  @override
  String get rateLimitedNothingUpdated =>
      'Se alcanzó el límite diario de noticias. No se actualizó nada.';

  @override
  String newsLimitReachedBanner(String time) {
    return 'Se alcanzó el límite diario de noticias · noticias de las $time';
  }

  @override
  String get noPhoto => 'Sin foto';

  @override
  String get saveDraft => 'Guardar borrador';

  @override
  String get draftsTab => 'Borradores';

  @override
  String get publishedTab => 'Publicados';

  @override
  String get untitledDraft => 'Borrador sin título';

  @override
  String get draftBadge => 'Borrador';

  @override
  String get draftsEmptyTitle => 'No hay borradores';

  @override
  String get draftsEmptyDetail =>
      'Los artículos que guardás sin publicar aparecen acá.';

  @override
  String get publishedEmptyTitle => 'No hay artículos publicados';

  @override
  String get publishedEmptyDetail =>
      'Terminá un borrador y publicalo para verlo acá.';

  @override
  String get coverPhotoSection => 'Foto de portada';

  @override
  String get articleDetailsSection => 'Detalles del artículo';

  @override
  String readingTime(int minutes) {
    return '$minutes min de lectura';
  }

  @override
  String get draftAutosaved => 'Borrador guardado';

  @override
  String maximumCharacters(int count) {
    return 'Máximo $count caracteres';
  }

  @override
  String get offlineCannotSave =>
      'Estás sin conexión. Conectate a internet para guardar este artículo.';

  @override
  String get couldNotOpenPhotos => 'No se pudieron abrir tus fotos.';

  @override
  String get moveToDrafts => 'Pasar a borradores';

  @override
  String get moveToDraftsTitle => '¿Pasar a borradores?';

  @override
  String get moveToDraftsMessage =>
      'Deja de ser público y vuelve a tus borradores, con los cambios que hiciste. Podés publicarlo de nuevo cuando quieras.';

  @override
  String get leaveDraftTitle => '¿Guardar los cambios?';

  @override
  String get leaveDraftMessage =>
      'Guardalo como borrador para terminarlo después, publicalo ahora o descartá los cambios.';
}
