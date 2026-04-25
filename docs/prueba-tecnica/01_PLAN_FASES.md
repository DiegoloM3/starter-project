# Plan de Ejecución Integrado — Prueba Técnica Symmetry

> **Versión integrada** del plan: incorpora los requisitos oficiales de la prueba **más** el conjunto de mejoras arquitectónicas priorizadas en [03_ANALISIS_ARQUITECTURA.md](./03_ANALISIS_ARQUITECTURA.md):
> - ✅ **Todas** las 🔴 Imprescindibles (5 puntos).
> - ✅ **Todas** las 🟡 Fuertes mejoras de calidad (9 puntos).
> - ✅ **Overdelivery** puntos **#15 (router declarativo)** y **#21 (design tokens + `ThemeExtension`)**.
>
> Pensado para ejecutarse en ~72 h. Lee cada fase con: **objetivo → tareas → criterio de salida → mejoras del análisis cubiertas**.

**Leyenda:** 🔴 Bloqueante · 🟡 Calidad · 🟢 Overdelivery · 🧪 Incluye tests.

---

## Vista general — flujo de fases

```
F0 Setup ──► F1 Modernización ──► F2 Fundamentos core ──► F3 Design system + Router
                                                                │
                                                                ▼
F4 Refactor daily_news ◄──────── F5 Backend (schema + rules) ◄──┤
        │                                                        │
        ▼                                                        │
F6 Domain user_articles ──► F7 Presentation user_articles ──► F8 Data user_articles
                                                                │
                                                                ▼
                                                   F9 QA final + Reporte + Entrega
```

F0–F3 son **habilitadores** (plataforma). F4 asegura que lo existente cumpla con los nuevos estándares antes de escalar. F5–F8 construyen la nueva feature. F9 cierra y entrega.

---

## Fase 0 — Setup del entorno (≈ 1–2 h) 🔴

**Objetivo:** dejar todas las herramientas instaladas y el proyecto compilando tal cual viene.

**Tareas**
- [ ] `flutter doctor` → resolver warnings críticos.
- [ ] Instalar: `npm i -g firebase-tools`, `dart pub global activate flutterfire_cli`.
- [ ] Crear proyecto en Firebase Console: habilitar **Firestore**, **Cloud Storage**, **Authentication** (email) y **Emulator Suite**.
- [ ] `firebase login` → editar [backend/.firebaserc](../../backend/.firebaserc) con el `projectId` real.
- [ ] `firebase init` (Firestore, Storage, Emulators). Verificar que se levantan: `firebase emulators:start`.
- [ ] `cd frontend && flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs`.
- [ ] Arrancar la app actual para confirmar que compila.

**Criterio de salida:** la app preexistente corre en un emulador Android/iOS/Chrome y los emuladores Firebase arrancan localmente.

---

## Fase 1 — Modernización técnica (≈ 4 h) 🔴🟡 🧪

**Objetivo:** subir la plataforma a estándares modernos **antes** de escribir nuevo código.

Cubre las mejoras del análisis: **R4** (Dart 3 / null-safety estricta), **D8** (lints), **R7** (CI), dependencias base para **R5** (freezed), **R3** (AppFailure), **R6** (tests) y **R2** (DataState uniforme).

**Tareas**
- [ ] **Dart 3 + null-safety estricta** en [frontend/pubspec.yaml](../../frontend/pubspec.yaml):
  ```yaml
  environment:
    sdk: ">=3.3.0 <4.0.0"
    flutter: ">=3.19.0"
  ```
- [ ] Reemplazar `flutter_lints: ^1.0.0` por `very_good_analysis: ^6.0.0` (o `flutter_lints: ^4`). Actualizar `analysis_options.yaml` para incluir:
  ```yaml
  analyzer:
    language:
      strict-casts: true
      strict-inference: true
      strict-raw-types: true
  ```
