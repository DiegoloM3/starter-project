# Argumentación del schema — por qué `articles` se ve así

> **Propósito.** Documento complementario a [`DB_SCHEMA.md`](./DB_SCHEMA.md). Mientras ese archivo define **qué** campos existen, este explica **por qué** cada uno fue modelado de esa forma: qué alternativas se consideraron, qué trade-offs se aceptaron, y qué garantiza cada elección respecto a las reglas y la UI.
>
> **A quién va dirigido.** Cualquiera que:
> - Sea reviewer técnico de la prueba y quiera defender el schema sin tener que leer el código.
> - Vaya a evolucionar la feature (añadir comments, likes, etc.) y necesite entender qué reglas del diseño debe respetar.
> - Tenga dudas sobre por qué se denormaliza X, por qué se duplica Y, o por qué un campo es enum y no booleano.

---

## Índice

1. [Principios rectores](#1-principios-rectores)
2. [Forma general de la colección](#2-forma-general-de-la-colección)
3. [Campo por campo](#3-campo-por-campo)
4. [Por qué el path incluye `{authorId}`](#4-por-qué-el-path-incluye-authorid)
5. [Denormalización justificada](#5-denormalización-justificada)
6. [Inmutabilidad y timestamps](#6-inmutabilidad-y-timestamps)
7. [Subcolecciones futuras — headroom dejado](#7-subcolecciones-futuras--headroom-dejado)
8. [Alternativas descartadas](#8-alternativas-descartadas)

---

## 1. Principios rectores

El schema obedece a cuatro principios que guían cada decisión individual:

**P1 — El schema es el contrato.** El documento Firestore es la fuente de verdad para el frontend, para las reglas y para los tests. Cualquier divergencia es bug. Por eso `isValidArticle()` en `firestore.rules` replica literalmente los límites que aplica el cliente en `PublishArticleUseCase._validate`.

**P2 — Las reglas son la última línea de defensa, no la primera.** El cliente valida primero por UX (deshabilitar el botón Publish, mostrar hint "title ≥ 5 chars"). El servidor valida por seguridad. Las dos validaciones están alineadas, pero ninguna se apoya en la otra.

**P3 — Nunca confiar en el cliente.** Campos como `authorId` no se aceptan tal cual vienen: deben igualar `request.auth.uid`. Campos como `publishedAt` no se aceptan como valores literales: deben coincidir con `request.time`.

**P4 — Optimizar para la lectura del feed.** El caso de uso más frecuente es "listar los artículos publicados ordenados por fecha". Eso justifica denormalizar `authorName` en el documento (ver §5) a cambio de aceptar que un cambio de display name no se propague retroactivamente a publicaciones viejas.

---

## 2. Forma general de la colección

**Decisión:** una única colección top-level `articles/{articleId}`, sin sub-collections por autor.

**Alternativa descartada:** `users/{authorId}/articles/{articleId}`.

**Por qué top-level:**

1. **Feed público global.** `articles.where('status', '==', 'published').orderBy('publishedAt', 'desc')` es una query simple contra una colección plana. Con la alternativa, habría que usar `collectionGroup('articles')` con un índice compuesto — más caro y sorprendente para nuevos contributors.
2. **Simetría con el feed de NewsAPI existente.** La feature `daily_news` ya maneja una colección plana de artículos externos. La feature nueva adopta la misma forma, lo que facilita refactors futuros donde las dos fuentes se unifiquen.
3. **Ownership sigue siendo trivial.** Aunque los artículos estén sueltos en top-level, el campo `authorId` + la regla `resource.data.authorId == request.auth.uid` basta para que solo el dueño escriba/borre los suyos. El path del doc no tiene que reflejar propiedad.

**Trade-off aceptado:** no se puede hacer listing de "todos los artículos de un usuario" vía navegación de path. Hay que hacer `articles.where('authorId', '==', uid)`. Para el volumen esperado (decenas de artículos por usuario), esto no introduce costo apreciable.

---

## 3. Campo por campo

### 3.1 `id` (string, obligatorio)

**Qué es:** copia del `documentId` dentro del propio documento.

**Por qué está duplicado:**

- Cuando se renderiza una lista, `QueryDocumentSnapshot.data()` devuelve solo el contenido del doc, no el id. Si el id **no** está en el documento, hay que pasarlo junto como parámetro adicional por cada `ArticleCard`. Esto se vuelve molesto al serializar/deserializar para estado de bloc.
- Tener el id en el doc nos permite usar `UserArticleModel.fromFirestore(data).toEntity()` como una transformación pura, sin necesitar el id por fuera.
- El costo en bytes es despreciable (un string corto).

**Cómo se generan los ids:** client-side en el bloc editor (`a_${DateTime.now().microsecondsSinceEpoch}`). Justificado a fondo en [`../prueba-tecnica/adr/0003-decisiones-consolidadas.md §13`](../../docs/prueba-tecnica/adr/0003-decisiones-consolidadas.md#13-d14--article-id-generado-client-side).

**Invariante:** la regla `request.resource.data.id == articleId` garantiza que nunca se escribe un doc donde el campo `id` y el `documentId` del path difieran.

### 3.2 `authorId` (string, obligatorio, inmutable)

**Qué es:** el `request.auth.uid` del usuario que creó el artículo.

**Por qué es la fuente de verdad para ownership:**

1. Lo aplican las reglas (`resource.data.authorId == request.auth.uid`).
2. Lo aplica el path de Storage (`media/articles/{authorId}/...`).
3. Lo aplican las queries del frontend (`where('authorId', '==', currentUser.id)`).

Los tres usos cruzados hacen que cualquier falsificación falle: un cliente que escriba un `authorId` distinto al suyo tendría el documento rechazado por Firestore antes de llegar a Storage.

**Por qué inmutable en update:**

Permitir reasignar `authorId` abre un vector de abuso: un autor podría "donar" un artículo a otro usuario, lo que contaminaría su feed. Además, el timestamp `publishedAt` quedaría semánticamente roto (¿publicado por quién originalmente?). Se prefiere forzar un delete + re-create si alguna vez se necesita transferir propiedad.

**`authorId` vs `createdBy`:** se descartó el nombre `createdBy` porque sugiere que puede haber un `modifiedBy` distinto. En este schema, el autor **es siempre** el creador; no hay co-edición. `authorId` deja clara esa invariante.

### 3.3 `authorName` (string, obligatorio, 1–60 chars)

**Qué es:** display name del autor, **denormalizado** en el documento.

**Por qué denormalizar:**

Alternativa sería guardar solo `authorId` y resolver el display name vía `users/{uid}.displayName` en tiempo de render. Pero:

- El feed muestra `authorName` de cada tarjeta → N reads adicionales por renderizado (si hay 20 cards, son 21 reads en vez de 1 query).
- Firestore no tiene joins — este es un patrón anti-NoSQL.

**Trade-off aceptado:**

Si un autor cambia su display name (`"Abe" → "Abraham"`), los artículos viejos siguen mostrando `"Abe"` porque el campo se capturó en el momento del write. Esto es **intencional**: preserva la integridad histórica del feed ("esto es lo que estaba firmado en aquel momento"). Si en el futuro se desea propagar renames, se puede añadir una Cloud Function que actualice en batch los documentos afectados.

**Rango 1–60:**

- `1`: obliga a tener al menos un caracter (no strings vacíos).
- `60`: margen cómodo para nombres largos con apellidos compuestos sin permitir contenido abusivo.

### 3.4 `title` (string, obligatorio, 5–120 chars)

**Por qué el mínimo de 5:**

Un título con menos de 5 chars normalmente es basura (`"Hi"`, `"test"`, `"x"`). Frenarlo en rules es más barato que moderarlo después.

**Por qué el máximo de 120:**

- Twitter/X antes era 140. 120 deja espacio para que el preview del feed quepa en una sola línea en móvil (`width: 375, fontSize: 15` → ~110 chars caben).
- SEO práctico: Google trunca meta títulos alrededor de 60 chars en desktop, 70 en móvil. 120 permite variantes de larga cola sin penalizar.

**Por qué string y no rich text:**

Sin emojis/negrita/links en el título — el Figma no los muestra y permitirlos abre la puerta a caracteres zero-width u otros exploits visuales.

### 3.5 `description` (string, obligatorio, 0–280 chars)

**Por qué 280:**

Alineado con el límite histórico de Twitter. Un teaser debe ser lo suficientemente corto como para ser escaneable en el feed, y 280 es un punto dulce validado por miles de millones de usuarios.

**Por qué `obligatorio` con min 0:**

El campo siempre está presente en el doc (tipo `is string`), pero puede estar vacío. Alternativa era usar `optional` (`!('description' in data) || data.description.size() <= 280`), pero eso complica la regla. Más simple: siempre está, puede ser `""`. El cliente enviando `""` es válido.

### 3.6 `content` (string, obligatorio, 50–20000 chars)

**Por qué el mínimo de 50:**

Un artículo con < 50 chars no tiene suficiente sustancia para justificar UI dedicada. Es el mismo umbral que `canPublish` en la entidad — título corto + contenido corto = draft, no publish.

**Por qué el máximo de 20000:**

- ~3000–4000 palabras, suficiente para artículos largos tipo Medium.
- Firestore cobra por doc size. Con 20000 chars (≈ 20 KB UTF-8), seguimos muy por debajo del límite hard de 1 MiB por doc, pero evitamos que un autor suba un libro.
- Si el contenido crece, la migración natural sería mover `content` a Cloud Storage como markdown file y dejar un `contentURL` en Firestore. Documentado como headroom en §7.

**Por qué string plano y no markdown estructurado:**

El Figma no tiene bloques (headings, quotes, embeds). Aceptar markdown como string es la escapatoria más barata si en el futuro se quiere renderizar formato: `flutter_markdown` lee un string y ya. Validación estructural no se necesita en rules — markdown malformado se degrada a texto plano en renderizado, no explota.

### 3.7 `thumbnailURL` (string, obligatorio, regex `https://.*`)

**Por qué `https://` obligatorio:**

Un HTTP plano en 2026 es un error de seguridad (content injection potencial). La regex es conservadora: cualquier URL HTTPS la pasa, incluyendo servidores propios que un futuro cliente podría usar. No se amarra a `firebasestorage.googleapis.com` para preservar flexibilidad.

**Por qué string y no referencia estructurada:**

Alternativa: `{ bucket: "...", path: "media/articles/..." }`. Descartada porque:

- La UI necesita una URL para renderizar con `CachedNetworkImage`. Con la alternativa habría que reconstruirla en cada render.
- La URL devuelta por `ref.getDownloadURL()` ya incluye token de autorización — es HTTPS y es todo lo que se necesita.

**¿Y si el Storage object es borrado pero el doc sigue vivo?**

El thumbnail falla en load y `CachedNetworkImage.errorWidget` muestra un placeholder. No bloquea la lectura del artículo. Una Cloud Function podría mantener consistencia, pero es complejidad que no paga su coste para el volumen esperado.

### 3.8 `tags` (list<string>, opcional, 0–5 elementos)

**Por qué max 5:**

- > 5 tags ya es spam / SEO stuffing.
- Caber en una fila del `Wrap` en la detail page sin overflow.

**Por qué strings sin normalizar (case + espacios):**

Simpleza. La UI parseaa `String.split(',').map(trim)`. Si en el futuro se añade buscador por tag, se podría normalizar a lowercase en el use case antes de enviar, pero no en rules (rules Dart es limitado para transformaciones string).

**Por qué no un enum/whitelist:**

La barrera de entrada para añadir tags nuevos sería toda una PR + deploy. Autor libre = más tags emergentes, buenos para descubribilidad orgánica. El coste (algún tag feo) se paga con moderación humana, no con código.

### 3.9 `status` (enum: `draft` | `published`)

**Por qué enum string y no booleano `published: bool`:**

Permite añadir estados sin migrar docs existentes:

- `archived` — artículo publicado en el pasado, oculto del feed pero accesible por URL directa.
- `pending-review` — si en el futuro se añade moderación.
- `scheduled` — publicación diferida con un campo `publishAt` futuro.

Con `is_published: bool` cada nuevo estado requeriría añadir otra booleana (`is_archived`, `is_scheduled`), lo que lleva a estados inconsistentes (`is_published=true && is_archived=true`).

**Por qué `'draft' | 'published'` en el campo de tipo string y no `int`:**

- Legibilidad en la consola Firestore: se ve `"published"` en vez de `1`.
- Migración más fácil: añadir `'archived'` es cambiar la regla `in ['draft', 'published', 'archived']`, no redefinir un mapeo numérico.

### 3.10 `publishedAt` (timestamp, obligatorio, inmutable, = `serverTimestamp`)

Ver §6.

### 3.11 `updatedAt` (timestamp, obligatorio, = `serverTimestamp`)

Ver §6.

---

## 4. Por qué el path incluye `{authorId}`

**Path elegido:** `media/articles/{authorId}/{articleId}/{file}`.

**Alternativa descartada:** `media/articles/{articleId}/{file}`.

**Razón técnica — reglas de Storage:**

Para que una regla valide "solo el autor puede subir imágenes a los artículos que posee", hay dos caminos:

**Camino A (path sin authorId):**
```
match /media/articles/{articleId}/{file} {
  allow write: if request.auth != null
    && firestore.get(/databases/(default)/documents/articles/$(articleId))
                .data.authorId == request.auth.uid
    && ...;
}
```

- **Latencia extra:** `firestore.get` dentro de Storage rules añade un RPC por petición.
- **Facturación:** cada upload cuenta un doc read de Firestore.
- **Ciclo de vida:** al crear un artículo, el usuario sube el thumbnail **antes** de que exista el doc. `firestore.get` devolvería null y la regla fallaría. Forzaría un orden raro: crear doc vacío → subir thumbnail → actualizar doc con URL. Tres round-trips.

**Camino B (path con authorId) — elegido:**
```
match /media/articles/{authorId}/{articleId}/{file} {
  allow write: if request.auth != null
    && request.auth.uid == authorId
    && ...;
}
```

- **O(1), sin cross-service:** un `==` local basta.
- **Upload antes del create del doc:** funciona siempre — el path es auto-suficiente.
- **Revisable en consola:** navegando el Storage bucket se ve "qué autor ha subido qué".

### Consecuencia aceptada

El cliente necesita conocer `authorId` (lo obtiene de `AuthSession.currentUser.id`) y `articleId` (generado client-side) **antes** de subir. Esto es lo que justifica la decisión de generar ids client-side — ver [`ADR-0003 §13`](../../docs/prueba-tecnica/adr/0003-decisiones-consolidadas.md#13-d14--article-id-generado-client-side).

---

## 5. Denormalización justificada

Los dos lugares donde el schema "duplica" información respecto a una forma relacional pura:

### 5.1 `id` en el documento (además del `documentId`)

Ya argumentado en §3.1. Costo: ~30 bytes por doc. Beneficio: serialización sin metadatos adicionales.

### 5.2 `authorName` en cada artículo

Ya argumentado en §3.3. Costo: posible divergencia con el perfil actual del autor. Beneficio: 1 read por feed en vez de N+1.

### 5.3 Nada más se denormaliza

Explícitamente **no** se denormalizan:

- **Número de comentarios / likes.** Cuando se implementen, se mantendrán en subcollections y se agregarán vía Cloud Functions (counter documents). Denormalizarlos en el doc del artículo introduce race conditions en updates concurrentes.
- **Tags del autor (su "top 5 de tags usados").** Es una vista derivada; se calcula on-demand o se precomputa fuera del doc.

---

## 6. Inmutabilidad y timestamps

### 6.1 Qué campos son inmutables en update

| Campo         | Motivo                                                                 |
|---------------|------------------------------------------------------------------------|
| `id`          | El documento vive bajo ese path. Cambiarlo sería mover el doc, no actualizarlo. |
| `authorId`    | Ownership es inmutable — ver §3.2.                                     |
| `publishedAt` | Integridad del feed histórico — la fecha de publicación no se antedata. |

Enforzado por las líneas de `firestore.rules`:

```
request.resource.data.id == resource.data.id
&& request.resource.data.authorId == resource.data.authorId
&& request.resource.data.publishedAt == resource.data.publishedAt
```

### 6.2 Por qué ambos timestamps se escriben con `serverTimestamp()`

**Alternativa:** `DateTime.now()` desde el cliente.

Descartada porque:

- **Clock skew:** el reloj del cliente puede diferir del servidor. Un cliente con fecha futura podría "antedatar" un artículo y saltar al top de `orderBy('publishedAt', desc)`.
- **Zonas horarias:** `DateTime.now()` devuelve hora local; reconciliarlo con UTC requiere disciplina en cada call site.
- **Auditoría:** si algo falla, saber que el timestamp es el del servidor elimina la variable "reloj del cliente" de la investigación.

La regla `request.resource.data.publishedAt == request.time` garantiza que el único valor aceptado es el del servidor.

**Consecuencia en el cliente:** en el data source, el payload se escribe con `FieldValue.serverTimestamp()`, y el snapshot de vuelta trae ya un `Timestamp` concreto. Entre el write y el siguiente read, el campo puede aparecer temporalmente como `null` en la cache local — por eso `UserArticleModel._asDate()` tiene un fallback a `DateTime.now()` para ese caso transitorio.

### 6.3 Por qué `publishedAt` es inmutable pero `updatedAt` se bumpea

- `publishedAt` = "cuándo se publicó por primera vez". No cambia aunque el autor edite 10 veces.
- `updatedAt` = "cuándo se tocó por última vez". Se sobrescribe en cada write.

Esto permite:

- Feed público ordenado por `publishedAt desc` = orden cronológico estable.
- Listado del autor ordenado por `updatedAt desc` = ver lo que editaste recientemente arriba.

---

## 7. Subcolecciones futuras — headroom dejado

El schema está pensado para que añadir las siguientes features no rompa los docs existentes:

### 7.1 `articles/{articleId}/comments/{commentId}`

```jsonc
{
  "authorId":  "uid",
  "authorName":"Display",
  "body":      "...",
  "createdAt": serverTimestamp
}
```

- Nada que cambiar en `isValidArticle()` — la regla ya es tolerante a campos extra vía el patrón `data.keys().hasAll(...)`.
- Se añaden reglas nuevas bajo `match /articles/{articleId}/comments/{commentId} { ... }`.

### 7.2 `articles/{articleId}/likes/{userId}`

Presencia ⇒ liked. Un documento vacío (o con `createdAt`) por usuario. El `count` se mantiene vía Cloud Function o Firestore aggregation query.

### 7.3 `content` migrado a Storage

Si en el futuro los artículos se vuelven muy largos (> 20 KB), migrar a `contentURL: string` apuntando a `media/articles/{authorId}/{articleId}/content.md`. Los docs existentes no se romperían — la regla `content.size() <= 20000` seguiría valiendo para los que aún tengan el campo inline, y los nuevos usarían el field alternativo. El cliente puede hacer fallback `contentURL ?? content`.

---

## 8. Alternativas descartadas

Recoge ideas que sonaban atractivas pero se rechazaron por razones explícitas.

### 8.1 `slug` auto-generado del título

**Idea:** `slug: string` derivado de `title` para URLs amigables (`/article/clean-architecture-en-flutter`).

**Por qué no:** el mapping slug → id sería otra colección de lookup o una query adicional. Con el id actual (`a_1714003200`) las URLs son feas pero funcionan sin overhead. Si en el futuro SEO importa, se agrega slug como campo opcional.

### 8.2 `contentPreview` generado del primer párrafo

**Idea:** duplicar los primeros 160 chars del `content` como `contentPreview` para renderizar en el feed sin bajar 20 KB por tarjeta.

**Por qué no:** `description` ya cumple este rol. Duplicar introduce una invariante más que mantener (si el autor edita el contenido, hay que re-derivar el preview). `description` es un campo que el autor controla explícitamente.

### 8.3 `wordCount` precomputado

**Idea:** almacenar `wordCount: int` para mostrar "5 min read" en el listado.

**Por qué no:** trivial de calcular en el cliente a partir de `content.split(' ').length`. No justifica ocupar espacio en el doc ni mantener invariante al actualizar.

### 8.4 `language` para internacionalización

**Idea:** `language: 'es' | 'en' | ...` para filtrar el feed por idioma del usuario.

**Por qué no:** out-of-scope para la prueba. Se puede añadir sin romper nada — `!('language' in data) || data.language is string` en la regla y el cliente deja `language: null` para docs viejos.

### 8.5 Schema polimórfico (artículos de distintos tipos)

**Idea:** `type: 'article' | 'video' | 'link'` y campos específicos por tipo.

**Por qué no:** complica las reglas significativamente (cada tipo necesita `isValidX()`). La prueba pide solo artículos de texto. Si en el futuro se soportan otros formatos, lo más limpio es una colección separada (`videos/`, `links/`) con schema dedicado.

---

## Cómo se conecta con el resto del proyecto

| Artefacto                                        | Rol                                                                      |
|--------------------------------------------------|--------------------------------------------------------------------------|
| [`DB_SCHEMA.md`](./DB_SCHEMA.md)                 | Especificación formal de campos y tipos. "El contrato."                  |
| **Este archivo**                                 | Narrativa de por qué. "La justificación del contrato."                   |
| [`RULES_VISUAL.md`](./RULES_VISUAL.md)           | Cómo subir y probar las reglas que enforzan el contrato.                 |
| [`../firestore.rules`](../firestore.rules)       | Implementación del contrato en el servidor.                              |
| [`../storage.rules`](../storage.rules)           | Implementación del contrato a nivel de archivo.                          |
| [`../../frontend/lib/features/user_articles/domain/params/*.dart`](../../frontend/lib/features/user_articles/domain/params/) | Contrato replicado en Dart para validación cliente. |
| [`../../frontend/lib/features/user_articles/data/models/user_article_model.dart`](../../frontend/lib/features/user_articles/data/models/user_article_model.dart) | Mapeo Firestore ↔ entidad. |
| [`../../docs/prueba-tecnica/adr/0003-decisiones-consolidadas.md §9`](../../docs/prueba-tecnica/adr/0003-decisiones-consolidadas.md#9-d10--esquema-reglas-y-paths) | Resumen cruzado con las otras decisiones del proyecto. |

**Si alguna celda de esta tabla se desincroniza con las demás, es un bug de diseño.** Mantener los cinco alineados es responsabilidad de cada PR que toque el schema.
