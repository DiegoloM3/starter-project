# Guía visual — Reglas Firestore + Storage

> **Propósito.** Manual visual y operativo para **subir, verificar y validar** las reglas del proyecto `symmetry-test-cf818`. Está pensado para que cualquier revisor pueda pegar las reglas en la consola Firebase, ejecutar los casos de prueba en el Playground y confirmar que el comportamiento es el esperado — sin tener que leer código Dart ni Flutter.
>
> **Archivos que documenta:**
> - [`backend/firestore.rules`](../firestore.rules)
> - [`backend/storage.rules`](../storage.rules)
>
> **Schema al que obedecen:** [`backend/docs/DB_SCHEMA.md`](./DB_SCHEMA.md) · argumentación completa en [`backend/docs/SCHEMA_RATIONALE.md`](./SCHEMA_RATIONALE.md).

---

## Índice

1. [Cómo subir las reglas a Firebase](#1-cómo-subir-las-reglas-a-firebase)
2. [Diagrama de decisión — Firestore](#2-diagrama-de-decisión--firestore)
3. [Casos de prueba — Firestore Playground](#3-casos-de-prueba--firestore-playground)
4. [Diagrama de decisión — Storage](#4-diagrama-de-decisión--storage)
5. [Casos de prueba — Storage Playground](#5-casos-de-prueba--storage-playground)
6. [Tabla maestra de validaciones](#6-tabla-maestra-de-validaciones)
7. [Cómo cambiar una regla sin romper nada](#7-cómo-cambiar-una-regla-sin-romper-nada)

---

## 1. Cómo subir las reglas a Firebase

### Opción A — Desde la terminal (recomendada, auditable)

```bash
cd backend
firebase login --reauth                       # solo si hace más de 24 h
firebase use symmetry-test-cf818              # confirmar que es el project activo
firebase deploy --only firestore:rules,storage:rules
```

Salida esperada:

```
✔  cloud.firestore: rules file firestore.rules compiled successfully
✔  storage: rules file storage.rules compiled successfully
✔  Deploy complete!
Project Console: https://console.firebase.google.com/project/symmetry-test-cf818/overview
```

### Opción B — Copy-paste desde la consola (si no hay CLI disponible)

1. Abrir [console.firebase.google.com/project/symmetry-test-cf818](https://console.firebase.google.com/project/symmetry-test-cf818).
2. **Build → Firestore Database → Rules** → **Edit rules**.
3. Pegar el contenido íntegro de [`firestore.rules`](../firestore.rules).
4. **Publish**.
5. **Build → Storage → Rules** → **Edit rules**.
6. Pegar [`storage.rules`](../storage.rules).
7. **Publish**.

**Verificación inmediata:**

- La pestaña **Rules** debe mostrar en verde *"Last deployed: hace unos segundos"*.
- La versión en la consola y la del repo tienen que coincidir byte a byte. Si difieren: volver a deploy.

---

## 2. Diagrama de decisión — Firestore

Cómo Firestore decide si aceptar una operación sobre `articles/{articleId}`:

```
                    ┌─────────────────────────┐
                    │  Petición sobre         │
                    │  articles/{articleId}   │
                    └───────────┬─────────────┘
                                │
             ┌──────────────────┼──────────────────┐
             ▼                                       ▼
      ┌──────────────┐                       ┌──────────────┐
      │  read (get   │                       │  write       │
      │  / list)     │                       │  (create /   │
      └──────┬───────┘                       │  update /    │
             │                                │  delete)     │
             ▼                                └──────┬───────┘
      ┌──────────────┐                               │
      │  allow: true │                ┌──────────────┼──────────────┐
      │  (feed       │                ▼              ▼              ▼
      │  público)    │         ┌───────────┐  ┌───────────┐  ┌───────────┐
      └──────────────┘         │  create   │  │  update   │  │  delete   │
                               └─────┬─────┘  └─────┬─────┘  └─────┬─────┘
                                     │              │              │
                              ┌──────▼─────┐ ┌──────▼──────┐ ┌─────▼──────┐
                              │ signedIn?  │ │ signedIn?   │ │ signedIn?  │
                              │ authorId   │ │ isOwner?    │ │ isOwner?   │
                              │  == uid?   │ │ authorId    │ │            │
                              │ data.id    │ │  inmutable? │ │            │
                              │  == {id}?  │ │ id          │ │            │
                              │ isValid-   │ │  inmutable? │ │            │
                              │  Article?  │ │ publishedAt │ │            │
                              │ publishedAt│ │  inmutable? │ │            │
                              │ ==request  │ │ updatedAt   │ │            │
                              │  .time?    │ │ ==request   │ │            │
                              │ updatedAt  │ │  .time?     │ │            │
                              │ ==request  │ │ isValid-    │ │            │
                              │  .time?    │ │  Article?   │ │            │
                              └──────┬─────┘ └──────┬──────┘ └─────┬──────┘
                                     │              │              │
                                     ▼              ▼              ▼
                              todas true?   todas true?    todas true?
                                 │              │              │
                             ┌───┴───┐      ┌───┴───┐      ┌───┴───┐
                             ▼       ▼      ▼       ▼      ▼       ▼
                          ALLOW    DENY  ALLOW   DENY   ALLOW   DENY
```

**Qué hace cada predicate:**

| Predicate                                           | Qué garantiza                                                                          |
|------------------------------------------------------|----------------------------------------------------------------------------------------|
| `isSignedIn()` → `request.auth != null`             | Solo usuarios autenticados pueden escribir. Lectura es pública.                        |
| `request.resource.data.authorId == request.auth.uid` | Un autor solo puede crear documentos con su propio uid. No se puede suplantar a otros. |
| `request.resource.data.id == articleId`              | El campo `id` del documento coincide con el `{articleId}` del path. Evita documentos "huérfanos". |
| `isValidArticle(data)`                               | Tipos, longitudes, enum y URL https. Ver §6.                                            |
| `request.resource.data.publishedAt == request.time`  | Timestamp de publicación obligado a ser `serverTimestamp()`. Evita que el cliente "antedate" publicaciones. |
| `request.resource.data.updatedAt == request.time`    | Idem para `updatedAt`.                                                                  |
| `resource.data.authorId == request.auth.uid` (update/delete) | Solo el autor puede tocar sus propios documentos.                                     |
| `request.resource.data.authorId == resource.data.authorId` (update) | **Inmutabilidad:** el autor no puede reasignarse a otro.                          |
| `request.resource.data.id == resource.data.id` (update) | Inmutabilidad del id.                                                                  |
| `request.resource.data.publishedAt == resource.data.publishedAt` (update) | Inmutabilidad del timestamp de publicación.                                   |

---

## 3. Casos de prueba — Firestore Playground

**Cómo llegar:** Consola Firebase → **Firestore Database → Rules → Rules Playground** (tab al lado derecho).

Los siguientes 8 casos cubren las combinaciones críticas. Ejecutar cada uno y confirmar el resultado esperado.

### Caso 3.1 — ✅ Lectura pública permitida

| Campo                | Valor                                                         |
|----------------------|---------------------------------------------------------------|
| Operation            | `get`                                                         |
| Location             | `/articles/cualquier-id`                                      |
| Authenticated        | **No**                                                        |

**Esperado:** ✅ **Simulated read allowed**
**Por qué:** feed público, `allow read: if true;`.

---

### Caso 3.2 — ✅ Create con autor autenticado y payload válido

| Campo                | Valor                                                         |
|----------------------|---------------------------------------------------------------|
| Operation            | `create`                                                      |
| Location             | `/articles/a_1714003200`                                     |
| Authenticated        | **Sí** (Provider: Anonymous; uid: `test-uid-123`)            |
| Resource data (JSON) | ver a continuación                                            |

```json
{
  "id":           "a_1714003200",
  "authorId":     "test-uid-123",
  "authorName":   "Test Author",
  "title":        "Clean architecture en Flutter",
  "description":  "Notas de la prueba técnica",
  "content":      "Este es el contenido largo que supera 50 caracteres sin mayor problema.",
  "thumbnailURL": "https://firebasestorage.googleapis.com/v0/b/symmetry-test-cf818/o/media%2Farticles%2Ftest-uid-123%2Fa_1714003200%2Fthumb.jpg?alt=media",
  "tags":         ["flutter", "clean-architecture"],
  "status":       "published",
  "publishedAt":  { ".sv": "timestamp" },
  "updatedAt":    { ".sv": "timestamp" }
}
```

**Esperado:** ✅ **Simulated create allowed**
**Por qué:** todos los predicates de `create` pasan.

> En el Playground, los `serverTimestamp()` pueden ingresarse como el string literal `{".sv":"timestamp"}`. Si el Playground rechaza esa sintaxis, sustituir por `request.time` seleccionando "timestamp" como tipo del campo.

---

### Caso 3.3 — ❌ Create suplantando a otro autor

Igual que 3.2 pero cambiando `"authorId": "otro-uid-999"` (distinto del `uid: test-uid-123` autenticado).

**Esperado:** ❌ **Simulated create denied**
**Por qué:** `request.resource.data.authorId == request.auth.uid` → false.
**Línea concreta:** [`firestore.rules`](../firestore.rules) línea con `request.resource.data.authorId == request.auth.uid`.

---

### Caso 3.4 — ❌ Create con `id` del doc distinto del `articleId` del path

Igual que 3.2 pero path `/articles/id_A` y en el JSON `"id": "id_B"`.

**Esperado:** ❌ **Simulated create denied**
**Por qué:** `request.resource.data.id == articleId` → false.

---

### Caso 3.5 — ❌ Create con title menor a 5 chars

Igual que 3.2 pero `"title": "Hi"`.

**Esperado:** ❌ **Simulated create denied**
**Por qué:** `isValidArticle()` rechaza `title.size() < 5`.

---

### Caso 3.6 — ✅ Update del mismo autor

| Operation  | `update`                              |
|------------|---------------------------------------|
| Location   | (mismo id del doc creado en 3.2)     |
| Auth uid   | `test-uid-123`                        |

Payload: mismo JSON que 3.2 pero `"title": "Titulo actualizado"` y `"updatedAt": {".sv":"timestamp"}`.

**Esperado:** ✅ **Simulated update allowed**

---

### Caso 3.7 — ❌ Update intentando reasignar `authorId`

Igual que 3.6 pero `"authorId": "test-uid-999"`.

**Esperado:** ❌ **Simulated update denied**
**Por qué:** `request.resource.data.authorId == resource.data.authorId` → false (inmutabilidad).

---

### Caso 3.8 — ❌ Delete por un tercero

| Operation  | `delete`                              |
|------------|---------------------------------------|
| Location   | (mismo id del doc creado en 3.2)     |
| Auth uid   | `otro-uid-999` (no es el autor)       |

**Esperado:** ❌ **Simulated delete denied**
**Por qué:** `resource.data.authorId == request.auth.uid` → false.

---

## 4. Diagrama de decisión — Storage

```
                  ┌─────────────────────────────────────┐
                  │  Petición sobre                      │
                  │  media/articles/{authorId}/          │
                  │         {articleId}/{file}           │
                  └───────────────┬─────────────────────┘
                                  │
                  ┌───────────────┼───────────────┐
                  ▼                                ▼
           ┌────────────┐                ┌────────────────┐
           │   read     │                │     write      │
           └──────┬─────┘                │  (create/      │
                  │                      │   update/      │
                  │                      │   delete)      │
                  ▼                      └───────┬────────┘
           ┌────────────┐                        │
           │ allow:true │          ┌─────────────┼─────────────┐
           │ (feed      │          ▼             ▼             ▼
           │  público)  │   ┌───────────┐ ┌───────────┐ ┌───────────┐
           └────────────┘   │ signedIn? │ │ uid ==    │ │ size <    │
                            │           │ │ authorId? │ │ 5 MiB?    │
                            │           │ │           │ │ image/*?  │
                            └─────┬─────┘ └─────┬─────┘ └─────┬─────┘
                                  │             │             │
                                  ▼             ▼             ▼
                                todas true? → ALLOW · falla alguna → DENY
```

**Por qué el path lleva `{authorId}` como segmento:**

Si el path fuera `media/articles/{articleId}/{file}`, Storage tendría que consultar Firestore (`firestore.get(...).data.authorId == request.auth.uid`) para validar propiedad — caro y cross-service. Con `{authorId}` en el path, basta `request.auth.uid == authorId`: **O(1) sin joins**. Ver [SCHEMA_RATIONALE §4](./SCHEMA_RATIONALE.md#4-por-qué-el-path-incluye-authorid) para el análisis completo.

---

## 5. Casos de prueba — Storage Playground

**Cómo llegar:** Consola Firebase → **Storage → Rules → Rules Playground**.

### Caso 5.1 — ✅ Upload válido

| Campo             | Valor                                                              |
|-------------------|--------------------------------------------------------------------|
| Operation         | `create`                                                           |
| Location          | `/media/articles/test-uid-123/a_1714003200/thumbnail.png`         |
| Authenticated     | **Sí** (uid: `test-uid-123`)                                       |
| contentType       | `image/png`                                                        |
| size              | `2_048_000` (2 MB)                                                 |

**Esperado:** ✅ **Allowed**

---

### Caso 5.2 — ❌ Upload a carpeta ajena

Igual que 5.1 pero path `/media/articles/otro-uid-999/a_1/thumbnail.png`.

**Esperado:** ❌ **Denied**
**Por qué:** `request.auth.uid == authorId` → false.

---

### Caso 5.3 — ❌ Upload de archivo > 5 MiB

Igual que 5.1 pero `size: 6_000_000`.

**Esperado:** ❌ **Denied**
**Por qué:** `request.resource.size < 5 * 1024 * 1024` → false.

---

### Caso 5.4 — ❌ Upload de PDF

Igual que 5.1 pero `contentType: application/pdf`.

**Esperado:** ❌ **Denied**
**Por qué:** `request.resource.contentType.matches('image/.*')` → false.

---

### Caso 5.5 — ✅ Lectura anónima

| Operation     | `get`                                                  |
|---------------|--------------------------------------------------------|
| Location      | cualquier path bajo `/media/articles/...`             |
| Authenticated | **No**                                                 |

**Esperado:** ✅ **Allowed**
**Por qué:** `allow read: if true;` (feed público, las thumbnails tienen que cargarse sin login).

---

## 6. Tabla maestra de validaciones

**Correspondencia uno-a-uno entre reglas, schema y validación cliente.** Si una celda se queda en blanco, es un hueco a documentar o cerrar.

| Campo          | Regla Firestore                                      | Regla Storage         | Validación cliente (use case)                                                       | Argumentación                                                                                       |
|----------------|-------------------------------------------------------|-----------------------|--------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------|
| `id`           | `is string` + `== articleId` (create) + inmutable en update | n/a             | generado client-side (`a_${microsecondsSinceEpoch}`), propagado en `PublishArticleParams` | ver [SCHEMA_RATIONALE §3.1](./SCHEMA_RATIONALE.md#31-por-qué-id-está-duplicado-en-el-documento-y-no-solo-en-el-path) |
| `authorId`     | `is string` + `== request.auth.uid` (create) + inmutable | path = uid          | inyectado desde `AuthSession.currentUser.id`                                         | single source of truth para ownership · ver [SCHEMA_RATIONALE §3.2](./SCHEMA_RATIONALE.md#32-authorid-vs-createdby) |
| `authorName`   | `is string` + `size() in [1, 60]`                     | n/a                   | `AuthSession.currentUser.name`                                                       | denormalizado para el feed · evita N+1 reads                                                         |
| `title`        | `is string` + `size() in [5, 120]`                    | n/a                   | mismo rango en `PublishArticleUseCase._validate`                                     | límite alto por SEO; mínimo para evitar "Hi" como título                                             |
| `description`  | `is string` + `size() <= 280`                         | n/a                   | mismo límite cliente                                                                  | Twitter-style cap; razonable para un teaser                                                          |
| `content`      | `is string` + `size() in [50, 20000]`                 | n/a                   | mismo rango cliente                                                                   | 50 = mínimo de un párrafo útil; 20000 = ~3000 palabras, suficiente para artículos largos             |
| `thumbnailURL` | `is string` + `matches('https://.*')`                 | path whitelisted      | `isNotEmpty` en cliente (regex HTTPS la enforcea rules)                              | debe apuntar a Storage `media/articles/...`                                                          |
| `tags`         | `is list` + `size() <= 5` (opcional)                  | n/a                   | `params.tags.length <= 5`                                                            | balance entre descubribilidad y ruido                                                                 |
| `status`       | `in ['draft', 'published']`                           | n/a                   | enum `UserArticleStatus` en Dart                                                     | sealed string set; fácil de extender a `archived` en el futuro                                       |
| `publishedAt`  | `is timestamp` + `== request.time` (create) + inmutable | n/a                 | `FieldValue.serverTimestamp()` en data source                                        | evita "antedates"; inmutable para preservar integridad del feed                                      |
| `updatedAt`    | `is timestamp` + `== request.time` (ambos write)      | n/a                   | `FieldValue.serverTimestamp()` en data source                                        | se bumpea automáticamente en cada write                                                              |
| **file size**  | n/a                                                   | `< 5 * 1024 * 1024`   | `UploadThumbnailUseCase` valida `bytes.length <= 5 * 1024 * 1024`                    | 5 MiB cubre >95% de fotos reales sin inflar Storage                                                  |
| **contentType**| n/a                                                   | `matches('image/.*')`  | `params.contentType.startsWith('image/')`                                            | JPG/PNG/WebP/HEIC aceptados; PDFs/docs rechazados                                                    |

---

## 7. Cómo cambiar una regla sin romper nada

Si en el futuro se necesita endurecer o relajar una regla, el procedimiento seguro es:

1. **Editar en el repo primero.** Nunca en la consola: los cambios en consola no quedan en git y divergen silenciosamente.
2. **Correr `firebase deploy --dry-run --only firestore:rules,storage:rules`**: valida sintaxis sin subir.
3. **Si hubo cambio semántico en un predicate (p. ej. se añadió un campo nuevo):**
   - Actualizar [`DB_SCHEMA.md`](./DB_SCHEMA.md) en la misma PR.
   - Actualizar [`SCHEMA_RATIONALE.md`](./SCHEMA_RATIONALE.md) si el argumento cambia.
   - Actualizar §6 de este archivo (tabla maestra).
   - Reejecutar los casos §3/§5 y añadir los nuevos si hacen falta.
4. **Deploy real:** `firebase deploy --only firestore:rules` (o `storage:rules`). Si falla, **NO** hacer rollback manual — deploy automático reversible con el commit previo.
5. **Contrastar con los use cases Dart:** las reglas son la última línea de defensa, pero las mismas validaciones viven en `PublishArticleUseCase._validate` y similares. Si divergen, el usuario ve un error que parece arbitrario (`ValidationFailure` del servidor distinto al del cliente). Siempre mantener los dos lados alineados.

**Nunca** relajar una regla temporalmente para "hacer funcionar" una demo. Si hay un caso de uso nuevo, escribirlo como casos de prueba §3/§5 primero y después tocar la regla.
