# Análisis de la Arquitectura Actual y Propuestas de Mejora

> Diagnóstico honesto del estado del repositorio *tal como está hoy* (antes de comenzar la prueba) y propuestas concretas, ordenadas por impacto, para mejorarlo. Respeta la definición oficial en [docs/APP_ARCHITECTURE.md](../APP_ARCHITECTURE.md) y las reglas de [ARCHITECTURE_VIOLATIONS.md](../ARCHITECTURE_VIOLATIONS.md).

---

## 1. Estado actual en un vistazo

### 1.1 Estructura de carpetas

```
frontend/lib/
├── config/            routes + theme
├── core/              constants, resources (DataState), usecase base
├── features/
│   └── daily_news/
│       ├── data/      data_sources (local Floor DAO + remote Dio/Retrofit), models, repository
│       ├── domain/    entities, repository (interface), usecases
│       └── presentation/
│           ├── bloc/article/{local,remote}
│           ├── pages/{home,article_detail,saved_article}
│           └── widgets/
├── injection_container.dart  (GetIt)
└── main.dart
```

### 1.2 Stack observado

| Área | Herramienta | Notas |
|---|---|---|
| Red | `dio` + `retrofit` | Llama NewsAPI (`newsAPIKey` en `core/constants`). |
| BD local | `floor` | Wrapper sobre sqflite. Guardado de artículos offline. |
| State | `flutter_bloc` 8.x | Patrón BLoC clásico con eventos. |
| DI | `get_it` | Singletons y factories manuales en `injection_container.dart`. |
| Firebase | `firebase_core`, `cloud_firestore`, `firebase_storage` | Dependencias **declaradas** en `pubspec.yaml` pero **no inicializadas** todavía (no hay `Firebase.initializeApp()` en `main.dart`). |
| UI | Material + `cached_network_image`, `ionicons`, `flutter_hooks` | Hooks declarados pero poco usados. |

### 1.3 Capas implementadas hoy (feature `daily_news`)

| Capa | Archivos | Estado |
|---|---|---|
| `domain/entities` | `article.dart` | ✅ Pura, con `Equatable`. |
| `domain/repository` | `article_repository.dart` | ✅ Interfaz abstracta. |
| `domain/usecases` | `get_article`, `get_saved_article`, `save_article`, `remove_article` | ✅ Cada uno con un `call()`. |
| `data/data_sources` | Remote (Retrofit) + Local (Floor DAO) | ✅ Aislados. |
| `data/models` | `ArticleModel` extiende `ArticleEntity` | ✅ Extiende la entidad, tiene `fromJson` + `fromEntity`. |
| `data/repository` | `ArticleRepositoryImpl` | ✅ Implementa la interfaz, retorna `DataState<T>` para red. |
| `presentation/bloc` | `remote_article_bloc`, `local_article_bloc` | ✅ Divididos por origen de datos. |
| `presentation/pages` | 3 pantallas | ✅ Funcionales. |

### 1.4 Lo que *falta* para cumplir la prueba

