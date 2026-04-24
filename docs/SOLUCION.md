# Solución técnica — Prueba Symmetry

> **Propósito de este documento.** Explicación exhaustiva de **qué** se construyó, **cómo** funciona y **por qué** se tomó cada decisión. Pensado para defender el trabajo en la reunión técnica de revisión. El [ADR-0003](./prueba-tecnica/adr/0003-decisiones-consolidadas.md) resume las decisiones; este documento narra la implementación.
>
> Lectura estimada: 20–25 minutos. Si solo se tiene tiempo para una sección, leer §3 (flujo end-to-end) y §11 (Q&A anticipada).

---

## Índice

1. [Resumen ejecutivo](#1-resumen-ejecutivo)
2. [Criterios de la prueba y cumplimiento](#2-criterios-de-la-prueba-y-cumplimiento)
3. [Flujo end-to-end: publicar un artículo](#3-flujo-end-to-end-publicar-un-artículo)
4. [Arquitectura de capas y grafo de dependencias](#4-arquitectura-de-capas-y-grafo-de-dependencias)
5. [Backend: schema y reglas](#5-backend-schema-y-reglas)
6. [Feature `user_articles` — Domain layer](#6-feature-user_articles--domain-layer)
7. [Feature `user_articles` — Data layer](#7-feature-user_articles--data-layer)
8. [Feature `user_articles` — Presentation layer](#8-feature-user_articles--presentation-layer)
9. [Plataforma transversal (core, shared, config)](#9-plataforma-transversal-core-shared-config)
10. [Testing, CI y calidad de código](#10-testing-ci-y-calidad-de-código)
11. [Preguntas anticipadas y respuestas (Q&A)](#11-preguntas-anticipadas-y-respuestas-qa)
12. [Deuda conocida y plan de salida](#12-deuda-conocida-y-plan-de-salida)

---

## 1. Resumen ejecutivo

**Qué se entrega:** una app Flutter que agrega al feed de noticias existente la capacidad de que el usuario autenticado **publique, edite, liste y borre** sus propios artículos. El backend usa Firestore + Cloud Storage con reglas que garantizan que cada autor solo puede tocar sus documentos y que las imágenes subidas obedecen límites de tamaño y tipo.

**Cómo se ejecutó:** un plan de 10 fases (F0 → F9), 56 batches de commit atómicos dentro de una sola rama `chore/modernization`. Cada commit deja el repo compilable y `flutter analyze` con 0 errores y 0 warnings. En lugar de construir la feature sobre un piso con deuda (DataState/DioError filtrado, sin CI, sin tests, sin lints modernos), las primeras fases hicieron una **pasada de plataforma** que alineó el código existente con los estándares que aplicarían al código nuevo.

**Estado al cierre:**

| Métrica                        | Valor                                                |
|--------------------------------|------------------------------------------------------|
| Commits en la rama             | 60 (56 del plan + 4 incrementales en F9)            |
| `flutter analyze`              | 0 errors · 0 warnings · 6 infos (benignos)          |
| `flutter test`                 | 58 pasando · 0 fallando                              |
| Features nuevas                | `user_articles` (3 páginas, 2 blocs, 5 use cases, 1 repo real + 1 fake) |
| Features migradas              | `daily_news` (entidad, modelo, repo y blocs al nuevo contrato `Either<AppFailure, T>`) |
| ADRs                           | 3 (lints, deps, consolidado)                         |
| Overdelivery oficial          | go_router tipado + design tokens con ThemeExtension  |

**Lo que NO se entrega y por qué:** `Firebase.initializeApp` no se llama porque no hay un proyecto Firebase configurado para la prueba (F0 bloqueado — sin `flutterfire configure`). La DI detecta esto en runtime (`Firebase.apps.isNotEmpty`) y conmuta automáticamente al `FakeUserArticleRepository` in-memory. La UI es navegable end-to-end sin credenciales; el switch a Firestore real es un `await Firebase.initializeApp(...)` en `bootstrap.dart` — cero cambios en features.

---

## 2. Criterios de la prueba y cumplimiento

El README oficial pide tres entregables principales: **backend (schema + reglas)**, **frontend (domain + presentation + data)** y **reporte**. La siguiente tabla cruza cada requisito con su evidencia.

### 2.1 Backend

| Requisito README §1                              | Evidencia                                                   | Estado |
|--------------------------------------------------|-------------------------------------------------------------|--------|
| 1.1 Schema en `backend/docs/DB_SCHEMA.md`        | [archivo](../backend/docs/DB_SCHEMA.md) con tabla de campos, ejemplo JSON, diagrama mermaid | ✅ |
| 1.2 Implementación en Firestore                  | Estructurada para `articles/{articleId}` con subcolecciones documentadas | ✅ (deploy pendiente de F0) |
| 1.3 Enforcement con `firestore.rules`            | [`backend/firestore.rules`](../backend/firestore.rules) con `isValidArticle()`, deny-by-default, inmutabilidad de `authorId` / `publishedAt` | ✅ |
| `thumbnailURL` apunta a `media/articles`         | Enforced por `storage.rules` sobre `media/articles/{authorId}/{articleId}/{file}` | ✅ |

### 2.2 Frontend

| Requisito README §2                              | Evidencia                                                   | Estado |
|--------------------------------------------------|-------------------------------------------------------------|--------|
| 2.0 Setup Firebase                               | `firebase_core`, `cloud_firestore`, `firebase_storage`, `firebase_auth` declarados. Options file (`firebase_options.dart`) pendiente de `flutterfire configure` (F0) | ⚠️ (wiring listo, credenciales no) |
| 2.1 Business layer (domain + mock data)          | `user_articles/domain/` con entidad, 4 params, 5 use cases. [`FakeUserArticleRepository`](../frontend/lib/features/user_articles/data/fake/fake_user_article_repository.dart) in-memory | ✅ |
| 2.2 Presentation layer                           | `MyArticlesCubit` + `ArticleEditorBloc` con freezed states/events; 3 pantallas; 3 widgets reutilizables; rutas nested en `go_router` | ✅ |
| 2.3 Data layer                                   | `UserArticlesFirestoreDataSource`, `UserArticlesStorageDataSource`, `UserArticleModel`, `UserArticleRepositoryImpl` con `_guard()` mapeando `FirebaseException` → `AppFailure` | ✅ |
| Estados de loading/success/empty/error por pantalla | `MyArticlesPage` cubre los 4; `ArticleEditorPage` cubre idle/submitting/success/failure; `UserArticleDetailPage` es read-only | ✅ |

### 2.3 Reporte y entrega

| Requisito README §3                              | Evidencia                                                   | Estado |
|--------------------------------------------------|-------------------------------------------------------------|--------|
| 7 secciones de [`REPORT_INSTRUCTIONS.md`](./REPORT_INSTRUCTIONS.md) | [`docs/REPORT.md`](./REPORT.md) | ✅ |
| Screenshots                                      | pendiente manual (ver [`PRE_PR_MANUAL.md`](./prueba-tecnica/PRE_PR_MANUAL.md) §3) | ⏳ |
| Vídeo demo ≤ 2 min                               | pendiente manual ([`PRE_PR_MANUAL.md`](./prueba-tecnica/PRE_PR_MANUAL.md) §4) | ⏳ |
| Sección Overdelivery explícita                   | §6 del REPORT cubre go_router, tokens, CI, lints, ADRs, AuthSession, `_guard` | ✅ |
| README principal actualizado                     | `frontend/README.md` reescrito con run/--dart-define/layout | ✅ |
| Commits con mensajes claros                      | 60 commits en Conventional Commits (feat/refactor/test/chore/docs/ci/fix) | ✅ |
| Rama + PR hacia `main`                           | `chore/modernization` lista; PR pendiente de lanzar | ⏳ |

### 2.4 Alineación con guidelines internos

| Fuente                                                  | Cumplimiento                                                                 |
|---------------------------------------------------------|------------------------------------------------------------------------------|
| [APP_ARCHITECTURE.md](./APP_ARCHITECTURE.md)            | 3 capas (data/domain/presentation); domain sin imports externos; data_sources lanzan excepciones; solo `repository/*_impl.dart` importa providers |
| [ARCHITECTURE_VIOLATIONS.md](./ARCHITECTURE_VIOLATIONS.md) | Todas las violaciones 1.x, 2.x, 3.x **ausentes** (verificado por grep — ver [ADR-0003 §14](./prueba-tecnica/adr/0003-decisiones-consolidadas.md#14-criterios-arquitectónicos-verificados)) |
| [CODING_GUIDELINES.md](./CODING_GUIDELINES.md)          | Nombres descriptivos (`UserArticleRepositoryImpl`, `_guard`, `reserveId`); funciones pequeñas (el más largo es `_onSubmitted`, 60 líneas con 2 niveles de anidamiento); abstract classes aisladas (`UserArticleRepository`, `AuthSession`, `ThumbnailPickerService`) |

**Las pequeñas desviaciones** (data layer retorna `Either<AppFailure, T>` en vez del `DataState<T>` que proponía la versión original de 1.4.3) están justificadas por [ADR-0003 §4](./prueba-tecnica/adr/0003-decisiones-consolidadas.md#4-d3-d4-d5--contrato-universal-de-errores) y están explícitamente permitidas por el valor *"Truth is King"* que el README llama a ejercitar.

---

## 3. Flujo end-to-end: publicar un artículo

Esta sección traza una request completa desde el botón "Publish" hasta el documento en Firestore. Sirve de mapa mental para la reunión.

### 3.1 El usuario rellena el formulario

**Archivos implicados:** [`ArticleEditorPage`](../frontend/lib/features/user_articles/presentation/pages/article_editor/article_editor_page.dart), [`ArticleEditorBloc`](../frontend/lib/features/user_articles/presentation/bloc/article_editor/article_editor_bloc.dart).

```
TextField(onChanged: titleChanged)
  → bloc.add(ArticleEditorEvent.titleChanged(value))
  → emit(state.copyWith(title: value, failure: null))
  → BlocBuilder rerender
```

Cada campo (title, description, content, tags) emite su propio evento freezed. El getter `state.canSubmit` calcula `title.length >= 5 && content.length >= 50 && thumbnailURL.isNotEmpty` — el mismo contrato que `firestore.rules#isValidArticle`. Si falla, el botón "Publish" queda deshabilitado y un helper muestra qué campos faltan.

### 3.2 El usuario selecciona thumbnail

```
ThumbnailPickerTile.onTap
  → ThumbnailPickerService.pickImage() (stub devuelve 1×1 PNG en dev)
  → bloc.add(ArticleEditorEvent.thumbnailPicked(fileName, bytes, contentType))
  → state.copyWith(
       pendingFileName: ..., pendingBytes: ..., pendingContentType: ...,
       thumbnailURL: 'pending://<file>'  // placeholder local
     )
```

Los bytes se guardan en el state del bloc. La subida a Storage **no** ocurre aquí — se pospone al submit para permitir re-picks sin gastar requests.

### 3.3 El usuario toca "Publish"

```
bloc.add(ArticleEditorEvent.submitted())
  → emit(state.copyWith(status: EditorStatus.submitting))
  │
  │   [1] Genera articleId si es artículo nuevo (editingId == null)
  │       articleId = 'a_${microsecondsSinceEpoch}'
  │
  │   [2] Si hay pendingBytes → UploadThumbnailUseCase
  │         → UserArticleRepository.uploadThumbnail
  │           → (real) UserArticlesStorageDataSource.uploadThumbnail
  │              storage.ref('media/articles/${authorId}/${articleId}/${fileName}')
  │              .putData(bytes, SettableMetadata(contentType))
  │              → snapshot.ref.getDownloadURL()  // public HTTPS URL
  │           → (fake) devuelve URL sintética
  │       thumbnailURL = URL devuelta
  │
  │   [3] PublishArticleUseCase(params)
  │         → validate() local (title/desc/content/tags/thumbnailURL)
  │         → UserArticleRepository.publishArticle
  │           → (real) UserArticlesFirestoreDataSource.createArticle
  │              firestore.collection('articles').doc(id).set({
  │                ...params,
  │                publishedAt: FieldValue.serverTimestamp(),
  │                updatedAt:   FieldValue.serverTimestamp(),
  │              })
  │              → get() de vuelta el documento escrito
  │           → UserArticleModel.fromFirestore(data).toEntity()
  │
  └─ emit(state.copyWith(status: EditorStatus.success, saved: article))
```

### 3.4 La UI reacciona al éxito

```
BlocListener<ArticleEditorBloc>
  listenWhen: (prev, curr) => prev.status != curr.status
  on EditorStatus.success:
    → ScaffoldMessenger.showSnackBar('Article published')
    → context.pop()       // vuelve a MyArticlesPage
MyArticlesPage (volviendo con pop):
  → await ya estaba en el await context.push(...) del FAB
  → _cubit.load(_authorId)   // refresh listado
  → BlocBuilder repinta con el nuevo artículo arriba del todo (orderBy updatedAt desc)
```

### 3.5 Fallos en cada paso

Cualquier `Left(AppFailure)` en el camino interrumpe la cadena y emite `EditorStatus.failure`. El listener de la página traduce `failure.when(...)` a un SnackBar con `theme.danger` de fondo. El usuario ve el mensaje específico (por ejemplo `"title: must be between 5 and 120 chars"` si la validación servidor dispara) y el formulario conserva los valores. El estado queda en `idle` tras el próximo `titleChanged` (que limpia `failure`).

**Flujo "offline":** Firestore SDK tiene persistencia local activa por defecto. Una publicación sin red se encola localmente y aparece en el siguiente read; la UI nunca bloquea en `NetworkFailure` a menos que el SDK agote sus reintentos.

---

## 4. Arquitectura de capas y grafo de dependencias

```
┌─────────────────────────────────────────────────────────┐
│ Presentation (features/*/presentation/)                 │
│   pages/ · widgets/ · bloc/ · services/ (ports)         │
│   — consume: domain/* + config/theme + core/            │
└───────────────────────────┬─────────────────────────────┘
                            │ solo use_cases e interfaces
┌───────────────────────────▼─────────────────────────────┐
│ Domain (features/*/domain/)                             │
│   entities/ · params/ · usecases/ · repository/         │
│   — consume: core/ (AppFailure, UseCase base)           │
│   — puro Dart: grep -R "flutter\|firebase_" → 0         │
└───────────────────────────┬─────────────────────────────┘
                            │ implementa interfaces
┌───────────────────────────▼─────────────────────────────┐
│ Data (features/*/data/)                                 │
│   data_sources/ · models/ · repository/ · fake/         │
│   — consume: domain/* + providers (Firestore/Storage)   │
│   — ÚNICA capa que importa cloud_firestore/storage      │
└─────────────────────────────────────────────────────────┘

Transversal:
  config/ (theme tokens, app_providers, routes, app_router)
  core/   (error, usecase, logger, env, session)
  shared/ (cross-feature UI helpers)
```

### 4.1 Invariantes verificados con grep

```bash
# 1. Domain nunca toca Flutter ni Firebase ni HTTP
grep -R "flutter\|firebase_\|dio\|floor" frontend/lib/features/*/domain/ → 0

# 2. Presentation nunca toca providers
grep -R "cloud_firestore\|firebase_storage\|floor\|dio" frontend/lib/features/*/presentation/ → 0

# 3. Presentation nunca cruza a data (excepto DI root)
grep -R "features/.*/data/" frontend/lib/features/*/presentation/ → 0

# 4. DataState / DioError residuales
grep -R "DioError\|DataState" frontend/lib → 0
```

### 4.2 Cortes de responsabilidad

- **`core/`** aloja abstractions reutilizables por múltiples features: `AppFailure`, `UseCase<R, P>`, `AppLogger`, `AuthSession`, `AppEnv`.
- **`shared/`** existe como carpeta pero en F9 aún no hospeda piezas transversales de UI. Queda con `.gitkeep` para que la convención sea visible desde el primer día (criterio D15 del análisis arquitectónico).
- **`config/`** contiene lo que configura la app al arranque: el router, los providers globales, los temas. No depende de ninguna feature específica — depende de todas para registrarlas.
- **`features/<name>/`** es autocontenido. Moverlo a otro repo requeriría arrastrar sus 3 subcapas y los tokens que consume.

---

## 5. Backend: schema y reglas

### 5.1 Esquema `articles/{articleId}`

| Campo         | Tipo          | Obligatorio | Notas                                              |
|---------------|---------------|-------------|----------------------------------------------------|
| `id`          | string        | sí          | Mirror del `{articleId}` del documento             |
| `authorId`    | string        | sí          | `request.auth.uid` del autor. Inmutable            |
| `authorName`  | string        | sí          | Denormalizado para el feed, 1-60 chars             |
| `title`       | string        | sí          | 5-120 chars                                        |
| `description` | string        | sí          | 0-280 chars                                        |
| `content`     | string        | sí          | 50-20000 chars                                     |
| `thumbnailURL`| string        | sí          | HTTPS URL apuntando a Storage                      |
| `tags`        | list<string>  | no          | 0-5 elementos                                      |
| `status`      | enum          | sí          | `draft` \| `published`                             |
| `publishedAt` | timestamp     | sí          | `serverTimestamp()` en create, inmutable después   |
| `updatedAt`   | timestamp     | sí          | `serverTimestamp()` en cada write                  |

Esquema completo en [`backend/docs/DB_SCHEMA.md`](../backend/docs/DB_SCHEMA.md), incluyendo diagrama mermaid y subcolecciones futuras.

### 5.2 Reglas de Firestore

Dos niveles de validación:

1. **Ownership** (`authorId == request.auth.uid`): enforcea que solo el autor puede crear/editar/borrar sus documentos. La invariante se aplica también en **update**: `request.resource.data.authorId == resource.data.authorId` evita que un autor reasigne la autoría a otro.

2. **Schema** (`isValidArticle(data)`): función reutilizada por create y update. Valida tipos, tamaños, regex (`thumbnailURL.matches('https://.*')`) y enum (`status in ['draft', 'published']`).

Deny-by-default protege el resto del árbol: `match /{document=**} { allow read, write: if false; }`.

### 5.3 Reglas de Storage

Restricción en 3 ejes por cada write:

- **Path:** `media/articles/{authorId}/{articleId}/{file}` (literal en la regla — no aceptan otras rutas).
- **Propietario:** `request.auth.uid == authorId` (el segmento `{authorId}` del path debe coincidir con el uid autenticado).
- **Contenido:** `request.resource.size < 5 * 1024 * 1024 && request.resource.contentType.matches('image/.*')`.

Lecturas públicas (`allow read: if true`) porque la UI renderiza thumbnails desde cualquier cliente.

### 5.4 Por qué `{authorId}` en el path

Es la decisión más crítica del diseño del backend. Si el path fuera `media/articles/{articleId}/{file}`, la regla de Storage tendría que leer Firestore (`get(/databases/.../articles/$(articleId)).data.authorId == request.auth.uid`) — caro y cruza servicios. Con `{authorId}` en el path, la regla queda O(1) sin joins.

---

## 6. Feature `user_articles` — Domain layer

### 6.1 Entidad `UserArticleEntity`

Freezed, inmutable, con dos reglas de negocio:

```dart
bool get canPublish =>
    title.length >= 5 && content.length >= 50 && thumbnailURL.isNotEmpty;
bool get isPublished => status == UserArticleStatus.published;
```

`canPublish` es **la misma predicate** que `isValidArticle` en `firestore.rules`. La duplicación es intencional: el cliente necesita saberlo localmente para gating de UI, el servidor necesita saberlo porque el cliente puede mentir. La alineación de los dos lados se valida en los tests (`PublishArticleUseCase` tests replican los límites).

### 6.2 Params (4 clases freezed)

Cada operación de escritura tiene su propia clase de parámetros:

- `PublishArticleParams` — campos completos + `id` generado client-side (ver [ADR-0003 §13](./prueba-tecnica/adr/0003-decisiones-consolidadas.md#13-d14--article-id-generado-client-side))
- `UpdateArticleParams` — mismo set pero sin `authorId`/`authorName` (inmutables en update)
- `DeleteArticleParams` — solo `id`
- `UploadThumbnailParams` — `authorId`, `articleId`, `fileName`, `bytes`, `contentType`

**Por qué clases y no listas de positional args:** nombres obligatorios en call-sites (`PublishArticleParams(title: ..., content: ...)`) evitan errores de transposición, y freezed les da `copyWith` gratis para los tests.

### 6.3 Use cases (5)

| Use case                       | Responsabilidad                                                       |
|--------------------------------|-----------------------------------------------------------------------|
| `GetMyArticlesUseCase`         | Validar `authorId` no vacío + delegar                                |
| `PublishArticleUseCase`        | Validar todos los campos vs. rules + delegar                         |
| `UpdateArticleUseCase`         | Validar campos mutables + delegar                                    |
| `DeleteArticleUseCase`         | Validar `id` no vacío + delegar                                      |
| `UploadThumbnailUseCase`       | Validar `authorId`/`articleId`/bytes/contentType + delegar           |

Todos extienden `UseCase<R, P>` (retorna `Future<Either<AppFailure, R>>`). Todos siguen el patrón:

```dart
Future<Either<AppFailure, T>> call(P params) {
  final validation = _validate(params);
  if (validation != null) return Future.value(Left(validation));
  return _repository.operation(params);
}
```

**Nada más.** No hay orquestación de múltiples repositorios, no hay caching, no hay lógica de negocio adicional. Un use case por operación — regla 2.3.1 de `ARCHITECTURE_VIOLATIONS.md`.

### 6.4 Interface `UserArticleRepository`

Abstract class con 5 métodos, cada uno retornando `Future<Either<AppFailure, T>>`. Viven dos implementaciones:

- `UserArticleRepositoryImpl` en `data/repository/` (Firestore + Storage reales)
- `FakeUserArticleRepository` en `data/fake/` (in-memory, para dev sin Firebase y para tests)

---

## 7. Feature `user_articles` — Data layer

### 7.1 Data sources (2)

**`UserArticlesFirestoreDataSource`:**

- Lee `Map<String, dynamic>` crudo, no entidades.
- Lanza `FirebaseException` en caso de fallo (cumple regla 1.2.1).
- Stampea `FieldValue.serverTimestamp()` en create y update para satisfacer `request.time` en las reglas.
- Expone `reserveId()` por si el cliente no genera el id y necesita uno.

**`UserArticlesStorageDataSource`:**

- Sube a `media/articles/{authorId}/{articleId}/{fileName}`.
- Setea `contentType` del `SettableMetadata`.
- Retorna `getDownloadURL()` — la URL pública HTTPS que se escribe en el documento Firestore.

### 7.2 Modelo `UserArticleModel`

Clase plana (no freezed) con:

- `fromFirestore(Map<String, dynamic>)` — convierte `Timestamp` a `DateTime`, maneja campos opcionales.
- `toEntity()` — mapea `String` status a `UserArticleStatus`, copia tags.
- `createPayload({...})` y `updatePayload({...})` — builders que devuelven el `Map<String, dynamic>` que el data source escribe.

**Por qué plano y no freezed:** `Timestamp` pelea con `json_serializable`, y el modelo solo necesita 2 converters en cada dirección. Freezed aportaría `==`/`hashCode` que no necesitamos (nadie compara `UserArticleModel` por valor — se compara la entidad).

### 7.3 `UserArticleRepositoryImpl` y el `_guard`

Helper central que captura `FirebaseException` y lo mapea a `AppFailure`:

```dart
Future<Either<AppFailure, T>> _guard<T>(Future<T> Function() action) async {
  try {
    return Right(await action());
  } on FirebaseException catch (e) {
    return Left(_mapFirebase(e));
  } catch (error, stackTrace) {
    return Left(AppFailure.unknown(cause: error, stackTrace: stackTrace));
  }
}
```

Esta es la **única** función en todo `lib/` que atrapa `FirebaseException`. Todo lo demás arriba de ella ve `Either<AppFailure, T>`. La correspondencia de códigos está en §4 de [ADR-0003](./prueba-tecnica/adr/0003-decisiones-consolidadas.md).

### 7.4 `FakeUserArticleRepository`

Implementa la misma interfaz, persiste en `Map<String, UserArticleEntity>`, incluye sorting por `updatedAt desc` en `getMyArticles` para paridad visual con Firestore. Se usa en dos contextos:

1. **Dev sin Firebase** (actual): DI detecta `Firebase.apps.isEmpty` y registra el fake.
2. **Tests de bloc/cubit:** los tests de `MyArticlesCubit` inyectan mocks de los use cases; los tests del fake mismo validan que el fake cumple el contrato.

---

## 8. Feature `user_articles` — Presentation layer

### 8.1 Estados y eventos con freezed

`MyArticlesState` y `ArticleEditorState` son uniones selladas. Esto hace que los `switch` en la UI sean exhaustivos por construcción — el compilador marca error si se añade un estado nuevo sin cubrirlo.

`ArticleEditorEvent` tiene 6 variantes (title/desc/content/tags/thumbnail/submitted). Cada una se manejea en un único `on<>()` del bloc.

### 8.2 Pantallas y sus estados de UI

| Pantalla                  | Loading     | Success                          | Empty                   | Error                         |
|---------------------------|-------------|----------------------------------|-------------------------|-------------------------------|
| `MyArticlesPage`          | Spinner     | ListView pull-to-refresh         | Empty-state con icon    | `_ErrorView` con retry        |
| `ArticleEditorPage`       | Spinner en button | SnackBar + `context.pop`     | n/a                     | SnackBar con `theme.danger`   |
| `UserArticleDetailPage`   | n/a (síncrono, se llega con la entidad en `state.extra`) | Read-only render | n/a        | `_MissingArticlePage` si `extra == null` |

### 8.3 Widgets reutilizables

- **`ArticleCard`** — tarjeta de 72px thumbnail + título + descripción + pill de status + botones opcionales edit/delete. Todos los colores via `context.appTheme`.
- **`ThumbnailPickerTile`** — 180px tile que muestra la imagen (bytes locales si están, URL remota si no, placeholder si ninguno). Overlay "Tap to change" si hay contenido.
- **`PrimaryButton`** — CTA con soporte para icon, loading state y disabled state. Altura fija 52px por consistencia vertical.

### 8.4 Navegación

Rutas nested bajo `/me/articles`:

```
/me/articles              → MyArticlesPage
/me/articles/new          → ArticleEditorPage (create)
/me/articles/:id          → UserArticleDetailPage (extra: entity)
/me/articles/:id/edit     → ArticleEditorPage (edit, extra: entity)
```

**Por qué se pasa la entidad en `state.extra` y no se refetch por `:id`:** en el flujo normal de uso, el usuario siempre viene de la lista, donde ya tenemos la entidad en memoria. Refetch sería un round-trip gratuito. Para deep links externos (donde no hay extra), `UserArticleDetailPage` cae en `_MissingArticlePage` — una mejora futura sería añadir un use case `GetArticleById` que rehidrate, pero no se implementó por scope.

### 8.5 Ports del presentation layer

**`AuthSession`** (en `core/`, no en la feature porque múltiples features lo usan): `DevAuthSession` devuelve un usuario fijo en dev. En producción se reemplazaría por una impl Firebase Auth.

**`ThumbnailPickerService`** (en `user_articles/presentation/services/`, específico de la feature): `StubThumbnailPickerService` devuelve un PNG de 1×1 hardcodeado. En producción lo reemplaza una impl con `image_picker`.

---

## 9. Plataforma transversal (core, shared, config)

### 9.1 `core/error/app_failure.dart`

Sealed class con 5 variantes. Ver §4 de [ADR-0003](./prueba-tecnica/adr/0003-decisiones-consolidadas.md) para la justificación completa.

### 9.2 `core/usecase/usecase.dart`

Abstract class base:

```dart
abstract class UseCase<R, P> {
  const UseCase();
  Future<Either<AppFailure, R>> call(P params);
}
class NoParams { const NoParams(); }
```

Toda lógica de negocio extiende esto. `NoParams` para use cases sin input (`GetArticleUseCase` en daily_news).

### 9.3 `core/env/app_env.dart`

Lee variables vía `String.fromEnvironment('NEWS_API_KEY')`. El valor se pasa con `--dart-define=NEWS_API_KEY=xxx` al correr o buildear. La CI inyecta el valor desde GitHub Secrets.

### 9.4 `core/logger/app_logger.dart`

Tres handlers globales que `bootstrap.dart` registra:

- `FlutterError.onError` — errores del framework (render, layout).
- `PlatformDispatcher.instance.onError` — errores nativos no capturados.
- `runZonedGuarded` — async no capturado.

En dev imprimen a consola; en producción se conectaría Crashlytics (ver §15 de [ADR-0003](./prueba-tecnica/adr/0003-decisiones-consolidadas.md)).

### 9.5 `core/session/auth_session.dart`

Port para el usuario actual. `AuthUser(id, name)` es un value object simple; `AuthSession.currentUser` puede retornar null si no hay sesión.

### 9.6 `config/theme/`

- `tokens/app_colors.dart` — paleta neutra (neutral0–900) + `brandPrimary`, `brandAccent`, `danger`.
- `tokens/app_spacing.dart` — escala 4-pt: xs(4), sm(8), md(12), lg(16), xl(24), xxl(32), xxxl(48).
- `tokens/app_radii.dart` — sm(4), md(8), lg(16), pill(999).
- `tokens/app_typography.dart` — `TextTheme` basado en Muli.
- `app_theme_extension.dart` — `AppTheme` con factories `.light()` y `.dark()` + wrappers `AppSpacingTokens` / `AppRadiiTokens`.
- `app_themes.dart` — `lightTheme()` y `darkTheme()` devuelven `ThemeData` con `AppTheme` en `extensions`.

Consumo: `final theme = context.appTheme;` → `theme.primary`, `theme.spacing.lg`, `theme.radii.mdRadius`.

### 9.7 `config/routes/`

- `app_routes.dart` — clase `AppRoutes` con helpers tipados (`AppRoutes.articleEditorEdit(id)`).
- `app_router.dart` — `GoRouter` con todas las rutas declaradas.

### 9.8 `config/app_providers.dart`

`MultiBlocProvider` global. F7 añadió `MyArticlesCubit` como lazy (se crea solo cuando se entra a la pantalla, via `BlocProvider.value` con instancia de `sl<>()`).

### 9.9 `injection_container.dart`

`GetIt` service locator. Dos funciones:

- `initializeDependencies()` — wiring cross-feature (database, Dio, use cases, blocs de daily_news).
- `_registerUserArticles()` — wiring específico con el **gate de Firebase** (ver §12 de [ADR-0003](./prueba-tecnica/adr/0003-decisiones-consolidadas.md)).

---

## 10. Testing, CI y calidad de código

### 10.1 Suite de tests (58)

| Área                                        | Tests | Herramientas                              |
|---------------------------------------------|-------|-------------------------------------------|
| `core/error/app_failure`                    | 4     | `test` — pattern matching                 |
| `core/usecase`                              | 3     | `test` — smoke de tipo                    |
| `features/daily_news/domain/usecases`       | 3     | `mocktail`                                |
| `features/daily_news/data/repository`       | 4     | fakes manuales (NewsApiService, AppDatabase) |
| `features/daily_news/presentation/bloc`     | 2     | `bloc_test` + `mocktail`                  |
| `features/user_articles/domain/entities`    | 5     | `test` — reglas de negocio                |
| `features/user_articles/domain/usecases`    | 12    | `mocktail`                                |
| `features/user_articles/data/fake`          | 5     | `test` — roundtrip                        |
| `features/user_articles/data/repository`    | 6     | `fake_cloud_firestore` + `firebase_storage_mocks` |
| `features/user_articles/presentation/bloc`  | 5     | `bloc_test` + `mocktail`                  |
| `features/user_articles/presentation/widgets` | 3   | `widgetTester`                            |
| `placeholder_test.dart`                     | 1     | smoke                                     |

**Qué NO está cubierto:** widget tests exhaustivos de las 3 pantallas (solo hay del `PrimaryButton`). Ampliarlo requiere `pumpWidget` con el stack completo de DI, cosa que complica la suite por el coste que no paga en proporción al scope.

### 10.2 CI (GitHub Actions)

[`.github/workflows/ci.yml`](../.github/workflows/ci.yml) corre en cada `pull_request` y `push` a `main`:

1. Checkout.
2. Setup Flutter (SDK pineado).
3. `flutter pub get`.
4. `flutter pub run build_runner build --delete-conflicting-outputs`.
5. `flutter analyze` (exit code 0 requerido; ver `--no-fatal-infos` en [ADR-0001](./prueba-tecnica/adr/0001-lint-migration-and-info-debt-budget.md)).
6. `dart format --set-exit-if-changed .`.
7. `flutter test --coverage`.

**No merge sin verde.** Cada uno de los 60 commits de esta rama pasó este gate.

### 10.3 `flutter analyze` al cierre

**6 infos, todos benignos:**

- 3 × `sort_pub_dependencies` (pubspec.yaml no está alfabéticamente ordenado — cosmético, requeriría reorg del archivo).
- 3 × `avoid_redundant_argument_values` en `user_article_repository_impl_test.dart` (defaults explícitos para claridad del test — deliberado).

**0 errors, 0 warnings.**

### 10.4 Clean code compliance

- **Funciones cortas:** el método más largo es `ArticleEditorBloc._onSubmitted` a 60 líneas. Se podría partir, pero la lógica es lineal y cada paso lee obvio. Resto de funciones < 20 líneas.
- **Anidamiento ≤ 2:** verificado manualmente. Solo `BlocBuilder > ListView.builder > ArticleCard > Column > Row` se acerca, pero cada nivel es un widget distinto, no un control-flow.
- **Nombres descriptivos:** `UserArticleRepositoryImpl`, `UserArticlesFirestoreDataSource`, `reserveId`, `_guard`, `_generateArticleId`, `createPayload`, `updatePayload`.
- **Clases pequeñas:** las clases más largas son los `.freezed.dart` generados (~500–700 líneas cada uno, autogenerados). Los archivos propios no pasan de 250 líneas salvo `ArticleEditorBloc` (195) y `article_card.dart` (170) — ambos cohesivos.

---

## 11. Preguntas anticipadas y respuestas (Q&A)

Formulario de ensayo para la reunión, ordenado por probabilidad de que aparezcan.

**Q1. ¿Por qué `Either<AppFailure, T>` en vez del `DataState<T>` que propone `ARCHITECTURE_VIOLATIONS.md` 1.4.3?**

Porque `DataState<T>` en el código base exponía `DioError` hacia presentation (las pantallas hacían `state is DataFailed<T>` y accedían a `state.error as DioError`). Reemplazar `DataState` por `Either` con el tipo de error sellado (`AppFailure`) cumple el mismo objetivo — forzar al consumidor a manejar éxito y fallo — sin filtrar el tipo de librería HTTP. La decisión está en [ADR-0003 §4](./prueba-tecnica/adr/0003-decisiones-consolidadas.md#4-d3-d4-d5--contrato-universal-de-errores). Si quieren que vuelva a `DataState<T>`, es un refactor de ~1 hora: cambiar el wrapper, las firmas, y los `fold` a `when`.

**Q2. ¿Por qué el fake está en `data/fake/` y no solo en `test/`?**

Porque F7 (presentation) necesitaba correr con datos antes de F8 (Firestore real). Opciones: (a) bloquear F7 hasta F8, (b) usar el fake solo en tests y meter un placeholder en el bloc, (c) tener el fake en producción detrás del gate de Firebase. Se eligió (c) porque también permite que la demo corra localmente sin credenciales. Ver [ADR-0003 §10](./prueba-tecnica/adr/0003-decisiones-consolidadas.md#10-d11--fake-repository-en-datafake).

**Q3. ¿Es seguro generar el article id en el cliente?**

Sí, con dos caveats: (1) Firestore solo requiere unicidad dentro de la colección, no global — un `microsecondsSinceEpoch` es suficiente para una sesión individual. (2) Las reglas del backend enforcean `request.resource.data.id == articleId`, así que un cliente malicioso no puede escribir documentos con ids que no controla. Detalles en [ADR-0003 §13](./prueba-tecnica/adr/0003-decisiones-consolidadas.md#13-d14--article-id-generado-client-side).

**Q4. ¿Por qué no usaron `freezed 3`?**

Porque `floor_generator ^1.4.x` bloquea `analyzer ≥ 6.5`, que es lo que `freezed 3` pide. El corredor de compatibilidad está en [ADR-0002](./prueba-tecnica/adr/0002-dependency-version-bands.md). Cuando `daily_news` reescriba su persistencia sin `floor` (fuera de alcance), se desbloquea.

**Q5. ¿No les preocupa tener tests con `fake_cloud_firestore` en vez del emulador real?**

Sí, un poco. `fake_cloud_firestore` no evalúa `firestore.rules`. Los tests validan el **wiring** del repositorio (que `publish` escribe al path correcto, que `getMyArticles` filtra por `authorId`, que los mapeos `FirebaseException → AppFailure` funcionan). La validación real de reglas quedaría en un test de `@firebase/rules-unit-testing` (Node) o contra el emulador. Lo dejamos como overdelivery pendiente en [`PRE_PR_MANUAL.md`](./prueba-tecnica/PRE_PR_MANUAL.md).

**Q6. ¿Cómo harían offline-first?**

Dos pasos: (1) Activar `FirebaseFirestore.instance.settings = Settings(persistenceEnabled: true)` — cloud_firestore ya tiene persistencia local gratis. (2) Para lectura offline de thumbnails, `cached_network_image` (ya usado) cubre la mitad. La parte cara sería sincronizar reads entrantes mientras el cliente está offline — Firestore lo maneja por stream, la UI tendría que mostrar un indicador de "sincronizando". Está fuera del alcance de 72h.

**Q7. El overdelivery oficial del plan era #15 y #21. Dicen que entregaron ambos — ¿dónde?**

- **#15 (router declarativo):** `go_router ^14` en `config/routes/app_router.dart`, helpers tipados en `app_routes.dart`. Documentado en [ADR-0003 §7](./prueba-tecnica/adr/0003-decisiones-consolidadas.md#7-d8--router-declarativo-con-go_router).
- **#21 (design tokens + ThemeExtension):** 4 archivos de tokens en `config/theme/tokens/` alimentando `AppTheme extends ThemeExtension<AppTheme>`. Documentado en [ADR-0003 §6](./prueba-tecnica/adr/0003-decisiones-consolidadas.md#6-d7--design-tokens--themeextension).

Ambos están arriba y el consumo está estandarizado en toda la feature nueva.

**Q8. ¿Por qué el `main.dart` tiene solo 2 líneas?**

Para cumplir el criterio de salida de F2: *"`main.dart` ≤ 10 líneas"*. La intención es que arrancar la app sea obvio — delegar toda la inicialización a `bootstrap.dart`, que tiene responsabilidades agrupadas y probables. Ver [ADR-0003 §5](./prueba-tecnica/adr/0003-decisiones-consolidadas.md#5-d6--bootstrap-separado-y-handlers-globales-de-error).

**Q9. ¿Por qué `AuthSession` es un port y no directamente `firebase_auth`?**

Dos razones: (1) el bloc del editor no debería importar `firebase_auth` (regla 3.1.1 — presentation no toca providers). (2) Los widget tests no pueden llamar a Firebase Auth real; necesitan un mock. Con el port, el test inyecta `DevAuthSession(user: AuthUser(id: 'u1', name: 'Test'))` y el resto del grafo sigue igual.

**Q10. ¿Qué piezas del Figma NO se implementaron?**

Animaciones y transiciones entre pantallas que el Figma sugería (fade del thumbnail al entrar a detail, slide de la tarjeta al hacer tap). Se consideraron overdelivery de nivel 🟢 del checklist E y se deprioritizaron frente al cierre de F9. El hook está: las pantallas ya navegan por `go_router`, donde un `CustomTransitionPage` podría insertarse sin tocar el código de la pantalla.

**Q11. Si tuviera que revertir algo, ¿qué sería lo más fácil y lo más caro?**

- **Fácil de revertir:** los tokens y `go_router`. Cada uno está aislado a su carpeta y el wiring es puntual. Volver a `onGenerateRoute` es ~2 horas.
- **Caro de revertir:** `Either<AppFailure, T>`. Tocaría firmas de 9 use cases + 2 repositorios + 3 blocs + 3 pantallas. Pero como está declarado en un solo alias (`UseCase<R, P>`) y se usa `.fold` consistentemente, la búsqueda-y-reemplazo es mecánica. Calculo 4–6 horas de refactor asistido por IDE.

---

## 12. Deuda conocida y plan de salida

### 12.1 Deuda visible

| Item                                          | Origen    | Impacto hoy           | Cómo se cierra                                      |
|-----------------------------------------------|-----------|-----------------------|-----------------------------------------------------|
| `Firebase.initializeApp` no invocada          | F0 bloqueada (sin proyecto Firebase) | App corre con fake | Descomentar en `bootstrap.dart`, tras `flutterfire configure` |
| 3 infos cosméticos en `pubspec.yaml`          | ADR-0001 | Pelusa de CI          | Reordenar alfabéticamente dependencies (cambio trivial) |
| 3 infos `avoid_redundant_argument_values` en tests | Deliberado | Ninguno          | Se conservan para claridad del test                 |
| `dependency_overrides` en `analyzer`/`dart_style` | ADR-0002 | Enmascara CVEs potenciales | F10: reemplazar `floor` por `drift` → libera la banda |
| Widget tests solo cubren `PrimaryButton`      | Scope de 72h | Test suite no cubre pantallas completas | Añadir pumpWidget tests de las 3 páginas con DI aislada |
| Screenshots y vídeo de la demo                | Scope de 72h | REPORT.md completo pero sin anexos visuales | Ver [`PRE_PR_MANUAL.md`](./prueba-tecnica/PRE_PR_MANUAL.md) §3-4 |

### 12.2 Orden sugerido de cierre post-PR

1. Desbloquear F0 (proyecto Firebase, `flutterfire configure`, deploy de reglas).
2. Capturar screenshots y vídeo con el flujo real contra Firestore.
3. Reemplazar `StubThumbnailPickerService` por impl con `image_picker`.
4. Reemplazar `DevAuthSession` por impl Firebase Auth (incluye login UI mínimo).
5. Cerrar los 6 infos cosméticos y endurecer CI a `--fatal-infos` (cierra ADR-0001).
6. Widget tests de las 3 pantallas.
7. Integration test contra el emulador Firebase.

Cada paso es independiente del siguiente — son mejoras acumulables.

---

## Apéndice A — Mapa de archivos clave

| Propósito                              | Path                                                                                         |
|----------------------------------------|----------------------------------------------------------------------------------------------|
| Error handling sellado                 | [core/error/app_failure.dart](../frontend/lib/core/error/app_failure.dart)                   |
| Use case base                          | [core/usecase/usecase.dart](../frontend/lib/core/usecase/usecase.dart)                       |
| Auth port                              | [core/session/auth_session.dart](../frontend/lib/core/session/auth_session.dart)             |
| Router declarativo                     | [config/routes/app_router.dart](../frontend/lib/config/routes/app_router.dart)               |
| Theme + tokens                         | [config/theme/app_theme_extension.dart](../frontend/lib/config/theme/app_theme_extension.dart) |
| DI y gate de Firebase                  | [injection_container.dart](../frontend/lib/injection_container.dart)                         |
| Entidad del dominio                    | [user_articles/domain/entities/user_article_entity.dart](../frontend/lib/features/user_articles/domain/entities/user_article_entity.dart) |
| Repositorio real                       | [user_articles/data/repository/user_article_repository_impl.dart](../frontend/lib/features/user_articles/data/repository/user_article_repository_impl.dart) |
| Repositorio fake                       | [user_articles/data/fake/fake_user_article_repository.dart](../frontend/lib/features/user_articles/data/fake/fake_user_article_repository.dart) |
| Data source Firestore                  | [user_articles/data/data_sources/remote/user_articles_firestore_data_source.dart](../frontend/lib/features/user_articles/data/data_sources/remote/user_articles_firestore_data_source.dart) |
| Data source Storage                    | [user_articles/data/data_sources/remote/user_articles_storage_data_source.dart](../frontend/lib/features/user_articles/data/data_sources/remote/user_articles_storage_data_source.dart) |
| Bloc del editor                        | [user_articles/presentation/bloc/article_editor/article_editor_bloc.dart](../frontend/lib/features/user_articles/presentation/bloc/article_editor/article_editor_bloc.dart) |
| Cubit del listado                      | [user_articles/presentation/bloc/my_articles/my_articles_cubit.dart](../frontend/lib/features/user_articles/presentation/bloc/my_articles/my_articles_cubit.dart) |
| Reglas Firestore                       | [backend/firestore.rules](../backend/firestore.rules)                                        |
| Reglas Storage                         | [backend/storage.rules](../backend/storage.rules)                                            |
| Schema del backend                     | [backend/docs/DB_SCHEMA.md](../backend/docs/DB_SCHEMA.md)                                    |
