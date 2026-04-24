# Checklist de Validación

> Lista dividida por áreas para verificar **el estado real** de cada entregable antes de presentar la prueba. Cada sección es independiente: se puede usar como *Definition of Done* por fase.

Convención:
- `[ ]` pendiente · `[x]` hecho · `[~]` parcial.
- 🔴 = obligatorio para aprobar · 🟡 = fuertemente recomendado · 🟢 = overdelivery.

---

## A. Entorno y configuración

- [x] 🔴 `flutter doctor` sin errores bloqueantes. *(Flutter 3.38.5 / Dart 3.10.4; única observación no bloqueante: Android licenses pendientes de aceptar.)*
- [~] 🔴 Firebase CLI instalada y autenticada (`firebase login`). *(CLI 15.1.0 instalada; credenciales de `dev@pik.lat` expiradas → requiere `firebase login --reauth` manual.)*
- [ ] 🔴 `backend/.firebaserc` apunta a un `projectId` real. *(Pendiente: sigue con `// TODO: ADD PROJECT ID`.)*
- [ ] 🔴 Proyecto Firebase tiene **Firestore**, **Storage** y **Emulator Suite** habilitados. *(Acción manual en la Consola.)*
- [ ] 🔴 `firebase emulators:start` levanta Firestore y Storage localmente.
- [ ] 🔴 `frontend/firebase_options.dart` generado con `flutterfire configure`. *(CLI `flutterfire_cli 1.3.1` instalada; corre tras el reauth.)*
- [ ] 🔴 `Firebase.initializeApp()` invocado en `main()`. *(Se cablea en F2.)*
- [ ] 🟡 `.gitignore` excluye `google-services.json`, `GoogleService-Info.plist` y `firebase_options.dart` si contienen secretos sensibles (o se documenta que son públicos).

---

## B. Backend — Schema

- [x] 🔴 Archivo [backend/docs/DB_SCHEMA.md](../../backend/docs/DB_SCHEMA.md) creado.
- [x] 🔴 Define la colección `articles` con todos sus campos y tipos.
- [x] 🔴 Define cómo se representa el autor (campo `authorId` propagado en el documento + `authorName` denormalizado para el feed).
- [x] 🔴 Campo `thumbnailURL` referencia explícitamente `media/articles/{authorId}/{articleId}/...` en Cloud Storage.
- [x] 🔴 Documenta timestamps (`publishedAt`, `updatedAt`) y que usan `serverTimestamp` (inmutable el primero, se bumpea el segundo).
- [x] 🟡 Describe subcolecciones futuras (`comments`, `likes`) aunque no se implementen.
- [x] 🟡 Incluye un **ejemplo de documento JSON** real.
- [x] 🟢 Diagrama mermaid del schema.

---

## C. Backend — Reglas (Firestore + Storage)

- [x] 🔴 `firestore.rules` deniega por defecto (`match /{document=**} { allow read, write: if false; }`).
- [x] 🔴 Permite lectura pública de `articles` (`allow read: if true;`).
- [x] 🔴 Solo el autor puede crear/editar/borrar sus propios artículos (`request.auth.uid == resource.data.authorId` + `authorId` inmutable en update).
- [x] 🔴 `isValidArticle()` valida tipos, longitudes (title 5–120, description ≤280, content 50–20000, thumbnailURL https) y enum `status`.
- [x] 🔴 `storage.rules` restringe writes al path `media/articles/{authorId}/{articleId}/{file}` al autor autenticado.
- [x] 🔴 Storage valida `contentType` (`image/*`) y tamaño (`< 5 * 1024 * 1024`).
- [ ] 🔴 Reglas desplegadas: `firebase deploy --only firestore:rules,storage:rules`. *(Pendiente F0: requiere `firebase login --reauth`.)*
- [ ] 🟡 Probadas con el simulador web de Firebase (al menos caso permitido + caso denegado). *(Pendiente F9.)*
- [ ] 🟢 Tests automatizados con `@firebase/rules-unit-testing`.

