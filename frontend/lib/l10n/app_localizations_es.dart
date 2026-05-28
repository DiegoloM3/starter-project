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
}