- [ ] Añadir dependencias (devdep en su mayoría):
  - `freezed_annotation` + `freezed` + `json_annotation` + `json_serializable` (modelos/estados inmutables).
  - `dartz` *(o `fpdart`)* para `Either<Failure, T>`.
  - `go_router: ^14` (router declarativo, overdelivery #15).
  - `flutter_dotenv` *o* uso de `--dart-define` (no hay que añadir paquete) para la key de NewsAPI.
  - `mocktail`, `bloc_test`, `firebase_auth_mocks`, `fake_cloud_firestore`, `firebase_storage_mocks` (tests).
  - `firebase_auth` (requerido para validar `authorId` en reglas).
- [ ] Ejecutar `flutter pub get` y arreglar compatibilidades (probable: bump de `floor`, `retrofit`, etc.).
- [ ] Correr `flutter pub run build_runner build --delete-conflicting-outputs` para regenerar archivos `.g.dart`.
- [ ] **CI GitHub Actions** en `.github/workflows/ci.yml`:
  - Job: `flutter analyze`, `dart format --set-exit-if-changed .`, `flutter test --coverage`.
  - Disparar en `pull_request` y `push` a `main`.
- [ ] Crear carpeta `frontend/test/` vacía con un smoke test `placeholder_test.dart` que compile.

**Criterio de salida:**
- `flutter analyze` limpio.
- `flutter test` verde (aunque sea solo el smoke).
- El pipeline de CI pasa en una PR de prueba.

---

## Fase 2 — Fundamentos `core` / `shared` y bootstrap (≈ 4 h) 🔴🟡 🧪

**Objetivo:** dejar las piezas transversales listas: fallos tipados, `Either`, inicialización limpia, error handlers, env vars y carpeta `shared/`.

Cubre: **R1** (Firebase init + bootstrap), **R2** (DataState uniforme → `Either`), **R3** (AppFailure), **D15** (crear `shared/`), **D12** (handlers globales), **D14** (desacoplar `DioError`), **#14** del análisis (env vars).

**Tareas**

### 2.1 Reestructurar carpetas transversales
- [ ] Crear `frontend/lib/shared/` según el arquetipo oficial (ver [APP_ARCHITECTURE.md](../APP_ARCHITECTURE.md#folder-structure-of-the-app)).
- [ ] Mantener `core/` **solo** para utilidades sin capas (constants, logger, base `UseCase`, `Failure`).
- [ ] Decidir ubicación final:
  - `core/error/app_failure.dart` (jerarquía de fallos).
  - `core/usecase/usecase.dart` (base genérica).
  - `core/env/app_env.dart` (lectura de `--dart-define`).
  - `core/logger/app_logger.dart`.

### 2.2 Jerarquía de fallos (`AppFailure`)
- [ ] Con `freezed`:
  ```dart
  @freezed
  sealed class AppFailure with _$AppFailure {
    const factory AppFailure.network({String? message, int? statusCode}) = NetworkFailure;
    const factory AppFailure.cache({String? message}) = CacheFailure;
    const factory AppFailure.validation({required String field, required String reason}) = ValidationFailure;
    const factory AppFailure.auth({String? message}) = AuthFailure;
    const factory AppFailure.unknown({Object? cause, StackTrace? stackTrace}) = UnknownFailure;
  }
  ```
- [ ] Reemplazar el uso directo de `DioError` en `core/resources/data_state.dart`:
  - Opción A *(recomendada)*: eliminar `DataState` y retornar `Either<AppFailure, T>` en repositorios.
  - Opción B: conservar `DataState` pero tipado como `DataState<T, AppFailure>` sin `DioError`.

### 2.3 Base `UseCase`
- [ ] `abstract class UseCase<R, P> { Future<Either<AppFailure, R>> call(P params); }`.
- [ ] `class NoParams { const NoParams(); }`.

### 2.4 Bootstrap separado
- [ ] Ejecutar `flutterfire configure` → genera `lib/firebase_options.dart`.
- [ ] Dividir [main.dart](../../frontend/lib/main.dart) en:
  - `main.dart`: solo punto de entrada.
  - `bootstrap.dart`: ejecuta `WidgetsFlutterBinding`, `Firebase.initializeApp`, `runZonedGuarded`, registra handlers globales y llama a `initializeDependencies()`.
  - `app.dart`: widget `MyApp` con `MultiBlocProvider` y `MaterialApp.router`.
  ```dart
  Future<void> bootstrap() async {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (d) => AppLogger.reportFlutterError(d);
    PlatformDispatcher.instance.onError = (e, s) { AppLogger.report(e, s); return true; };
    await dotenv.load(); // o nada si se usa --dart-define
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await initializeDependencies();
    runApp(const MyApp());
  }
  ```

### 2.5 Variables de entorno
- [ ] Mover `newsAPIKey` fuera de [core/constants/constants.dart](../../frontend/lib/core/constants/constants.dart):
  ```dart
  // core/env/app_env.dart
  abstract class AppEnv {
    static const newsApiKey = String.fromEnvironment('NEWS_API_KEY');
  }
  ```
- [ ] Documentar en el README cómo correr: `flutter run --dart-define=NEWS_API_KEY=xxx`.
- [ ] Añadir `--dart-define` al job de CI usando GitHub Secrets.

### 2.6 Tests 🧪
- [ ] `test/core/error/app_failure_test.dart`: `freezed` pattern matching.
- [ ] `test/core/usecase/usecase_test.dart`: smoke de tipo.

**Criterio de salida:**
- `main.dart` ≤ 10 líneas.
- `grep -R "DioError" frontend/lib/features` vacío.
- `AppFailure` usado en al menos un use case de prueba.
- CI sigue verde.

---

## Fase 3 — Design system + Router declarativo (≈ 3–4 h) 🟢

**Objetivo:** preparar UI base antes de construir pantallas nuevas (overdelivery #15 + #21).

Cubre: **#15** (go_router tipado, reemplaza `onGenerateRoute`), **#21** (design tokens + `ThemeExtension`), parcialmente **R8**.

**Tareas**

### 3.1 Design tokens y ThemeExtension
- [ ] Crear `lib/config/theme/tokens/`:
  - `app_colors.dart` (paleta + roles semánticos).
  - `app_spacing.dart` (`xs`, `sm`, `md`, `lg`, `xl`).
  - `app_radii.dart`.
  - `app_typography.dart` (pulls de la familia Muli ya declarada en `pubspec.yaml`).
- [ ] `lib/config/theme/app_theme_extension.dart`: clase con `extends ThemeExtension<AppTheme>` agrupando todos los tokens semánticos (`surface`, `onSurface`, `primary`, `spacing`, etc.).
- [ ] Refactor de [config/theme/app_themes.dart](../../frontend/lib/config/theme/app_themes.dart) para producir `ThemeData` claro y oscuro a partir de los tokens.
- [ ] Exponer helper: `extension ThemeX on BuildContext { AppTheme get t => Theme.of(this).extension<AppTheme>()!; }`.

### 3.2 Router declarativo
- [ ] Crear `lib/config/routes/app_router.dart` con `go_router`:
  ```dart
  final appRouter = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const DailyNewsPage()),
      GoRoute(path: '/article/:id', builder: (_, s) => ArticleDetailPage(id: s.pathParameters['id']!)),
      GoRoute(path: '/saved', builder: (_, __) => const SavedArticlesPage()),
      // Rutas a añadir en F6/F7
      GoRoute(path: '/me/articles', ...),
      GoRoute(path: '/me/articles/new', ...),
      GoRoute(path: '/me/articles/:id/edit', ...),
    ],
  );
  ```
- [ ] Definir helpers tipados: `AppRoutes.articleDetail(String id) => '/article/$id';`.
- [ ] Reemplazar `MaterialApp(onGenerateRoute: ...)` por `MaterialApp.router(routerConfig: appRouter, theme: ..., darkTheme: ...)` en `app.dart`.
- [ ] Eliminar lógica manual en [config/routes/routes.dart](../../frontend/lib/config/routes/routes.dart) (o reducirla a una fachada).

**Criterio de salida:**
- Navegar entre `DailyNews` y `ArticleDetail` usando `context.go(AppRoutes.articleDetail(id))`.
- Cambiar un token (color o spacing) se propaga sin tocar widgets individuales.
- Modo oscuro funcional con tokens.

---

## Fase 4 — Refactor de `daily_news` al nuevo estándar (≈ 4 h) 🟡 🧪

**Objetivo:** dejar la feature existente **alineada** con todo lo construido en F1–F3. Evita deuda técnica mixta.

Cubre: **D2** (modelos con `freezed`/`json_serializable`), **D3–D5** (repository consistente + `Either`), **D6** (entidad con reglas de negocio), **D10** (bloc global extraído).

**Tareas**
- [ ] Convertir `ArticleEntity` a `freezed` manteniendo el API. Añadir una regla de negocio mínima (p. ej. `bool get isValidForDisplay => (title?.isNotEmpty ?? false);`).
- [ ] Convertir `ArticleModel` a `freezed` + `json_serializable` (`@JsonKey(defaultValue: '')`). Eliminar los `?? ""` manuales.
- [ ] Refactor de [article_repository_impl.dart](../../frontend/lib/features/daily_news/data/repository/article_repository_impl.dart): **todos** los métodos retornan `Future<Either<AppFailure, T>>`. Método helper privado `_guard()` para capturar excepciones y mapearlas.
- [ ] Actualizar `domain/repository/article_repository.dart` para reflejar `Either<AppFailure, T>`.
- [ ] Actualizar blocs `RemoteArticlesBloc` y `LocalArticleBloc` para consumir `Either` con pattern-matching:
  ```dart
  final result = await getArticles(const NoParams());
  result.fold(
    (f) => emit(RemoteArticlesError(f)),
    (r) => emit(RemoteArticlesDone(r)),
  );
  ```
- [ ] Estados del bloc con `freezed` + `sealed class` (exhaustividad en `switch`).
- [ ] Extraer `BlocProvider<RemoteArticlesBloc>` global de `main.dart` a un `app_providers.dart` en `lib/config/` con `MultiBlocProvider`. Mover el `add(GetArticles())` a `BlocProvider.lazy: false` + `create` dedicado o a un `initializer`.
- [ ] Tests 🧪 en `test/features/daily_news/`:
  - `domain/usecases/get_article_test.dart` con `mocktail`.
  - `data/repository/article_repository_impl_test.dart` con fakes de `NewsApiService` y `AppDatabase`.
  - `presentation/bloc/remote_article_bloc_test.dart` con `bloc_test`.

**Criterio de salida:**
- La feature existente sigue funcionando idénticamente al usuario.
- Cobertura ≥ 60 % en la capa de dominio y repositorio de `daily_news`.
- CI pasa.

---

## Fase 5 — Backend: schema + reglas (≈ 4 h) 🔴 🧪

**Objetivo:** congelar el contrato de datos antes de escribir el data layer nuevo.

Cubre: puntos oficiales 1.1/1.2/1.3 de la prueba + endurecimiento con Auth.

**Tareas**
- [ ] Diseñar schema `articles/{articleId}` en [backend/docs/DB_SCHEMA.md](../../backend/docs/DB_SCHEMA.md) (crear carpeta/archivo):
  - Campos: `id`, `authorId`, `authorName`, `title`, `description`, `content`, `thumbnailURL`, `publishedAt` (Timestamp), `updatedAt`, `tags[]`, `status` (`draft|published`).
  - Subcolección opcional para comentarios/likes (documentar aunque no se implemente).
  - Ejemplo de documento JSON real.
- [ ] Escribir [backend/firestore.rules](../../backend/firestore.rules):
  - `allow read: if true;` para `articles` publicados (según decisión de negocio).
  - `allow create: if request.auth != null && request.resource.data.authorId == request.auth.uid && isValidArticle(request.resource.data);`.
  - `allow update, delete: if request.auth != null && resource.data.authorId == request.auth.uid;`.
  - Función `isValidArticle()` con validaciones de tipo y tamaño de campos.
- [ ] Escribir [backend/storage.rules](../../backend/storage.rules):
  - Path: `media/articles/{userId}/{articleId}/{file}`.
  - `allow write: if request.auth != null && request.auth.uid == userId && request.resource.size < 5 * 1024 * 1024 && request.resource.contentType.matches('image/.*');`.
  - `allow read: if true;`.
- [ ] Deploy: `firebase deploy --only firestore:rules,storage:rules`.
- [ ] Probar en el simulador Firebase: al menos un caso permitido y un caso denegado por regla.
- [ ] 🧪 *(opcional 🟢)* Tests con `@firebase/rules-unit-testing` (Node).

**Criterio de salida:**
- Un usuario autenticado puede crear un artículo suyo pero no uno ajeno; un anónimo nunca puede escribir.
- `thumbnailURL` dentro del documento solo se acepta si apunta al path correcto en Storage.

---

## Fase 6 — Domain layer `user_articles` (≈ 3–4 h) 🔴 🧪

**Objetivo:** modelar la nueva feature con use_cases puros (Dart + `freezed` + `dartz`), sin Flutter ni Firebase.

Cubre: puntos 2.1 del README + **D6** (entidades con reglas) + **R6** (tests).

**Tareas**
- [ ] Estructura:
  ```
  frontend/lib/features/user_articles/
  └── domain/
      ├── entities/user_article_entity.dart        (freezed)
      ├── repository/user_article_repository.dart  (interface)
      ├── params/{publish,update,delete}_article_params.dart
      └── usecases/
          ├── get_my_articles.dart
          ├── publish_article.dart
          ├── update_article.dart
          ├── delete_article.dart
          └── upload_thumbnail.dart
  ```
- [ ] `UserArticleEntity` con `freezed` y métodos de negocio: `bool get canPublish => title.length >= 5 && content.length >= 50 && thumbnailURL != null;`.
- [ ] Interface del repositorio: todos los métodos retornan `Future<Either<AppFailure, T>>`.
- [ ] Use cases extienden `UseCase<R, P>` base.
- [ ] **Mock data** inicial dentro de los use cases o detrás de un `FakeUserArticleRepository` inyectado por `get_it` en modo debug (limpio para sustituir en F8).
- [ ] 🧪 Tests unitarios TDD para cada use case + para reglas de negocio de la entidad. Confirmar con `grep` que `domain/` no importa `flutter`, `firebase_*`, `cloud_firestore`, `dio`, `floor`.

**Criterio de salida:**
- `flutter test features/user_articles/domain/` verde.
- Zero imports prohibidos en `domain/`.

---

## Fase 7 — Presentation layer `user_articles` (≈ 10–12 h) 🔴 🧪

**Objetivo:** convertir el Figma a Flutter usando **design tokens + go_router**, cableado a los use_cases con mock data.

Cubre: punto 2.2 del README + **D10** (providers extraídos) + **R5**/**R8** (freezed en estados + router tipado).

**Tareas**
- [ ] Cubits:
  - `MyArticlesCubit` (lista) con estados `initial/loading/success(List)/failure(AppFailure)` (freezed).
  - `ArticleEditorBloc` (create + edit) con eventos `titleChanged`, `contentChanged`, `thumbnailPicked`, `submitted`.
- [ ] Pantallas (todas usando `AppTheme`):
  - `MyArticlesPage` (lista con pull-to-refresh).
  - `ArticleEditorPage` (formulario + image picker → callback `UploadThumbnail`).
  - `UserArticleDetailPage` (preview).
- [ ] Widgets reutilizables en `presentation/widgets/`: `ArticleCard`, `ThumbnailPickerTile`, `PrimaryButton`.
- [ ] Rutas en `app_router.dart` (ya preparado en F3).
- [ ] Registrar blocs en `injection_container.dart` con `registerFactory`.
- [ ] Integrar en el `MultiBlocProvider` global (o usar `BlocProvider` local en la screen).
- [ ] 🧪 Tests con `bloc_test` para cada estado del editor + widget test del formulario.

**Criterio de salida:**
- Recorrido completo con mock data: listar → crear → editar → borrar.
- Cambiar un design token se refleja en la feature nueva sin tocar screens.

---

## Fase 8 — Data layer `user_articles` (≈ 5–6 h) 🔴 🧪

**Objetivo:** sustituir mocks por Firestore + Cloud Storage reales.

Cubre: punto 2.3 del README + **R2** aplicado a la feature nueva.

**Tareas**
- [ ] Estructura:
  ```
  user_articles/data/
  ├── data_sources/remote/
  │   ├── user_articles_firestore_data_source.dart
  │   └── user_articles_storage_data_source.dart
  ├── models/user_article_model.dart
  └── repository/user_article_repository_impl.dart
  ```
- [ ] Data sources **lanzan excepciones** (regla 1.2.1 de [ARCHITECTURE_VIOLATIONS](../ARCHITECTURE_VIOLATIONS.md)).
- [ ] `UserArticleModel` con `freezed` + `fromFirestore`/`toFirestore`.
- [ ] `UserArticleRepositoryImpl` implementa la interfaz: mapea excepciones a `AppFailure` y retorna `Either`.
- [ ] Sustituir el binding mock en `injection_container.dart`:
  ```dart
  sl.registerSingleton<UserArticleRepository>(UserArticleRepositoryImpl(sl(), sl()));
  ```
- [ ] Probar **contra emulador** primero, luego contra proyecto real.
- [ ] 🧪 Tests con `fake_cloud_firestore` y `firebase_storage_mocks` para `RepositoryImpl`.

**Criterio de salida:**
- Crear artículo → documento en Firestore + imagen en Storage.
- Al reiniciar la app, el artículo reaparece.
- No hay `DataState` ni `DioError` en ninguna capa (solo `Either<AppFailure, T>`).

---

## Fase 9 — QA, pulido, accesibilidad, reporte (≈ 3–4 h) 🔴 🧪

**Objetivo:** entregar con calidad demostrable.

**Tareas**
- [ ] `flutter analyze` sin warnings.
- [ ] `dart format .`.
- [ ] Cobertura global objetivo ≥ 50 % (`flutter test --coverage` + `lcov`).
- [ ] Revisión contra [02_CHECKLIST.md](./02_CHECKLIST.md) completa.
- [ ] Estados vacío / carga / error verificados en cada pantalla.
- [ ] Red caída probada manualmente (airplane mode).
- [ ] Accesibilidad mínima: `Semantics`, `tooltip`, contraste.
- [ ] Pruebas en Android + Chrome (iOS si hay Mac).
- [ ] Redactar [docs/REPORT.md](../REPORT.md) con las 7 secciones de [REPORT_INSTRUCTIONS.md](../REPORT_INSTRUCTIONS.md).
- [ ] Grabar vídeo corto (≤ 2 min) del flujo end-to-end.
- [ ] Capturar screenshots.
- [ ] Actualizar README raíz con: cómo correr, credenciales de `--dart-define`, comandos de deploy.
- [ ] Tag `v1.0.0`.

**Criterio de salida:**
- Un revisor que clone el repo desde cero puede seguir el README y correr la app sin intervención.
- CI verde en `main`.

---

## Mapeo de mejoras del análisis → fases

| Propuesta del análisis | Tipo | Fase |
|---|---|---|
| R1 Inicializar Firebase + separar bootstrap | 🔴 | F2 |
| R2 Uniformar retorno a `DataState` / `Either` | 🔴 | F2 + F4 + F8 |
| R3 Jerarquía `AppFailure` (sustituye `DioError`) | 🔴 | F2 |
| R4 Migración a Dart 3 + null-safety estricta | 🟡 | F1 |
| R5 `freezed` en entidades/estados | 🟡 | F2 + F4 + F6 + F7 |
| R6 Carpeta `test/` con mocks y bloc_test | 🟡 | F1 (setup) + F4/F6/F7/F8 |
| R7 CI GitHub Actions | 🟡 | F1 |
| R8 Router declarativo (`go_router`) — OD #15 | 🟢 | F3 |
| R9 Crashlytics / Performance | — | No incluido |
| R10 Modularización con melos | — | No incluido |
| D2 Errores silenciosos en `fromJson` | 🟡 | F4 |
| D6 Entidades sin lógica de negocio | 🟡 | F4 (daily_news) + F6 (user_articles) |
| D8 `flutter_lints` desactualizado | 🟡 | F1 |
| D10 BlocProvider global en `main.dart` | 🟡 | F4 |
| D12 Handlers globales de error | 🟡 | F2 |
| D14 Acoplamiento a `DioError` en `DataState` | 🟡 | F2 |
| D15 Crear `shared/` | 🟡 | F2 |
| #14 Env vars para `newsAPIKey` | 🟡 | F2 |
| #21 Design tokens + `ThemeExtension` — OD | 🟢 | F3 |

---

## Estimación total

| Fase | Horas | Acumulado |
|---|---|---|
| F0 Setup | 1–2 | 2 |
| F1 Modernización | 4 | 6 |
| F2 Core/shared/bootstrap | 4 | 10 |
| F3 Design system + Router | 4 | 14 |
| F4 Refactor daily_news | 4 | 18 |
| F5 Backend (schema + rules) | 4 | 22 |
| F6 Domain user_articles | 4 | 26 |
| F7 Presentation user_articles | 12 | 38 |
| F8 Data user_articles | 6 | 44 |
| F9 QA + reporte | 4 | 48 |

Margen de ~24 h dentro de las 72 h para imprevistos y pulido.

---

## Plan de batches y commits (PR único)

> El proyecto se entrega en **un único Pull Request**. Cada fase se divide en **batches controlados** y **cada batch = un commit atómico** con mensaje en formato *Conventional Commits* (`feat:`, `refactor:`, `test:`, `chore:`, `docs:`, `ci:`, `fix:`). Esto permite revisión, reversión (`git revert <sha>`) y `git bisect` precisos aun dentro de un solo PR.
>
> **Regla de oro por batch:** el repo debe compilar y `flutter analyze` debe pasar **al final de cada commit** (no al final del PR). Si un batch rompe la build, se parte en 2 batches más pequeños.

### F0 — Setup (2 commits)
| # | Commit | Archivos |
|---|---|---|
| B0.1 | `chore(backend): set firebase projectId in .firebaserc` | [backend/.firebaserc](../../backend/.firebaserc) |
| B0.2 | `chore(backend): wire emulators config in firebase.json` | [backend/firebase.json](../../backend/firebase.json) |

### F1 — Modernización (6 commits)
| # | Commit | Archivos |
|---|---|---|
| B1.1 | `chore(deps): bump sdk to dart 3.3 and flutter 3.19` | `pubspec.yaml` |
| B1.2 | `chore(lint): adopt very_good_analysis with strict language modes` | `pubspec.yaml`, `analysis_options.yaml` |
| B1.3 | `chore(deps): add freezed, json_serializable, dartz, go_router` | `pubspec.yaml`, `pubspec.lock` |
| B1.4 | `chore(deps): add test tooling (mocktail, bloc_test, fakes)` | `pubspec.yaml`, `pubspec.lock` |
| B1.5 | `ci: add github actions workflow (analyze, format, test)` | `.github/workflows/ci.yml` |
| B1.6 | `test: add placeholder smoke test to bootstrap test dir` | `frontend/test/placeholder_test.dart` |

### F2 — Core / shared / bootstrap (8 commits)
| # | Commit | Archivos |
|---|---|---|
| B2.1 | `refactor(core): scaffold shared/ folder per architecture spec` | `frontend/lib/shared/.gitkeep`, moves if any |
| B2.2 | `feat(core): introduce AppFailure hierarchy with freezed` | `core/error/app_failure.dart` + `.g/.freezed.dart` |
| B2.3 | `refactor(core): replace DataState with Either<AppFailure, T>` | `core/resources/data_state.dart` (eliminado o reemplazado) |
| B2.4 | `feat(core): add base UseCase<R, P> returning Either` | `core/usecase/usecase.dart` |
| B2.5 | `feat(core): add AppEnv reading NEWS_API_KEY via --dart-define` | `core/env/app_env.dart`, `core/constants/constants.dart` |
| B2.6 | `feat(app): split main into bootstrap.dart and app.dart with Firebase init` | `lib/main.dart`, `lib/bootstrap.dart`, `lib/app.dart`, `lib/firebase_options.dart` |
| B2.7 | `feat(core): register global error handlers and logger` | `core/logger/app_logger.dart`, `lib/bootstrap.dart` |
| B2.8 | `test(core): cover AppFailure pattern matching and UseCase base` | `test/core/**` |

### F3 — Design system + Router (6 commits)
| # | Commit | Archivos |
|---|---|---|
| B3.1 | `feat(theme): add design tokens (colors, spacing, radii, typography)` | `config/theme/tokens/*.dart` |
| B3.2 | `feat(theme): add AppTheme ThemeExtension and context helper` | `config/theme/app_theme_extension.dart` |
| B3.3 | `refactor(theme): rebuild light+dark ThemeData from tokens` | `config/theme/app_themes.dart` |
| B3.4 | `feat(routes): introduce go_router with typed route helpers` | `config/routes/app_router.dart`, `config/routes/app_routes.dart` |
| B3.5 | `refactor(app): migrate to MaterialApp.router` | `lib/app.dart` |
| B3.6 | `chore(routes): remove legacy onGenerateRoute plumbing` | `config/routes/routes.dart` |

### F4 — Refactor `daily_news` (6 commits)
| # | Commit | Archivos |
|---|---|---|
| B4.1 | `refactor(daily_news): convert ArticleEntity to freezed with business rules` | `domain/entities/article.dart` |
| B4.2 | `refactor(daily_news): convert ArticleModel to freezed + json_serializable` | `data/models/article.dart` |
| B4.3 | `refactor(daily_news): return Either<AppFailure, T> from repository` | `data/repository/article_repository_impl.dart`, `domain/repository/article_repository.dart` |
| B4.4 | `refactor(daily_news): convert bloc states to freezed sealed classes` | `presentation/bloc/article/**` |
| B4.5 | `refactor(app): extract MultiBlocProvider to app_providers.dart` | `config/app_providers.dart`, `lib/app.dart`, `lib/main.dart` |
| B4.6 | `test(daily_news): cover usecases, repository and bloc` | `test/features/daily_news/**` |

### F5 — Backend schema + rules (3 commits)
| # | Commit | Archivos |
|---|---|---|
| B5.1 | `docs(backend): add DB_SCHEMA.md describing articles collection` | `backend/docs/DB_SCHEMA.md` |
| B5.2 | `feat(backend): enforce firestore.rules with auth and validation` | `backend/firestore.rules`, `backend/firestore.indexes.json` |
| B5.3 | `feat(backend): enforce storage.rules with size and contentType checks` | `backend/storage.rules` |

### F6 — Domain `user_articles` (4 commits)
| # | Commit | Archivos |
|---|---|---|
| B6.1 | `feat(user_articles): scaffold domain with entity and repository interface` | `features/user_articles/domain/entities/*`, `.../repository/*` |
| B6.2 | `feat(user_articles): add params classes for write operations` | `features/user_articles/domain/params/*` |
| B6.3 | `feat(user_articles): implement use cases with mock repository` | `features/user_articles/domain/usecases/*` |
| B6.4 | `test(user_articles): add domain layer unit tests (TDD)` | `test/features/user_articles/domain/**` |

### F7 — Presentation `user_articles` (9 commits)
| # | Commit | Archivos |
|---|---|---|
| B7.1 | `feat(user_articles): add MyArticlesCubit with freezed states` | `presentation/bloc/my_articles/*` |
| B7.2 | `feat(user_articles): add ArticleEditorBloc with freezed events/states` | `presentation/bloc/article_editor/*` |
| B7.3 | `feat(user_articles): scaffold MyArticlesPage from Figma` | `presentation/pages/my_articles/*` |
| B7.4 | `feat(user_articles): scaffold ArticleEditorPage with image picker` | `presentation/pages/article_editor/*` |
| B7.5 | `feat(user_articles): scaffold UserArticleDetailPage` | `presentation/pages/user_article_detail/*` |
| B7.6 | `feat(user_articles): add reusable widgets (ArticleCard, ThumbnailPickerTile, PrimaryButton)` | `presentation/widgets/*` |
| B7.7 | `feat(routes): register user_articles routes in go_router` | `config/routes/app_router.dart`, `config/routes/app_routes.dart` |
| B7.8 | `feat(di): register user_articles blocs and use cases in get_it` | `lib/injection_container.dart` |
| B7.9 | `test(user_articles): add bloc_test and widget tests` | `test/features/user_articles/presentation/**` |

### F8 — Data `user_articles` (6 commits)
| # | Commit | Archivos |
|---|---|---|
| B8.1 | `feat(user_articles): add Firestore remote data source` | `data/data_sources/remote/user_articles_firestore_data_source.dart` |
| B8.2 | `feat(user_articles): add Cloud Storage data source for thumbnails` | `data/data_sources/remote/user_articles_storage_data_source.dart` |
| B8.3 | `feat(user_articles): add UserArticleModel with Firestore converters` | `data/models/user_article_model.dart` |
| B8.4 | `feat(user_articles): implement repository returning Either<AppFailure, T>` | `data/repository/user_article_repository_impl.dart` |
| B8.5 | `refactor(di): swap mock repository for real implementation` | `lib/injection_container.dart` |
| B8.6 | `test(user_articles): add repository tests with fake_cloud_firestore` | `test/features/user_articles/data/**` |

### F9 — QA + reporte (6 commits)
| # | Commit | Archivos |
|---|---|---|
| B9.1 | `chore: run dart format across the codebase` | (múltiples) |
| B9.2 | `fix: address remaining flutter analyze warnings` | (múltiples) |
| B9.3 | `feat(a11y): add semantic labels and tooltips to primary screens` | `presentation/**` |
| B9.4 | `docs(readme): update run instructions with --dart-define and emulators` | `README.md`, `frontend/README.md`, `backend/README.md` |
| B9.5 | `docs(report): write REPORT.md with screenshots and video links` | `docs/REPORT.md`, `docs/assets/**` |
| B9.6 | `docs: add CHANGELOG entry for v1.0.0` | `CHANGELOG.md` |

### Resumen de volumen

| Fase | Batches/commits |
|---|---|
| F0 | 2 |
| F1 | 6 |
| F2 | 8 |
| F3 | 6 |
| F4 | 6 |
| F5 | 3 |
| F6 | 4 |
| F7 | 9 |
| F8 | 6 |
| F9 | 6 |
| **Total** | **56 commits dentro del PR único** |

> Si al ejecutar alguna fase un batch crece demasiado (más de ~300 líneas netas o toca más de 10 archivos), **partirlo en 2 batches** antes de commitear.

---

## Reglas de oro durante la ejecución

1. **No saltar fases**: cada una prepara la siguiente; romper el orden genera refactors dobles.
2. **Un PR único** hacia `main` que acumule todos los batches de todas las fases, en el mismo orden del plan.
3. **Un batch = un commit atómico**, siguiendo el desglose de la sección *Plan de batches y commits*. Usa Conventional Commits (`feat:`, `refactor:`, `test:`, `chore:`, `docs:`, `ci:`, `fix:`).
4. **Cada commit debe compilar**: `flutter analyze` verde antes de `git commit`. Si no, partir el batch.
5. **Tests junto al código**: los batches `test:` van inmediatamente después del batch `feat:`/`refactor:` que cubren, no al final.
6. **Si algo rompe F1 (Dart 3 / lints)**: priorizar desbloquear la compilación antes de avanzar. Es la base.
7. **No tocar `domain/`** con imports de Flutter/Firebase — verificar con `grep` al cierre de F6.
8. **Accesibilidad y estados vacíos no son opcionales** — se revisan en F9.
9. **Antes de push final**: revisar `git log --oneline` y confirmar que la secuencia de commits cuenta una historia coherente de principio a fin.

---

## Próximo paso inmediato

Ejecutar la **Fase 0**: `flutter doctor`, instalar CLIs, crear el proyecto Firebase, y confirmar que la app preexistente compila. Una vez verde, abrir una rama `chore/modernization` y comenzar la Fase 1.