---

## D. Frontend — Domain layer

- [x] 🔴 Existe [frontend/lib/features/user_articles/domain/](../../frontend/lib/features/user_articles/domain/).
- [x] 🔴 Entidad `UserArticleEntity` modelada con `@freezed` (reemplaza `Equatable` con `==`/`hashCode` autogenerados).
- [x] 🔴 Interface `UserArticleRepository` declarada en `domain/repository/user_article_repository.dart`.
- [x] 🔴 Use cases con método `call(params)`:
  - [x] `GetMyArticlesUseCase`
  - [x] `PublishArticleUseCase`
  - [x] `UpdateArticleUseCase`
  - [x] `DeleteArticleUseCase`
  - [x] `UploadThumbnailUseCase`
- [x] 🔴 `domain/` **no importa** `flutter`, `firebase_*`, `dio`, `floor` — verificado vía grep (0 matches).
- [x] 🔴 Cada use case tiene una **sola** responsabilidad (validación + delegación).
- [x] 🟡 `canPublish`/`isPublished` testeados + validaciones de cada use case con mocktail (12 tests de dominio + 5 del fake).

---

## E. Frontend — Presentation layer

- [x] 🔴 BLoCs/Cubits creados por feature en `presentation/bloc/`. *(`MyArticlesCubit`, `ArticleEditorBloc`.)*
- [x] 🔴 Los blocs son lo **único** que importa `use_cases`.
- [x] 🔴 Los widgets/screens **no** acceden a repositorios ni data sources.
- [x] 🔴 Todas las pantallas del Figma relevantes están implementadas:
  - [x] Lista de mis artículos (`MyArticlesPage`).
  - [x] Crear/editar artículo (`ArticleEditorPage`).
  - [x] Detalle/preview (`UserArticleDetailPage`).
- [x] 🔴 Cada pantalla tiene estados de **carga**, **éxito**, **vacío** y **error**.
- [x] 🔴 Blocs registrados en `injection_container.dart` con `registerFactory`.
- [x] 🟡 Navegación centralizada en `config/routes/app_router.dart` + `AppRoutes` helpers.
- [x] 🟡 Componentes reutilizables en `presentation/widgets/` (`ArticleCard`, `ThumbnailPickerTile`, `PrimaryButton`).
- [ ] 🟢 Animaciones y transiciones fieles al Figma.
- [x] 🟢 Modo oscuro funcional vía `AppTheme.dark()`.

---

## F. Frontend — Data layer

- [x] 🔴 `data_sources/` contiene solo conexión externa; **lanza excepciones** (`UserArticlesFirestoreDataSource`, `UserArticlesStorageDataSource`).
- [x] 🔴 `models/` exponen `fromFirestore` + `toEntity()` (`UserArticleModel`).
- [x] 🔴 `repository/*_impl.dart` implementa la interfaz del dominio y retorna `Either<AppFailure, T>`.
- [x] 🔴 Solo `repository/*_impl.dart` importa providers (Firestore/Storage).
- [~] 🔴 Flujo probado contra **emulador Firebase**. *(Probado con `fake_cloud_firestore` + `firebase_storage_mocks`; pendiente verificar manualmente con emulador una vez se desbloquee F0.)*
- [ ] 🔴 Flujo probado contra **proyecto Firebase real**. *(Pendiente: requiere `flutterfire configure` + `Firebase.initializeApp`.)*
- [x] 🟡 Cache local (Firestore persistence) delegada al SDK; retries automáticos vía `cloud_firestore`.
- [ ] 🟢 Sincronización offline explícita (Firestore persistence + Floor mirror).

---

## G. Calidad de código (Clean Code)

