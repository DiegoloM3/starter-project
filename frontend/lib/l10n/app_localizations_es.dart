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
  String get noArticlesYet =>
      'No hay artículos aún. ¡Sé el primero en publicar!';

  @override
  String get articleSavedSuccessfully => 'Artículo guardado exitosamente.';

  @override
  String get savedArticles => 'Artículos Guardados';

  @override
  String get noSavedArticles => 'No hay artículos guardados';

  @override
  String get writeTitleHint => 'Escribí tu título acá...';

  @override
  String get titleRequired => 'El título es obligatorio';

  @override
  String get titleMaxLength => 'El título debe tener menos de 200 caracteres';

  @override
  String get attachImage => 'Adjuntar Imagen';

  @override
  String get briefDescriptionHint => 'Descripción breve...';

  @override
  String get descriptionRequired => 'La descripción es obligatoria';

  @override
  String get descriptionMaxLength =>
      'La descripción debe tener menos de 500 caracteres';

  @override
  String get addArticleHint => 'Escribí tu artículo acá...';

  @override
  String get contentRequired => 'El contenido del artículo es obligatorio';

  @override
  String get articlePublishedSuccessfully =>
      '¡Artículo publicado exitosamente!';

  @override
  String get failedToPublishArticle => 'Error al publicar artículo';

  @override
  String get anErrorOccurred => 'Ocurrió un error';

  @override
  String get commentsHeader => 'Comentarios';

  @override
  String get addCommentHint => 'Agregar un comentario...';

  @override
  String get noCommentsYet => 'No hay comentarios. ¡Sé el primero!';

  @override
  String get failedToLoadComments => 'Error al cargar comentarios';

  @override
  String get unknownAuthor => 'Desconocido';

  @override
  String get publishArticle => 'Publicar Artículo';

  @override
  String get myArticles => 'Mis Artículos';

  @override
  String get filterAll => 'Todos';

  @override
  String get filterDrafts => 'Borradores';

  @override
  String get filterPublished => 'Publicados';

  @override
  String get filterArchived => 'Archivados';

  @override
  String get editDraft => 'Editar Borrador';

  @override
  String get newArticle => 'Nuevo Artículo';

  @override
  String get editArticle => 'Editar Artículo';

  @override
  String get updateArticle => 'Actualizar Artículo';

  @override
  String get deleteArticle => 'Eliminar Artículo';

  @override
  String get deleteArticleConfirmation =>
      '¿Estás seguro de eliminar este artículo? Esta acción no se puede deshacer.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get articleDeletedSuccessfully => 'Artículo eliminado exitosamente.';

  @override
  String get failedToDeleteArticle => 'Error al eliminar artículo';

  @override
  String get noUserArticles => 'Todavía no escribiste ningún artículo.';

  @override
  String get articleUpdatedSuccessfully =>
      '¡Artículo actualizado exitosamente!';

  @override
  String get failedToUpdateArticle => 'Error al actualizar artículo';

  @override
  String get saveDraft => 'Guardar Borrador';

  @override
  String get preview => 'Vista Previa';

  @override
  String get saved => 'Guardado';

  @override
  String get justSaved => 'Recién guardado';

  @override
  String savedTimeAgo(String time) {
    return 'Guardado hace $time';
  }

  @override
  String get edit => 'Editar';

  @override
  String get saveDraftTooltip => 'Guardar borrador';

  @override
  String get draft => 'Borrador';

  @override
  String get published => 'Publicado';

  @override
  String get archived => 'Archivado';

  @override
  String get searchTitle => 'Buscar';

  @override
  String get searchHint => 'Buscar artículos...';

  @override
  String get typeToSearch => 'Escribí para buscar artículos';

  @override
  String get noArticlesFound => 'No se encontraron artículos';

  @override
  String get searchFailed => 'Error en la búsqueda';

  @override
  String get myDrafts => 'Mis Borradores';

  @override
  String get noDraftsYet => 'No hay borradores aún';

  @override
  String get draftsEmptySubtitle =>
      'Empezá a escribir y tus borradores aparecerán acá';

  @override
  String get failedToLoadDrafts => 'Error al cargar borradores';

  @override
  String get deleteDraft => 'Eliminar Borrador';

  @override
  String get deleteDraftConfirmation =>
      '¿Seguro que querés eliminar este borrador? No se puede deshacer.';

  @override
  String get keepEditing => 'Seguir Editando';

  @override
  String get publish => 'Publicar';

  @override
  String get untitled => 'Sin Título';

  @override
  String get noContentYet => 'Sin contenido aún.';

  @override
  String get invalidEmail => 'Ingresá un email válido';

  @override
  String get emailRequired => 'Ingresá tu email';

  @override
  String get passwordRequired => 'Ingresá tu contraseña';

  @override
  String get passwordMinLength =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get commentActionFailed =>
      'No se pudo completar la acción del comentario';

  @override
  String get loadArticlesFailed => 'No se pudieron cargar los artículos';

  @override
  String get tapToRetry => 'Tocá para reintentar';

  @override
  String get deletePermanently => 'Eliminar permanentemente';

  @override
  String get writeAnArticle => 'Escribir un artículo';

  @override
  String get writeTheFirstArticle => 'Escribir el primer artículo';

  @override
  String get noArticlesTitle => 'No hay artículos aún';

  @override
  String get noArticlesSubtitle =>
      'Tus historias van a aparecer acá. Empezá a escribir algo increíble.';

  @override
  String get noDraftsTitle => 'No hay borradores';

  @override
  String get noDraftsSubtitle =>
      'Los artículos en los que estés trabajando se guardan acá automáticamente.';

  @override
  String get noPublishedTitle => 'Nada publicado aún';

  @override
  String get noPublishedSubtitle =>
      'Compartí tu trabajo — publicá un artículo para llegar a tus lectores.';

  @override
  String get noArchivedTitle => 'No hay artículos archivados';

  @override
  String get noArchivedSubtitle =>
      'Los artículos que archives se guardan acá como referencia.';

  @override
  String get noSavedTitle => 'No hay artículos guardados';

  @override
  String get noSavedSubtitle =>
      'Guardá artículos que quieras leer después — van a aparecer acá.';

  @override
  String get undo => 'Deshacer';

  @override
  String get articleRemoved => 'Artículo eliminado';

  @override
  String get draftDeleted => 'Borrador eliminado';

  @override
  String get searchPrompt => 'Buscá artículos';

  @override
  String get searchPromptSubtitle =>
      'Encontrá artículos por título o descripción';

  @override
  String noResultsFor(String query) {
    return 'Sin resultados para \"$query\"';
  }

  @override
  String get tryDifferentKeywords =>
      'Probá con otras palabras clave o revisá la ortografía';

  @override
  String get somethingWentWrong => 'Algo salió mal';

  @override
  String get couldNotLoadArticles =>
      'No pudimos cargar los artículos. Revisá tu conexión e intentá de nuevo.';

  @override
  String get tryAgain => 'Intentar de nuevo';
}