- Carpetas `shared/` no existen (el arquetipo las prevé, [APP_ARCHITECTURE.md](../APP_ARCHITECTURE.md#folder-structure-of-the-app)).
- No hay feature `user_articles` ni equivalente.
- Firebase declarado en `pubspec.yaml` pero no inicializado.
- `backend/firestore.rules` y `backend/storage.rules` vacíos (solo `TODO`).
- `backend/docs/DB_SCHEMA.md` inexistente.
- Carpeta `test/` inexistente (la arquitectura dice que `test/` debe espejar `lib/`).
- `frontend/lib/config/routes/routes.dart` existe pero conviene revisar que siga la convención después de añadir rutas.

---

## 2. Observaciones finas (lo que ya está pero puede mejorar)

### 2.1 Fortalezas
- **Separación clara** de las 3 capas clean en `daily_news`: respeta la regla de imports.
- **`ArticleModel` extiende `ArticleEntity`**: cumple [ARCHITECTURE_VIOLATIONS 1.3.1](../ARCHITECTURE_VIOLATIONS.md).
- **`DataState<T>`** ya existe en `core/resources/data_state.dart` como contrato único de retorno de red.
- **Separación local/remote** en los blocs: escala bien cuando se sumen nuevas fuentes (Firestore).
- **DI con `get_it`** centralizada en un solo archivo.

### 2.2 Debilidades detectadas

| # | Observación | Evidencia | Impacto |
|---|---|---|---|
| D1 | `newsAPIKey` se importa desde `core/constants` hacia `data/repository` — OK, pero la clave vive en el repo. | [article_repository_impl.dart:22](../../frontend/lib/features/daily_news/data/repository/article_repository_impl.dart#L22) | Seguridad: la key viaja al binario. |
| D2 | `null` silenciosos en `ArticleModel.fromJson` (`map['author'] ?? ""`). | [article.dart:28-36](../../frontend/lib/features/daily_news/data/models/article.dart#L28-L36) | Se pierden datos malformados sin logging. |
| D3 | El repository envuelve `DioError` manualmente en la rama `!= 200`. | [article_repository_impl.dart:29-37](../../frontend/lib/features/daily_news/data/repository/article_repository_impl.dart#L29-L37) | Duplicación de lógica de mapeo a `DataFailed`. |
| D4 | `getSavedArticles()` y `saveArticle()` **no** retornan `DataState`. | [article_repository_impl.dart:45-57](../../frontend/lib/features/daily_news/data/repository/article_repository_impl.dart#L45-L57) | Inconsistencia con el resto del patrón; errores de SQLite llegan crudos al bloc. |
| D5 | `DataSuccess(httpResponse.data)` devuelve `List<ArticleModel>` al dominio, pero el dominio debería trabajar con **entidades**. | Viola [ARCHITECTURE_VIOLATIONS 2.4.2](../ARCHITECTURE_VIOLATIONS.md) en espíritu. | Acoplamiento débil entre capas. |
| D6 | La entidad `ArticleEntity` no implementa **ninguna** lógica de negocio (solo data). | [entities/article.dart](../../frontend/lib/features/daily_news/domain/entities/article.dart) | Las entidades se reducen a DTOs; se pierde el valor de la capa. |
| D7 | SDK Dart declarado `>=2.16.1 <3.0.0`. | [pubspec.yaml:9](../../frontend/pubspec.yaml#L9) | Atascado en Dart 2; Flutter 3.13+ requiere Dart 3. No hay null-safety estricta. |
| D8 | `flutter_lints: ^1.0.0` (muy antiguo). | [pubspec.yaml:53](../../frontend/pubspec.yaml#L53) | Reglas de lint desactualizadas; conviene migrar a `flutter_lints: ^3` o `very_good_analysis`. |
| D9 | No hay `test/` ni CI. | — | Las guidelines dicen que `test/` debe espejar `lib/`. |
| D10 | `main.dart` monta `BlocProvider` global pero dispara `GetArticles()` en el `create` → lógica de arranque dentro del árbol de widgets. | [main.dart:22-28](../../frontend/lib/main.dart#L22-L28) | Mezcla bootstrap con composición; difícil de testear. |
| D11 | Falta `Firebase.initializeApp()` aunque el paquete esté declarado. | [main.dart](../../frontend/lib/main.dart) | Romperá la Fase 5 en caliente. |
| D12 | No existe abstracción para logging/errores globales (`FlutterError.onError`, zoned errors). | — | Los crashes no se reportan. |
| D13 | `GetIt` registra `ArticleRepository` con `registerSingleton` pero el repo tiene estado (cache). | [injection_container.dart:27-29](../../frontend/lib/injection_container.dart#L27-L29) | Correcto funcionalmente, pero dificulta pruebas (no se puede reemplazar fácilmente). |
| D14 | Acoplamiento directo a `DioError` en la interfaz `DataState`. | — | Si mañana cambiamos a `http`, propagamos el cambio a todos los blocs. |
| D15 | No hay separación `shared/` aunque el arquetipo la prevé y ya hay código potencialmente compartible (core constants, DataState). | — | No bloqueante, pero `core` terminará engordando. |

---

## 3. Propuestas de mejora (priorizadas)

### 🔴 Imprescindibles para la prueba

1. **Inicializar Firebase** en `main.dart` y separar el bootstrap:
   ```dart
   Future<void> main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
     await initializeDependencies();
     runApp(const MyApp());
   }
   ```
2. **Crear `shared/` y mover allí `DataState`, `UseCase` base, `constants`** si varias features las consumirán, o dejarlas en `core/` y documentarlo.
3. **Nueva feature `user_articles/`** siguiendo exactamente la estructura de `daily_news/`.
4. **Enforzar el schema en el backend**: reglas de Firestore y Storage reales (no `TODO`).
5. **Hacer que TODOS los métodos de repository retornen `DataState<T>`** (uniformidad → blocs más simples).

### 🟡 Fuertes mejoras de calidad

6. **Migrar a Dart 3 / null-safety estricto** y actualizar `flutter_lints` (o `very_good_analysis`). Permite `sealed class`, `records`, `switch` exhaustivos para estados de BLoC.
7. **Reemplazar `DioError` en `DataState` por una jerarquía propia** `AppFailure` → `NetworkFailure`, `CacheFailure`, `ValidationFailure`. Desacopla el dominio del transporte.
8. **Adoptar `freezed` + `json_serializable`** para entidades/modelos: elimina boilerplate de `Equatable`, `copyWith`, `fromJson` y errores silenciosos del tipo D2.
9. **Opcional: `dartz` o `fpdart`** para reemplazar `DataState<T>` por `Either<Failure, T>` con pattern-matching real.
10. **Carpeta `test/` espejando `lib/`** con:
    - Tests unitarios de use cases (mocks de repos con `mocktail`).
    - Tests de `RepositoryImpl` contra fakes de data source.
    - Tests de blocs con `bloc_test`.
11. **CI con GitHub Actions**: `flutter analyze`, `flutter test`, `dart format --set-exit-if-changed`.
12. **Extraer el `BlocProvider<RemoteArticlesBloc>` global** a un `MultiBlocProvider` dedicado (`app_providers.dart`) que viva al nivel de `MyApp`.
13. **Handlers globales de error** con `FlutterError.onError` + `PlatformDispatcher.instance.onError`.
14. **Mover `newsAPIKey` a variables de entorno** (`--dart-define=NEWS_API_KEY=...`) o un archivo `.env` no versionado.

### 🟢 Overdelivery (nivel senior)

15. **Router declarativo** con `go_router` o `auto_route` y rutas tipadas — reemplaza `onGenerateRoute` manual.
16. **Feature flags** (p. ej. `remote_config`) para activar/desactivar subir artículos sin releases.
17. **Arquitectura modular por paquetes** (`melos`): un paquete Dart por feature para aislar grafos de dependencias (lo ideal para equipos grandes).
18. **Monitoreo**: Firebase Crashlytics + Performance.
19. **Accesibilidad**: `Semantics`, contraste, soporte a lectores de pantalla.
20. **i18n** con `flutter_localizations` + `intl_utils`.
21. **Tema extraído a design tokens** (colores, spacing, radii) consumidos desde un único `ThemeExtension`.

---

## 4. Diagrama de arquitectura propuesta (alto nivel)

```text
┌──────────────────────── presentation ────────────────────────┐
│  screens  ──▶  BLoCs/Cubits  ──▶  UseCases                   │
│                                  (pure Dart)                  │
└──────────────────────────┬────────────────────────────────────┘
                           │ contracts
                           ▼
┌─────────────────────────── domain ────────────────────────────┐
│  Entities   Repository (abstract)   Params                    │
└──────────────────────────▲────────────────────────────────────┘
                           │ implementations
                           │
┌──────────────────────────┴── data ────────────────────────────┐
│  Repository Impl  ──▶  DataSources (Firestore, Storage, API, │
│                                    SQLite via Floor)          │
│                       emiten excepciones → Repository Impl    │
│                       las mapea a DataState / Failure         │
└───────────────────────────────────────────────────────────────┘
                           │
                           ▼
                ┌──────────────────────┐
                │   core / shared      │  (DataState, Failures,
                │                      │   base UseCase, DI, logging)
                └──────────────────────┘
```

**Reglas blindadas:**
- `domain/` jamás importa `package:flutter/*` ni SDKs externos.
- `presentation/` jamás importa `data/`.
- Solo `data/repository/*_impl.dart` habla con SDKs (Firestore, Storage, Dio, Floor).

---

## 5. Roadmap sugerido de refactor (sin romper nada en producción)

| # | Acción | Rompe API pública | Esfuerzo |
|---|---|---|---|
| R1 | Inicializar Firebase + separar bootstrap | No | 15 min |
| R2 | Uniformar retorno a `DataState` en todo `RepositoryImpl` | Sí (blocs) | 1 h |
| R3 | Introducir `AppFailure` y quitar `DioError` del dominio | Sí | 2 h |
| R4 | Migrar a Dart 3 + null-safety estricta | Posible | 2–4 h |
| R5 | Añadir `freezed` a entidades/estados | No (si se mantiene shape) | 3 h |
| R6 | Crear `test/` con bloc_test + mocktail | No | 4 h |
| R7 | CI GitHub Actions | No | 30 min |
| R8 | `go_router` + rutas tipadas | Sí (navegación) | 2 h |
| R9 | Crashlytics + Performance | No | 1 h |
| R10 | Modularizar con melos (*si hay tiempo*) | Sí (paths) | 1 día |

---

## 6. Conclusión

La base del proyecto **ya respeta la mayoría** de las reglas de Clean Architecture que Symmetry exige: capas bien separadas, DI centralizada, contratos abstractos y modelos que extienden entidades. Los puntos débiles son de **madurez** (null-safety, tests, tipado de errores, boilerplate) más que de diseño. Con las acciones 🔴 listadas arriba, la prueba queda cubierta a cabalidad; las 🟡/🟢 convierten el entregable en una muestra clara de capacidad de *Maximally Overdeliver*.