- [~] 🔴 `flutter analyze` sin warnings críticos. *(0 errores / 0 warnings. 27 infos restantes presupuestados como deuda en [ADR-0001](../adr/0001-lint-migration-and-info-debt-budget.md); F9 debe cerrar a 0.)*
- [x] 🔴 `dart format .` aplicado. *(Adelantado desde F9/B9.1 para destrabar el CI en F2–F8.)*
- [ ] 🔴 Funciones cortas (máx. ~20 líneas) y con una responsabilidad.
- [ ] 🔴 Nombres intention-revealing; sin abreviaturas oscuras.
- [ ] 🔴 Anidamiento máximo de control-flow ≤ 2.
- [ ] 🟡 Archivos < 300 líneas (salvo generados).
- [ ] 🟡 Sin `print()` residuales; usar logger o comentar por qué.
- [ ] 🟢 TDD real para la feature nueva (al menos use_cases + repository_impl).

### G.1 Tooling base (F1)

- [x] 🔴 SDK bumpeado a Dart 3.3 / Flutter 3.19 (instalado: Dart 3.10.4 / Flutter 3.38.5).
- [x] 🔴 Lints: `very_good_analysis ^6.0.0` con `strict-casts`, `strict-inference`, `strict-raw-types`.
- [x] 🔴 Modelado: `freezed ^2.4.7` + `freezed_annotation` + `json_serializable ^6.8` + `json_annotation`.
- [x] 🔴 Error handling: `dartz ^0.10.1`.
- [x] 🔴 Router: `go_router ^14.2.7`.
- [x] 🔴 Test stack: `mocktail`, `bloc_test`, `fake_cloud_firestore`, `firebase_auth_mocks`, `firebase_storage_mocks`.
- [x] 🔴 Auth: `firebase_auth ^4.20.0`.
- [x] 🔴 `build_runner` re-genera los `.g.dart` sin errores.
- [x] 🔴 Test directory (`frontend/test/`) creado con smoke test (`placeholder_test.dart`).
- [x] 🔴 Pipeline CI GitHub Actions: analyze + format + test con cobertura.
- [x] 🟡 ADRs registradas para decisiones de F1: [ADR-0001](../adr/0001-lint-migration-and-info-debt-budget.md), [ADR-0002](../adr/0002-dependency-version-bands.md).

### G.2 Fundamentos core/shared + bootstrap (F2)

- [x] 🔴 Carpeta `frontend/lib/shared/` creada con el invariante documentado.
- [x] 🔴 `AppFailure` freezed sellado: `network`, `cache`, `validation`, `auth`, `unknown`.
- [x] 🔴 `DataState` eliminado; `grep -R "DioError\|DataState" frontend/lib` vacío.
- [x] 🔴 Repositorios de `daily_news` devuelven `Either<AppFailure, T>` (`Unit` para operaciones void).
- [x] 🔴 Base `UseCase<R, P>` con `call(P params)` retornando `Future<Either<AppFailure, R>>` + `NoParams`.
- [x] 🔴 Cuatro use cases de `daily_news` migrados a la nueva base.
- [x] 🔴 `AppEnv` lee `NEWS_API_KEY` vía `--dart-define` (pass-through desde `constants.dart`).
- [x] 🔴 `main.dart` ≤ 10 líneas; lógica extraída a `bootstrap.dart` y `app.dart`.
- [x] 🔴 `AppLogger` + handlers globales (`FlutterError.onError`, `PlatformDispatcher.onError`, `runZonedGuarded`).
- [x] 🔴 Tests cubren `AppFailure` (4) y `UseCase` base (3) → suite 8/8 verde.
- [ ] 🟡 `Firebase.initializeApp` cableado en `bootstrap.dart` *(bloqueado por F0: requiere `flutterfire configure`).*

### G.3b Refactor `daily_news` al nuevo estándar (F4)

