# Database Schema

Esquema actual de datos para la News App (Firestore + Cloud Storage).

## Cloud Storage

### Carpeta `media/articles`

- **Ruta:** `media/articles/{authorId}_{timestamp}.{ext}`
- **Uso:** Almacena imágenes de portada de artículos creados por usuarios autenticados.
- **Permisos:** escritura solo para usuarios autenticados (ver `backend/storage.rules`).
- La referencia se guarda en Firestore en el campo `urlToImage` como URL de descarga.

## Firestore

### Colección `articles`

Cada documento representa un artículo creado por un usuario autenticado.

| Campo | Tipo | Obligatorio | Descripción |
|---|---|---|---|
| `authorId` | string | Sí | UID del usuario autenticado (`request.auth.uid`). |
| `author` | string | No | Nombre/email mostrado del autor al crear el artículo. |
| `title` | string | Sí | Título del artículo. |
| `description` | string | No | Resumen del artículo. |
| `urlToImage` | string | No | URL pública de la imagen subida a Storage (`media/articles/...`). |
| `content` | string | No | Contenido del artículo. |
| `createdAt` | timestamp | Sí | Fecha de creación (`FieldValue.serverTimestamp()`). |
| `publishedAt` | timestamp | Sí | Fecha de publicación (`FieldValue.serverTimestamp()`). |

### Notas de implementación actual

- El `documentId` se genera automáticamente con `.add(...)` en Firestore.
- Las reglas de Firestore validan:
  - usuario autenticado para crear,
  - `authorId == request.auth.uid`,
  - presencia y tipo de `authorId`, `title` y `createdAt`.

### Ejemplo de documento

```json
{
  "authorId": "u123456",
  "author": "tomas@gmail.com",
  "title": "Cómo configurar emuladores Firebase en Flutter",
  "description": "Guía práctica para Auth, Firestore y Storage.",
  "urlToImage": "http://127.0.0.1:9199/v0/b/.../o/media%2Farticles%2Fu123456_1740732800000.jpg?alt=media",
  "content": "Contenido del artículo...",
  "createdAt": "<Firestore Timestamp>",
  "publishedAt": "<Firestore Timestamp>"
}
```
