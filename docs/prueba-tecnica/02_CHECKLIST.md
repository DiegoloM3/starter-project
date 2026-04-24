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

- [ ] 🔴 Archivo `backend/docs/DB_SCHEMA.md` creado.
- [ ] 🔴 Define la colección `articles` con todos sus campos y tipos.
- [ ] 🔴 Define cómo se representa el autor (campo `authorId` / subdocumento / referencia).
- [ ] 🔴 Campo `thumbnailURL` referencia explícitamente `media/articles/...` en Cloud Storage.
- [ ] 🔴 Documenta timestamps (`createdAt`, `updatedAt`) y si usan `serverTimestamp`.
- [ ] 🟡 Describe subcolecciones futuras (comentarios, likes) aunque no se implementen.
- [ ] 🟡 Incluye un **ejemplo de documento JSON** real.
- [ ] 🟢 Diagrama UML/mermaid del schema.

---

## C. Backend — Reglas (Firestore + Storage)

- [ ] 🔴 `firestore.rules` deniega por defecto (`allow read, write: if false;` en la raíz).
- [ ] 🔴 Permite lectura pública (o autenticada) de `articles` según lo decidido.
- [ ] 🔴 Solo el autor puede crear/editar/borrar sus propios artículos (`request.auth.uid == resource.data.authorId`).
- [ ] 🔴 Valida tipos y longitudes (`request.resource.data.title is string && request.resource.data.title.size() > 5`).
- [ ] 🔴 `storage.rules` restringe writes al path `media/articles/{userId}/...` al autor autenticado.
- [ ] 🔴 Storage valida `contentType` (sólo imágenes) y tamaño (`request.resource.size < 5 * 1024 * 1024`).
- [ ] 🔴 Reglas desplegadas: `firebase deploy --only firestore:rules,storage:rules`.
- [ ] 🟡 Probadas con el simulador web de Firebase (al menos caso permitido + caso denegado).
- [ ] 🟢 Tests automatizados con `@firebase/rules-unit-testing`.

---

## D. Frontend — Domain layer

- [ ] 🔴 Existe `frontend/lib/features/user_articles/domain/`.
- [ ] 🔴 Entidad `UserArticleEntity` con `Equatable`.
- [ ] 🔴 Interface `UserArticleRepository` declarada (no implementada aquí).
- [ ] 🔴 Use cases con método `call(params)`:
  - [ ] `GetMyArticlesUseCase`
  - [ ] `PublishArticleUseCase`
  - [ ] `UpdateArticleUseCase`
  - [ ] `DeleteArticleUseCase`
  - [ ] `UploadThumbnailUseCase`
- [ ] 🔴 `domain/` **no importa** `flutter`, `firebase_*`, `dio`, `floor` ni nada ajeno a Dart puro.
  - Validación rápida: `grep -R "import 'package:flutter" frontend/lib/features/*/domain/` → vacío.
- [ ] 🔴 Cada use case tiene una **sola** responsabilidad.
- [ ] 🟡 Cada entidad tiene al menos una regla de negocio (validación) testeada.

---

## E. Frontend — Presentation layer

- [ ] 🔴 BLoCs/Cubits creados por feature en `presentation/bloc/`.
- [ ] 🔴 Los blocs son lo **único** que importa `use_cases`.
- [ ] 🔴 Los widgets/screens **no** acceden a repositorios ni data sources.
- [ ] 🔴 Todas las pantallas del Figma relevantes están implementadas:
  - [ ] Lista de mis artículos.
  - [ ] Crear/editar artículo.
  - [ ] Detalle/preview.
- [ ] 🔴 Cada pantalla tiene estados de **carga**, **éxito**, **vacío** y **error**.
- [ ] 🔴 Blocs registrados en `injection_container.dart` con `registerFactory`.
- [ ] 🟡 Navegación centralizada en `config/routes/routes.dart`.
- [ ] 🟡 Componentes reutilizables en `presentation/widgets/`.
- [ ] 🟢 Animaciones y transiciones fieles al Figma.
- [ ] 🟢 Modo oscuro funcional.

---

## F. Frontend — Data layer

- [ ] 🔴 `data_sources/` contiene solo conexión externa; **lanza excepciones**.
- [ ] 🔴 `models/` extienden entidades y exponen `fromRawData` + `toEntity()`.
- [ ] 🔴 `repository/*_impl.dart` implementa la interfaz del dominio y retorna `DataState<T>`.
- [ ] 🔴 Solo `repository/*_impl.dart` importa providers (Firestore/Storage/Floor/Dio).
- [ ] 🔴 Flujo probado contra **emulador Firebase**.
- [ ] 🔴 Flujo probado contra **proyecto Firebase real**.
- [ ] 🟡 Cache local o reintentos básicos de red.
- [ ] 🟢 Sincronización offline (Firestore persistence + Floor).

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

- [ ] 🔴 `docs/REPORT.md` contiene las 7 secciones de `REPORT_INSTRUCTIONS.md`.
- [ ] 🔴 Screenshots de cada pantalla clave.
- [ ] 🔴 Vídeo demo del flujo completo (≤ 2 min).
- [ ] 🔴 Sección *Overdelivery* detalla lo extra (o indica explícitamente que no hubo).
- [ ] 🔴 README principal actualizado con instrucciones para correr el proyecto (credenciales de emulador, etc.).
- [ ] 🟡 Commits con mensajes claros (`feat:`, `fix:`, `docs:`, `refactor:`...).
- [ ] 🟡 Una rama por entregable + PR a `main` (demuestra el flujo de Symmetry).
- [ ] 🟢 Tag de versión `v1.0.0` al terminar.

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