- [x] 🟡 `ArticleEntity` reescrita con `@freezed` y regla de negocio `isValidForDisplay`.
- [x] 🟡 `ArticleModel` ya no extiende la entidad — expone `toEntity()`/`fromEntity()` y adopta `@JsonSerializable()` + `@JsonKey(defaultValue: '')` (elimina los `?? ''` manuales).
- [x] 🟡 Repositorio devuelve `Either<AppFailure, List<ArticleEntity>>` mapeando `List<ArticleModel>` → entidades; try/catch centralizado en `_guardNetwork`/`_guardCache`.
- [x] 🟡 Estados `RemoteArticlesState` y `LocalArticlesState` migrados a uniones `@freezed` (`loading`/`done`/`error`).
- [x] 🟡 `MultiBlocProvider` global extraído a `lib/config/app_providers.dart` (listo para registrar los blocs de F7).
- [x] 🧪 Tests añadidos: `GetArticleUseCase`, `ArticleRepositoryImpl` (4 casos), `RemoteArticlesBloc` (2 casos).
- [x] 🔴 `flutter analyze`: 18 issues (todos preexistentes del presupuesto de [ADR-0001](../adr/0001-lint-migration-and-info-debt-budget.md); los 7 errors de `data/models/article.dart` de F3 están cerrados con `json_serializable`).

### G.4 Domain `user_articles` (F6)

- [x] 🔴 `UserArticleEntity` freezed con enum `UserArticleStatus` + reglas `canPublish`/`isPublished` alineadas con `firestore.rules#isValidArticle`.
- [x] 🔴 Params freezed (`PublishArticleParams`, `UpdateArticleParams`, `DeleteArticleParams`, `UploadThumbnailParams`).
- [x] 🔴 Interface `UserArticleRepository` retorna `Either<AppFailure, T>` en todas las operaciones.
- [x] 🔴 Use cases `GetMyArticles`, `PublishArticle`, `UpdateArticle`, `DeleteArticle`, `UploadThumbnail` con validación previa + delegación.
- [x] 🟢 `FakeUserArticleRepository` in-memory en `data/fake/` para destrabar F7 antes del Firestore real de F8.
- [x] 🧪 Suite **42/42 verde** (entidad + 5 use cases + fake roundtrip).
- [x] 🔴 `grep` de imports prohibidos en `features/user_articles/domain/` → vacío.

### G.5 Presentation `user_articles` (F7)

- [x] 🔴 `MyArticlesCubit` con estados freezed (initial / loading / success / failure) y delete optimista con rollback.
- [x] 🔴 `ArticleEditorBloc` con eventos freezed (title/description/content/tags/thumbnail/submitted) y decisión automática publish vs. update según `editingId`.
- [x] 🔴 Pantallas `MyArticlesPage`, `ArticleEditorPage`, `UserArticleDetailPage` con estados loading / empty / error y pull-to-refresh.
- [x] 🔴 Widgets reutilizables `ArticleCard`, `ThumbnailPickerTile`, `PrimaryButton` consumiendo `context.appTheme`.
- [x] 🔴 Rutas nested en `app_router.dart`: `/me/articles`, `/me/articles/new`, `/me/articles/:id`, `/me/articles/:id/edit`.
- [x] 🔴 Blocs / cubits registrados en `injection_container.dart` (`registerFactory` para cubits, singletons para use cases).
- [x] 🔴 `AuthSession` port + `DevAuthSession` stub para desacoplar la UI de Firebase Auth.
- [x] 🔴 `ThumbnailPickerService` port + `StubThumbnailPickerService` para desacoplar la UI de `image_picker`.
- [x] 🧪 Suite **52/52 verde** (añadidos `MyArticlesCubit`, `ArticleEditorBloc`, widget test de `PrimaryButton`).

### G.6 Data `user_articles` (F8)

