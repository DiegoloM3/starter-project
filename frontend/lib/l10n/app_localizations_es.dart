// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get navNews => 'NOTICIAS';

  @override
  String get navCommunity => 'COMUNIDAD';

  @override
  String get navSaved => 'GUARDADOS';

  @override
  String get navAccount => 'CUENTA';

  @override
  String get actionWrite => 'Escribir';

  @override
  String get dailyNewsTitle => 'Noticias del día';

  @override
  String get newsLoadFailed => 'No pudimos cargar las noticias.';

  @override
  String get newsEmptyTitle => 'No hay noticias ahora';

  @override
  String get newsEmptyMessage =>
      'Esta sección está vacía por el momento. Prueba con otra, o vuelve en un rato.';

  @override
  String get readMore => 'Leer más';

  @override
  String get tryAgain => 'Reintentar';

  @override
  String get checkConnection => 'Revisa tu conexión y vuelve a intentarlo.';

  @override
  String get categoryGeneral => 'General';

  @override
  String get categoryBusiness => 'Negocios';

  @override
  String get categoryTechnology => 'Tecnología';

  @override
  String get categoryScience => 'Ciencia';

  @override
  String get categoryHealth => 'Salud';

  @override
  String get categorySports => 'Deportes';

  @override
  String get categoryEntertainment => 'Entretenimiento';

  @override
  String get savedTitle => 'Artículos guardados';

  @override
  String get savedEmptyTitle => 'Todavía no has guardado nada';

  @override
  String get savedEmptyMessage =>
      'Abre un artículo y pulsa Guardar para conservarlo aquí.';

  @override
  String get removedFromSaved => 'Quitado de guardados.';

  @override
  String get undo => 'Deshacer';

  @override
  String get removeFromSaved => 'Quitar de guardados';

  @override
  String get save => 'Guardar';

  @override
  String get saved => 'Guardado';

  @override
  String get savedConfirmation =>
      'Guardado. Lo encuentras en la pestaña Guardados.';

  @override
  String get articleUnavailable => 'Este artículo ya no está disponible.';

  @override
  String get communityTitle => 'Artículos de la comunidad';

  @override
  String get loadMoreArticles => 'Cargar más artículos';

  @override
  String get communityLoadFailed => 'No pudimos cargar los artículos.';

  @override
  String get communityEmptyRecentTitle => 'Nada nuevo esta semana';

  @override
  String communityEmptyRecentMessage(int days) {
    return 'El feed de la comunidad muestra lo publicado en los últimos $days días. Sé el primero en escribir algo.';
  }

  @override
  String get authorEmptyTitle => 'Todavía no hay artículos';

  @override
  String get authorEmptyMessage => 'Este periodista aún no ha publicado nada.';

  @override
  String byAuthor(String author) {
    return 'Por $author';
  }

  @override
  String viewsCount(String count) {
    return '$count vistas';
  }

  @override
  String moreFrom(String name) {
    return 'Más de $name';
  }

  @override
  String get thisAuthor => 'este autor';

  @override
  String get myArticlesTitle => 'Mis artículos';

  @override
  String get searchMyArticles => 'Buscar en mis artículos';

  @override
  String get filterAll => 'Todos';

  @override
  String get filterDrafts => 'Borradores';

  @override
  String get filterPublished => 'Publicados';

  @override
  String get badgeDraft => 'BORRADOR';

  @override
  String get badgePublished => 'PUBLICADO';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get publish => 'Publicar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get deleteArticleTitle => 'Eliminar artículo';

  @override
  String deleteArticleMessage(String title) {
    return '\"$title\" se eliminará permanentemente. Esto no se puede deshacer.';
  }

  @override
  String get myArticlesLoadFailed => 'No pudimos cargar tus artículos.';

  @override
  String get noMatchesTitle => 'No hay coincidencias';

  @override
  String get noMatchesMessage => 'Prueba con otra búsqueda, o con otro filtro.';

  @override
  String get myArticlesEmptyTitle => 'Todavía no hay artículos';

  @override
  String get myArticlesEmptyMessage =>
      'Todo lo que escribas aparecerá aquí, borradores incluidos.';

  @override
  String get writeFirstArticle => 'Escribe tu primer artículo';

  @override
  String publishedOn(String date) {
    return 'Publicado el $date';
  }

  @override
  String savedOn(String date) {
    return 'Guardado el $date';
  }

  @override
  String get notSavedYet => 'Sin guardar';

  @override
  String get newArticle => 'Artículo nuevo';

  @override
  String get editArticle => 'Editar artículo';

  @override
  String get addCoverImage => 'Añadir portada';

  @override
  String get recommendedSize => 'Tamaño recomendado: 1200 × 630 px';

  @override
  String get replace => 'Reemplazar';

  @override
  String get remove => 'Quitar';

  @override
  String get titleHint => 'Escribe aquí tu titular...';

  @override
  String get descriptionHint => 'Añade una descripción breve...';

  @override
  String get contentHint => 'Empieza a escribir tu artículo...';

  @override
  String get articleSection => 'Artículo';

  @override
  String get preview => 'Vista previa';

  @override
  String get keepWriting => 'Seguir escribiendo';

  @override
  String get nothingToPreview => 'Todavía no hay nada que previsualizar.';

  @override
  String draftSavedAt(String time) {
    return 'Borrador guardado · $time';
  }

  @override
  String get saving => 'Guardando...';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get unsavedTitle => 'Tus cambios no están guardados';

  @override
  String get unsavedMessage =>
      'Si sales ahora, perderás lo que hayas escrito desde el último guardado.';

  @override
  String get discard => 'Descartar';

  @override
  String get howToWrite => 'Cómo escribir un artículo';

  @override
  String get toolbarHeading => 'Título';

  @override
  String get toolbarBold => 'Negrita';

  @override
  String get toolbarItalic => 'Cursiva';

  @override
  String get toolbarList => 'Lista';

  @override
  String get toolbarQuote => 'Cita';

  @override
  String get whatYouType => 'Lo que escribes';

  @override
  String get whatReadersSee => 'Lo que ven los lectores';

  @override
  String tourStepOf(int current, int total) {
    return 'Paso $current de $total';
  }

  @override
  String get skip => 'Saltar';

  @override
  String get close => 'Cerrar';

  @override
  String get back => 'Atrás';

  @override
  String get next => 'Siguiente';

  @override
  String get gotIt => 'Entendido';

  @override
  String get tourCoverTitle => 'Empieza por la portada';

  @override
  String get tourCoverBody =>
      'Elige una imagen de tu teléfono. También vale un GIF animado, y es lo primero que ve un lector.';

  @override
  String get tourTitleTitle => 'Ponle un titular';

  @override
  String get tourTitleBody =>
      'Una línea que diga de qué va el artículo. Con esto solo ya puedes guardar un borrador.';

  @override
  String get tourFormatTitle => 'Da formato mientras escribes';

  @override
  String get tourFormatBody =>
      'Selecciona unas palabras y pulsa un botón. No tienes que recordar ningún símbolo: estos los escriben por ti.';

  @override
  String get tourPreviewTitle => 'Míralo como lo verá un lector';

  @override
  String get tourPreviewBody =>
      'La vista previa muestra el artículo terminado. Vuelve cuando quieras seguir escribiendo.';

  @override
  String get tourPublishTitle => 'Publica cuando esté listo';

  @override
  String get tourPublishBody =>
      'Para publicar hacen falta titular, descripción, portada y texto. Hasta entonces, Guardar cambios lo mantiene privado.';

  @override
  String get articleLiveTitle => 'Tu artículo está publicado';

  @override
  String get articleLiveMessage =>
      'Cualquiera puede leerlo ya en el feed de la comunidad.';

  @override
  String get viewArticle => 'Ver artículo';

  @override
  String get backToMyArticles => 'Volver a mis artículos';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get createAnAccount => 'Crear una cuenta';

  @override
  String get alreadyHaveAccount => 'Ya tengo una cuenta';

  @override
  String get forgotPassword => 'Olvidé mi contraseña';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get repeatPassword => 'Repite la contraseña';

  @override
  String get displayNameOptional => 'Nombre que verán los lectores (opcional)';

  @override
  String atLeastCharacters(int count) {
    return 'Al menos $count caracteres';
  }

  @override
  String get newHereCreateAccount => '¿Eres nuevo?  Crear una cuenta';

  @override
  String get resetPassword => 'Restablecer contraseña';

  @override
  String get resetRequested => 'Solicitud enviada';

  @override
  String get resetInstructions =>
      'Escribe el correo con el que te registraste y te enviaremos un enlace para elegir una contraseña nueva.';

  @override
  String get sendResetLink => 'Enviar enlace';

  @override
  String get resetSentMessage =>
      'Si ese correo tiene una cuenta, el enlace va en camino. Ábrelo para elegir una contraseña nueva y vuelve a iniciar sesión.';

  @override
  String get resetSpamHint =>
      'Pista: revisa las carpetas de spam o promociones si no llega en unos minutos.';

  @override
  String get backToSignIn => 'Volver a iniciar sesión';

  @override
  String get accountInviteTitle => 'Escribe tus propias historias';

  @override
  String get accountInviteMessage =>
      'Leer siempre es gratis. Crear una cuenta lleva un momento y es lo que te permite publicar.';

  @override
  String get myArticles => 'Mis artículos';

  @override
  String get nameReadersSee => 'Nombre que ven los lectores';

  @override
  String get yourName => 'Tu nombre';

  @override
  String get nameHelper =>
      'Aparecerá como autor de todo lo que publiques a partir de ahora.';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String statsSummary(String articles, String views) {
    return '$articles  ·  $views vistas';
  }

  @override
  String articleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artículos',
      one: '1 artículo',
    );
    return '$_temp0';
  }

  @override
  String get errorEmailInUse =>
      'Ese correo ya tiene una cuenta. Inicia sesión.';

  @override
  String get errorInvalidCredentials =>
      'Ese correo y esa contraseña no coinciden con ninguna cuenta.';

  @override
  String get errorNotSignedIn => 'Inicia sesión para continuar.';

  @override
  String get errorTooManyAttempts =>
      'Demasiados intentos. Prueba de nuevo en unos minutos.';

  @override
  String get errorGeneric => 'Algo salió mal.';

  @override
  String get errorEmailRequired => 'Escribe tu correo.';

  @override
  String get errorEmailMalformed => 'Eso no parece una dirección de correo.';

  @override
  String get errorPasswordRequired => 'Escribe tu contraseña.';

  @override
  String errorPasswordTooShort(int count) {
    return 'Usa al menos $count caracteres.';
  }

  @override
  String get errorPasswordsDiffer => 'Las dos contraseñas son distintas.';

  @override
  String errorDisplayName(int count) {
    return 'Escribe un nombre de hasta $count caracteres.';
  }

  @override
  String get errorTitleRequired => 'El artículo necesita un titular.';

  @override
  String get errorTitleTooLong => 'El titular es demasiado largo.';

  @override
  String get errorDescriptionRequired =>
      'Los lectores necesitan una descripción breve.';

  @override
  String get errorDescriptionTooLong => 'La descripción es demasiado larga.';

  @override
  String get errorContentRequired => 'El artículo todavía no tiene texto.';

  @override
  String get errorThumbnailRequired => 'Añade una portada antes de publicar.';

  @override
  String get errorAuthorRequired => 'El artículo no tiene autor.';

  @override
  String get errorOwnerRequired => 'El artículo no tiene dueño.';

  @override
  String get errorArticleNotFound => 'Este artículo ya no existe.';

  @override
  String get errorArticleNotStored => 'Guarda el artículo antes de publicarlo.';

  @override
  String get errorImageEmpty => 'La imagen elegida está vacía.';

  @override
  String get errorImageTooLarge => 'La imagen pesa más de 5 MB.';

  @override
  String get errorImageFormat =>
      'Solo se admiten imágenes jpg, png, webp y gif.';

  @override
  String get justNow => 'Justo ahora';

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
    return 'hace $count d';
  }

  @override
  String get errorNoConnection =>
      'Sin conexión a internet. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get appName => 'Byline';

  @override
  String get appTagline => 'Léelo. Escríbelo.';

  @override
  String get signInSubtitle =>
      'Inicia sesión para publicar con tu propio nombre.';

  @override
  String get signUpSubtitle =>
      'Solo necesitas una cuenta para escribir. Leer siempre es gratis.';

  @override
  String get newsPreviewNotice =>
      'La News API solo envía un adelanto de cada artículo. La nota completa está en la fuente.';

  @override
  String get openAtSource => 'Lee el artículo completo en';

  @override
  String bylineUpdated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tus $count artículos publicados ya llevan el nuevo nombre.',
      one: 'Tu artículo publicado ya lleva el nuevo nombre.',
    );
    return '$_temp0';
  }
}
