
# Database Schema — Articles

Este documento describe el schema de Firestore para la funcionalidad de "subir artículos propios" (feature `user_articles`), agregada como parte de esta prueba técnica.

## Colección: `articles`

Cada documento dentro de la colección `articles` representa un artículo subido por un usuario, con la siguiente estructura:

```
ArticleSchema = {
  title: string,
  content: string,
  thumbnailURL: string,      // referencia a Firebase Storage, carpeta 'media/articles'
  publishedAt: timestamp,
}
```

## Descripción de campos

| Campo | Tipo | Descripción |
|----------------|-----------|--------------------------------------------------------------------------------------------|
| `title`        | string    | Título del artículo, ingresado por el usuario al publicar.                                 |
| `content`      | string    | Cuerpo completo del texto del artículo.                                                    |
| `thumbnailURL` | string    | URL de descarga de la imagen del artículo. La imagen en sí vive en Firebase Cloud Storage. |
| `publishedAt`  | timestamp | Fecha y hora de creación del artículo, generada automáticamente al momento de subir (tipo
                              `Timestamp` nativo de Firestore). 

## Relación con Firebase Storage

Las imágenes de los artículos se almacenan en:

```
media/articles/{nombre_del_archivo}
```

Cuando un usuario sube una imagen, esta se guarda primero en Storage, y la URL de descarga resultante (`getDownloadURL()`) es la que se guarda en el campo `thumbnailURL` del documento correspondiente en Firestore.

## Decisiones de diseño

- No se incluye un campo de autor/usuario (`authorId`) porque esta implementación no incluye autenticación (Firebase Auth), decisión tomada explícitamente por alcance y tiempo disponible. En una versión futura con autenticación, se añadiría `authorId: string` referenciando el `uid` del usuario.
- `publishedAt` se guarda como `Timestamp` nativo de Firestore (no como string) para permitir ordenar los artículos cronológicamente de forma eficiente en las consultas.


## Sobre el identificador del artículo (Document ID)

Firestore asigna automáticamente un ID único a cada documento al crearlo (vía `.add()`), sin que se especifique manualmente. Este ID **no se guarda como un campo dentro del documento** — vive como parte de la ruta del documento en Firestore (ej. `articles/AbC123XyZ`), no como un dato del schema en sí.

En la app, este ID se recupera al leer los documentos (`doc.id`) y se usa como identificador único del artículo dentro de la capa de dominio (`UserArticleEntity.id`) — necesario, por ejemplo, para poder referenciar y eliminar un artículo específico.