- [x] 🔴 `UserArticlesFirestoreDataSource`: CRUD + `reserveId()` usando `FieldValue.serverTimestamp()` para `publishedAt`/`updatedAt` (satisface `request.time` en las reglas).
- [x] 🔴 `UserArticlesStorageDataSource`: upload a `media/articles/{authorId}/{articleId}/{file}` con content-type, retorna `getDownloadURL()`.
- [x] 🔴 `UserArticleModel` (plain class) con `fromFirestore`, `toEntity`, `createPayload`, `updatePayload`; mapeo de `Timestamp` y fallback a `DateTime.now()` para server-stamped writes.
- [x] 🔴 `UserArticleRepositoryImpl` retorna `Either<AppFailure, T>` con `_guard` que mapea `FirebaseException.code` → `AuthFailure|NetworkFailure|ValidationFailure|UnknownFailure`.
- [x] 🔴 DI gate `Firebase.apps.isNotEmpty`: real impl cuando Firebase está cableado, fake cuando no.
- [x] 🔴 Article id generado client-side en el bloc y propagado a upload + publish (necesario por `data.id == articleId` en `firestore.rules`).
- [x] 🧪 Suite **58/58 verde** con `fake_cloud_firestore` + `firebase_storage_mocks`: publish/list/update/delete, upload al path whitelisted, y `FirebaseException(permission-denied)` mapeada a `AuthFailure`.

### G.7 QA y entrega (F9)

- [x] 🔴 `dart format` aplicado al codebase.
- [x] 🔴 `flutter analyze`: 0 errors, 0 warnings, 6 infos (todas presupuestadas en [ADR-0001](../adr/0001-lint-migration-and-info-debt-budget.md) o ruido cosmético).
- [x] 🔴 `flutter test`: 58/58 verde.
- [x] 🔴 `frontend/README.md` reescrito con instrucciones de ejecución, `--dart-define`, layout del proyecto y toggling Firebase.
- [x] 🔴 `docs/REPORT.md` con las 7 secciones.
- [x] 🔴 `CHANGELOG.md` entrada 1.0.0 con added/changed/removed/ADRs/métricas.
- [x] 🟡 Accesibilidad: `Semantics` header en títulos, `Semantics` label en cada form field, tooltips en edit/delete icon buttons.
- [ ] 🔴 Screenshots + vídeo demo. *(Pendiente capturar; todo lo demás está listo para entregar.)*

### G.3 Design system + Router declarativo (F3)

- [x] 🟢 Tokens de diseño en `lib/config/theme/tokens/`: `app_colors.dart`, `app_spacing.dart` (escala 4-pt), `app_radii.dart`, `app_typography.dart`.
- [x] 🟢 `AppTheme extends ThemeExtension<AppTheme>` con presets `light()`/`dark()` y wrappers `AppSpacingTokens`/`AppRadiiTokens`.
- [x] 🟢 Helper `context.appTheme` en `app_theme_extension.dart` para consumir tokens semánticos desde widgets.
- [x] 🟢 `app_themes.dart` reescrito: `lightTheme()` y `darkTheme()` derivados de tokens vía `ColorScheme.fromSeed` + `AppTypography.buildTextTheme`.
- [x] 🟢 `go_router ^14.2.7` cableado en `lib/config/routes/app_router.dart` con rutas `home`, `articleDetail` (`/article/:id`) y `saved`.
- [x] 🟢 Helpers tipados `AppRoutes.home()`, `AppRoutes.saved()`, `AppRoutes.articleDetail(id)` y `AppRoutes.articleDetailFor(article)` en `app_routes.dart`.
- [x] 🟢 `app.dart` migrado a `MaterialApp.router(routerConfig: appRouter, theme: lightTheme(), darkTheme: darkTheme())`.
- [x] 🟢 `daily_news` (home, saved, detail) navega por `context.push` / `context.pop` — `Navigator.pushNamed` eliminado.
- [x] 🟢 `lib/config/routes/routes.dart` legacy borrado; `MaterialApp.onGenerateRoute` ya no existe.
- [x] 🔴 `flutter analyze`: 0 issues nuevos (los 25 restantes son preexistentes presupuestados — 7 errors en `data/models/article.dart` se cierran en F4 con `freezed`/`json_serializable`).
- [x] 🔴 Suite 8/8 verde tras la migración del router.

---

## H. Cumplimiento arquitectónico (contra `ARCHITECTURE_VIOLATIONS.md`)

Auditoría rápida por capa; marcar solo si se verificó manualmente.

- [ ] 🔴 Ninguna violación 1.x (data).
- [ ] 🔴 Ninguna violación 2.x (domain).
- [ ] 🔴 Ninguna violación 3.x (presentation).
- [ ] 🟡 `grep` de sanidad:
  - `grep -R "cloud_firestore\|firebase_storage\|floor\|dio" frontend/lib/features/*/domain/` → vacío.
  - `grep -R "cloud_firestore\|firebase_storage\|floor\|dio" frontend/lib/features/*/presentation/` → vacío.
  - `grep -R "features/.*/data/" frontend/lib/features/*/presentation/` → vacío.

---

## I. Reporte y entrega

- [x] 🔴 `docs/REPORT.md` contiene las 7 secciones de `REPORT_INSTRUCTIONS.md`.
- [x] 🟢 `docs/SOLUCION.md` — narrativa técnica detallada para la reunión de revisión (flujo end-to-end, Q&A anticipada, mapa de archivos).
- [x] 🟢 `docs/adr/0003-decisiones-consolidadas.md` — fuente de verdad panorámica con las 14 decisiones técnicas del ciclo F0–F9.
- [x] 🟢 `docs/PRE_PR_MANUAL.md` — checklist operativo para el humano antes del PR (desbloqueo F0, screenshots, vídeo, merge).
- [ ] 🔴 Screenshots de cada pantalla clave. *(Checklist en [PRE_PR_MANUAL.md §3](../PRE_PR_MANUAL.md).)*
- [ ] 🔴 Vídeo demo del flujo completo (≤ 2 min). *(Checklist en [PRE_PR_MANUAL.md §4](../PRE_PR_MANUAL.md).)*
- [x] 🔴 Sección *Overdelivery* detalla lo extra (go_router, design tokens, CI, strict lints, ADRs, AuthSession fallback, `_guard` mapper).
- [x] 🔴 `frontend/README.md` actualizado con instrucciones para correr el proyecto y `--dart-define=NEWS_API_KEY`.
- [x] 🟡 Commits con mensajes claros en formato Conventional Commits.
- [x] 🟡 Rama `chore/modernization` lista para PR a `main`.
- [ ] 🟢 Tag de versión `v1.0.0` al terminar. *(Pendiente: ver [PRE_PR_MANUAL.md §7](../PRE_PR_MANUAL.md).)*

---

## J. Seguridad básica

- [ ] 🔴 Claves de API (p. ej. `newsAPIKey` en `constants.dart`) no quedan hardcodeadas en el repo si son sensibles — si es una API key pública de NewsAPI de prueba, documentarlo.
- [ ] 🔴 Firestore Rules no permiten acceso anónimo a escritura.
- [ ] 🔴 Storage Rules acotan tamaño y `contentType`.
- [ ] 🟡 Autenticación requerida para escribir artículos.
- [ ] 🟢 Validación cliente **y** servidor (doble check del schema).

---

## K. Verificación final antes de entregar

1. [ ] 🔴 `git status` limpio en la rama principal.
2. [ ] 🔴 El repo clonado desde cero compila y corre con los pasos del README.
3. [ ] 🔴 Un revisor externo (mentor, compañero) puede crear y ver un artículo sin intervención.
4. [ ] 🔴 El reporte responde: *¿qué hice, cómo lo hice, qué aprendí, qué haría mejor?*.
5. [ ] 🟡 Se entrega antes del deadline de 72 h.
