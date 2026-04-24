# ADR-0003 — Decisiones técnicas consolidadas (fuente de verdad)

- **Fecha:** 2026-04-24
- **Estado:** Accepted
- **Fases cubiertas:** F0 — F9 (el ciclo completo de la prueba técnica)
- **Rama:** `chore/modernization`
- **Supersede:** ninguno. Los ADR-0001 y ADR-0002 siguen vigentes como profundización específica de dos decisiones locales (lints y versiones de dependencias). Este documento es la **vista panorámica** que los engloba y añade el resto.

---

## 1. Propósito

Durante la ejecución de la prueba técnica se tomaron decisiones repartidas en 9 fases y 60 commits. Los ADR-0001 y ADR-0002 capturaron con detalle dos de ellas (lints y pins de dependencias), pero el resto (error handling, navegación, DI condicional, acoplamiento entre reglas de Firestore y la UI, esquema de tests, etc.) quedaba únicamente en los mensajes de commit y en los comentarios del código.

**Este ADR sirve como fuente única de verdad para defender el trabajo en la revisión técnica.** No repite lo ya documentado en los otros dos ADRs — los referencia y añade el contexto que faltaba.

---

## 2. Índice rápido de decisiones (14)

| # | Decisión | Fase | Doc detallado |
|---|---|---|---|
| D1 | Migrar a `very_good_analysis ^6` con modos `strict-*` y presupuesto de infos | F1 | [ADR-0001](./0001-lint-migration-and-info-debt-budget.md) |
| D2 | Corredor de compatibilidad pineado para `analyzer`/`dart_style`/`floor`/`retrofit`/`freezed` | F1 | [ADR-0002](./0002-dependency-version-bands.md) |
| D3 | `Either<AppFailure, T>` como contrato universal de use cases y repositorios | F2 | §4 de este ADR |
| D4 | `AppFailure` sellado con 5 variantes (`network`, `cache`, `validation`, `auth`, `unknown`) | F2 | §4 |
| D5 | Eliminar `DataState<T>` y la fuga de `DioError` hacia presentation | F2 + F4 | §4 |
| D6 | `bootstrap.dart` + `app.dart` separados; `main.dart` ≤ 10 líneas; handlers globales de error | F2 | §5 |
| D7 | Design tokens + `AppTheme extends ThemeExtension<AppTheme>` | F3 | §6 |
| D8 | `go_router ^14` declarativo con helpers tipados `AppRoutes` | F3 | §7 |
| D9 | `freezed` + `json_serializable` para entidades, modelos y estados | F2 + F4 + F6 + F7 | §8 |
| D10 | Esquema `articles` + reglas con `isValidArticle()` + Storage path `media/articles/{authorId}/{articleId}/` | F5 | §9 |
| D11 | `FakeUserArticleRepository` en `data/fake/` para destrabar F7 | F6 | §10 |
| D12 | `AuthSession` y `ThumbnailPickerService` como *ports* con stubs en dev | F7 | §11 |
| D13 | DI condicional: `Firebase.apps.isNotEmpty` decide entre real y fake | F8 | §12 |
| D14 | Article id generado client-side y propagado a Upload + Publish | F8 | §13 |

Secciones siguientes expanden de D3 en adelante. D1 y D2 viven en los ADRs dedicados; se resumen únicamente donde la interacción con otras decisiones lo requiera.

---

## 3. Contexto macro (por qué el proyecto se entrega así)

El repo base arrancaba con tres deudas arquitectónicas que ningún commit previo había capturado en un ADR:

1. `DataState<T>` exponía `DioError` en la capa de presentación. Los blocs hacían `switch` sobre tipos de error de la librería HTTP.
2. No había `firebase_options.dart` ni `Firebase.initializeApp`. `firebase_core` estaba declarado pero sin usar.
3. No había `test/`, ni CI, ni `freezed`, ni lints modernos.

El plan ([01_PLAN_FASES.md](../prueba-tecnica/01_PLAN_FASES.md)) decidió no construir la feature nueva sobre ese piso y consumir las primeras ~14 horas en una **pasada de plataforma** (F1 → F4). El resultado es que el código nuevo (F6 → F8) y el código viejo (`daily_news`) terminan hablando el mismo idioma (`Either`, `AppFailure`, `freezed`, tokens) — no hay un "este es el código de la prueba y este es el legacy" dentro del mismo árbol.

---

## 4. D3, D4, D5 — Contrato universal de errores

**Decisión:** toda operación que pueda fallar retorna `Future<Either<AppFailure, T>>`. `AppFailure` es una unión sellada con 5 variantes exhaustivas. `DataState<T>` y `DioError` desaparecen del grafo de imports de `lib/features/`.

```dart
// core/error/app_failure.dart
@freezed
class AppFailure with _$AppFailure {
  const factory AppFailure.network({String? message, int? statusCode}) = NetworkFailure;
  const factory AppFailure.cache({String? message})                    = CacheFailure;
  const factory AppFailure.validation({required String field, required String reason})
                                                                        = ValidationFailure;
  const factory AppFailure.auth({String? message})                     = AuthFailure;
  const factory AppFailure.unknown({Object? cause, StackTrace? stackTrace}) = UnknownFailure;
}

// core/usecase/usecase.dart
abstract class UseCase<R, P> {
  const UseCase();
  Future<Either<AppFailure, R>> call(P params);
}
```

**Por qué `Either` y no `DataState` + `FailureOrSuccess<T>`:**

- `Either` fuerza al consumidor a manejar ambos casos en el mismo `fold`. Un `DataState` con un getter `.isError` permite olvidar el caso feliz o infeliz y dejarlo sin cubrir.
- `Either` es el paradigma que `dartz` ha empaquetado y que la comunidad Flutter/Dart usa de forma idiomática.
- Al combinar con `freezed` sealed, `AppFailure` produce un `when`/`map` exhaustivo que el compilador verifica.

**Por qué 5 variantes y no 1 (`Failure(String message)`):**

El código tiene que decidir cosas distintas por cada tipo de error:

- `network`: mostrar botón de retry, ofrecer modo offline.
- `cache`: reintentar leyendo de red.
- `validation`: destacar el campo específico (`field`) en el formulario.
- `auth`: redirigir a login.
- `unknown`: reportar a Crashlytics/AppLogger y mostrar mensaje genérico.

Con un solo tipo, la UI tendría que parsear strings. Con la unión, el `when` expresa la intención:

```dart
failure.when(
  network:    (m, _) => SnackBar('Network error: $m'),
  cache:      (m)    => SnackBar('Cache error'),
  validation: (f, r) => highlightField(f, r),
  auth:       (_)    => context.go('/login'),
  unknown:    (c, _) => reportToCrashlytics(c),
);
```

**Dónde se instancia cada una:**

`UserArticleRepositoryImpl._guard` es la ÚNICA función que atrapa `FirebaseException`. Mapea:

| Código de Firebase                         | Variante de `AppFailure`           |
|-------------------------------------------|------------------------------------|
| `permission-denied`, `unauthenticated`    | `AuthFailure`                      |
| `unavailable`, `deadline-exceeded`, `aborted` | `NetworkFailure`               |
| `not-found`                               | `ValidationFailure(field: 'id')`  |
| cualquier otro                            | `UnknownFailure(cause: e)`         |

Los use cases añaden `ValidationFailure` ANTES de llamar al repo (validación cliente de los mismos límites que enforcea `firestore.rules#isValidArticle`). Esto cierra el bucle: si el servidor rechaza, la UI muestra exactamente el mismo mensaje que habría mostrado sin pedir permiso.

---

## 5. D6 — Bootstrap separado y handlers globales de error

**Decisión:** `main.dart` es solo el punto de entrada; toda la inicialización vive en `bootstrap.dart`; la construcción del árbol Widget vive en `app.dart`.

```dart
// main.dart (≤ 10 líneas, criterio de salida de F2)
import 'package:news_app_clean_architecture/bootstrap.dart';
void main() => bootstrap();
```

```dart
// bootstrap.dart — responsabilidades:
//   1. Bind engine (WidgetsFlutterBinding).
//   2. Registrar handlers globales (FlutterError.onError + PlatformDispatcher + runZonedGuarded).
//   3. (Cuando F0 esté desbloqueado) Firebase.initializeApp.
//   4. initializeDependencies() para DI.
//   5. runApp(MyApp).
```

**Por qué:** cumple **R1** (Firebase init aislado), **D12** (handlers globales) y **D10** (providers extraídos) de [03_ANALISIS_ARQUITECTURA.md](../prueba-tecnica/03_ANALISIS_ARQUITECTURA.md). Un `main` gigante mezcla inicialización con construcción de UI y hace que cada vez que cambie el DI haya que re-leer la vida entera de la app.

**Trade-off aceptado:** `Firebase.initializeApp` sigue comentada con `TODO(F0)` porque la prueba técnica se realizó sin proyecto Firebase configurable. Ver §12 para cómo se mitigó.

---

## 6. D7 — Design tokens + ThemeExtension

**Decisión:** los estilos viven en 4 archivos de tokens (`app_colors`, `app_spacing`, `app_radii`, `app_typography`) que alimentan una clase `AppTheme extends ThemeExtension<AppTheme>`. Los widgets consumen `context.appTheme.spacing.lg` en vez de constantes *hard-coded*.

```dart
// config/theme/app_theme_extension.dart
factory AppTheme.light() => AppTheme(
  surface:   AppColors.neutral0,
  onSurface: AppColors.neutral900,
  primary:   AppColors.brandPrimary,
  ...
  spacing:   AppSpacingTokens(),
  radii:     AppRadiiTokens(),
);
factory AppTheme.dark() => AppTheme(
  surface:   AppColors.neutral900,
  onSurface: AppColors.neutral0,
  ...
);
```

**Por qué ThemeExtension y no un `InheritedWidget` propio:**

- `ThemeData.extensions` está integrado con el framework. `Theme.of(context).extension<AppTheme>()` funciona sin configuraciones adicionales.
- Permite `lerp()` entre `AppTheme.light()` y `AppTheme.dark()` gratis (animaciones al cambiar de tema).
- Testing: `MaterialApp(theme: lightTheme())` en un `pumpWidget` expone el tema a través de `context.appTheme` igual que en producción.

**Por qué tokens separados en clases vs. extension methods sobre `ThemeData`:**

Los tokens **numéricos** (spacing, radii) no tienen lugar natural en `ThemeData`. Meterlos en la extension los agrupa semánticamente: `theme.spacing.lg` tiene una intención que `16.0` no tiene.

**Cobertura del overdelivery:** corresponde al punto **#21** del análisis arquitectónico (design tokens). Es uno de los dos overdelivery oficiales declarados en el plan.

---

## 7. D8 — Router declarativo con `go_router`

**Decisión:** `MaterialApp.onGenerateRoute` fuera, `MaterialApp.router(routerConfig: appRouter)` dentro. Las rutas de `user_articles` se declaran nested bajo `/me/articles`:

```dart
GoRoute(
  path: AppRoutes.myArticles(),                           // /me/articles
  routes: [
    GoRoute(path: 'new',  builder: ...),                  // /me/articles/new
    GoRoute(
      path: ':id',        builder: ...,                    // /me/articles/:id
      routes: [
        GoRoute(path: 'edit', builder: ...),              // /me/articles/:id/edit
      ],
    ),
  ],
),
```

**Por qué `go_router` y no `auto_route`/`beamer`:**

- Es el router oficial recomendado por el equipo de Flutter desde 2023.
- No requiere generación de código (compatible con el corredor de compatibilidad de ADR-0002, que fuerza a minimizar el código generado).
- Soporte nativo a Navigator 2.0, deep links y `state.extra` tipado.

**Helpers tipados:** `AppRoutes.articleEditorEdit(id)` en vez de `'/me/articles/$id/edit'`. Si mañana la ruta cambia, un solo archivo se toca.

**Cobertura del overdelivery:** corresponde al punto **#15** del análisis. Es el segundo overdelivery oficial.

---

## 8. D9 — `freezed` + `json_serializable`

**Decisión:** todo DTO, entidad y estado que deba comparar por valor o serializarse usa `freezed`. Los modelos que se serializan a JSON añaden `json_serializable`. La excepción es `UserArticleModel` (solo `Firestore`, no JSON puro) que se deja como clase plana por la razón explicada en §9.

**Por qué `freezed`:**

- Reemplaza `Equatable` (manual) con `==`/`hashCode` autogenerados consistentes.
- Unions selladas: `@freezed sealed class State { ... }` hace que `switch` en Dart 3 sea exhaustivo.
- `copyWith` gratis con el tipo correcto.

**Limitación aceptada:** se usa `freezed ^2.4.7` en vez de `freezed 3.x` por el corredor de compatibilidad de ADR-0002. 2.4 no soporta la palabra `sealed` del propio freezed, pero Dart 3 ya ofrece `sealed` como keyword del lenguaje y cubre el mismo caso.

---

## 9. D10 — Esquema, reglas y paths

**Decisión:** el contrato entre frontend y backend se congela en [`backend/docs/DB_SCHEMA.md`](../../backend/docs/DB_SCHEMA.md) **antes** de escribir el data layer. Las reglas de Firestore y Storage refieren explícitamente a los mismos campos y rangos.

| Entidad / Campo                             | Validación en reglas (backend)                          | Validación cliente (use case)                     |
|---------------------------------------------|----------------------------------------------------------|---------------------------------------------------|
| `title`                                     | `size() in [5..120]`                                    | `params.title.length in [5..120]`                 |
| `description`                               | `size() <= 280`                                          | `params.description.length <= 280`                |
| `content`                                   | `size() in [50..20000]`                                 | `params.content.length in [50..20000]`            |
| `thumbnailURL`                              | `matches('https://.*')`                                  | `params.thumbnailURL.isNotEmpty`                  |
| `status`                                    | `in ['draft','published']`                               | enum `UserArticleStatus`                          |
| `tags`                                      | `is list && size() <= 5`                                | `params.tags.length <= 5`                         |
| `authorId` == `request.auth.uid`            | rules                                                    | inyectado desde `AuthSession.currentUser`          |
| `data.id` == `articleId`                    | rules                                                    | id generado client-side (§13)                     |
| `publishedAt`/`updatedAt` == `request.time` | rules                                                    | escritas con `FieldValue.serverTimestamp()`        |

**Por qué doble validación (cliente + servidor):**

- **Cliente:** UX rápida. El botón "Publish" se deshabilita antes de la llamada si los campos no cumplen. Un `ValidationFailure(field: 'title', reason: 'must be between 5 and 120 chars')` aparece como SnackBar antes de gastar un round-trip.
- **Servidor:** seguridad. Un cliente manipulado o desactualizado no puede saltarse las reglas.

**Path de Storage con `{authorId}/{articleId}`:**

Esta elección no es decorativa. Al incluir `{authorId}` en el path, la regla de Storage colapsa a una sola predicate: `request.auth.uid == authorId`. Si el path fuera `media/articles/{articleId}`, la regla necesitaría leer Firestore para verificar el propietario — lo cual es caro y requiere un `get()` cross-service.

**Cobertura en el checklist:** secciones B, C y J.

---

## 10. D11 — Fake repository en `data/fake/`

**Decisión:** F6 introduce `FakeUserArticleRepository` que implementa `UserArticleRepository` y vive en `lib/features/user_articles/data/fake/`. Persiste en un `Map<String, UserArticleEntity>` in-memory.

**Por qué no inyectarlo solo en tests:**

F7 (presentation) no podía depender de Firestore real porque F0 está bloqueado (sin `flutterfire configure`). Dos caminos:

- **A.** Esperar a F8 para enchufar Firestore y entonces ver la UI funcionando end-to-end.
- **B.** Introducir el fake en F6 y tener F7 corriendo con datos reales-pero-in-memory.

Se eligió **B** porque el plan ordena las fases en un crítico serial (F7 → F8) y romper el sub-plan tiene costo. Además, el fake se mantiene en el árbol después de F8 y se usa como "modo demo" cuando Firebase no está inicializado (ver §12).

**Invariante:** el fake vive en `data/fake/` (no en `data/repository/`) para dejar claro desde el nombre de la carpeta que NO es el impl productivo. El impl real es `data/repository/user_article_repository_impl.dart`.

---

## 11. D12 — Ports con stubs: `AuthSession` y `ThumbnailPickerService`

**Decisión:** dos piezas que en producción son "Firebase Auth" y "image_picker" se abstraen como interfaces en el proyecto, con stubs en dev y la conexión real pendiente de wiring en F0/F10.

```dart
// core/session/auth_session.dart
abstract class AuthSession {
  AuthUser? get currentUser;
}
class DevAuthSession implements AuthSession { ... }
```

```dart
// features/user_articles/presentation/services/thumbnail_picker_service.dart
abstract class ThumbnailPickerService {
  Future<PickedThumbnail?> pickImage();
}
class StubThumbnailPickerService implements ThumbnailPickerService { ... }
```

**Por qué:**

1. **Testing.** `ArticleEditorPage` tests no pueden pedir permisos de galería. Con el stub, `pumpWidget` corre sin intervención humana.
2. **Aislamiento de dependencia.** El bloc y la UI no importan `firebase_auth` ni `image_picker` en F7. Al agregarlas en F8/F10, solo cambia el wiring en `injection_container.dart` — no el código de features.
3. **Capa `core/` vs. `features/`.** `AuthSession` vive en `core/session/` porque múltiples features lo usarán. `ThumbnailPickerService` vive en `features/user_articles/presentation/services/` porque es específico de este flujo. Es un corte correcto: generalizar antes de que haya dos features probablemente sería YAGNI.

---

## 12. D13 — DI condicional: `Firebase.apps.isNotEmpty`

**Decisión:** `injection_container.dart` detecta en runtime si Firebase está inicializado y registra `UserArticleRepositoryImpl` (Firestore/Storage reales) o `FakeUserArticleRepository` (in-memory) según corresponda.

```dart
if (Firebase.apps.isNotEmpty) {
  sl
    ..registerSingleton<UserArticlesFirestoreDataSource>(
        UserArticlesFirestoreDataSource(FirebaseFirestore.instance))
    ..registerSingleton<UserArticlesStorageDataSource>(
        UserArticlesStorageDataSource(FirebaseStorage.instance))
    ..registerSingleton<UserArticleRepository>(
        UserArticleRepositoryImpl(sl(), sl()));
} else {
  sl.registerSingleton<UserArticleRepository>(FakeUserArticleRepository());
}
```

**Por qué en runtime y no vía flag de compilación (`--dart-define=USE_FIREBASE=true`):**

- Una variable de compilación implica dos builds distintos para demo y producción. El fallback runtime es una única build que hace lo correcto sin intervención.
- En tests, `Firebase.apps` siempre está vacío → la suite usa el fake automáticamente, sin mocks.
- En desarrollo local sin credenciales → el fake se activa, la app arranca, el flujo end-to-end es navegable.
- En producción (una vez F0 desbloquee) → basta con descomentar `Firebase.initializeApp` en `bootstrap.dart`. No se toca ninguna otra línea.

**Trade-off:** un desarrollador leyendo `injection_container.dart` podría confundirse sobre qué binding está activo. **Mitigación:** el comentario del método explica el gate y apunta a este ADR.

---

## 13. D14 — Article id generado client-side

**Decisión:** el bloc editor genera el id del artículo en `_onSubmitted()` antes de llamar al upload y lo propaga a `PublishArticleParams.id` y a `UploadThumbnailParams.articleId`.

```dart
final articleId = state.editingId ?? _generateArticleId();
// ... upload usa articleId
// ... publish params usa articleId
String _generateArticleId() =>
    'a_${DateTime.now().microsecondsSinceEpoch}';
```

**Por qué generar client-side:**

Las reglas del backend imponen dos restricciones que solo se resuelven si el cliente conoce el id antes del primer write:

- `firestore.rules#isValidArticle`: `request.resource.data.id == articleId` (el campo `id` del documento debe igualar el `documentId` de Firestore).
- `storage.rules`: el thumbnail se sube a `media/articles/{authorId}/{articleId}/{file}` — necesita el `{articleId}` antes de cualquier write.

Si se generara server-side (por ejemplo en un Cloud Function), la UI tendría que:

1. Subir un placeholder a un path temporal.
2. Llamar al function → recibir el id.
3. Mover el archivo al path definitivo.

Tres round-trips en vez de uno.

**Por qué `microsecondsSinceEpoch` y no un uuid:**

- Dart stdlib no incluye uuid. Agregar `package:uuid` solo para esto añade una dependencia transitiva.
- Colisiones: el id es único por microsegundo por cliente → probabilidad de colisión en una sesión de usuario individual es efectivamente cero. Firestore solo requiere unicidad dentro de la colección, no global.
- Si F10 migra a uuids reales, el cambio se contiene en el helper `_generateArticleId()`.

**Nota de diseño:** este detalle se descubrió durante F8 al ejecutar la suite de tests contra `fake_cloud_firestore` y ver que el `state.editingId ?? 'new'` original colisionaba entre artículos. Se refactorizó en el commit `4a48ebb` (`refactor(user_articles): thread article id through publish params`).

---

## 14. Criterios arquitectónicos verificados

Greps que pasaron 0 matches al cierre de F9 (verificables vía la herramienta `grep` en el repo):

| Check                                                                          | Resultado |
|--------------------------------------------------------------------------------|-----------|
| `domain/` importa `flutter`, `firebase_*`, `dio`, `floor`, `cloud_firestore`   | vacío     |
| `presentation/` importa `firebase_*`, `dio`, `floor`, `cloud_firestore`        | vacío     |
| `presentation/` importa `features/*/data/`                                     | vacío     |
| `DioError` o `DataState` residuales en `lib/`                                  | vacío     |

Esto cierra las violaciones 1.x, 2.x y 3.x de [`ARCHITECTURE_VIOLATIONS.md`](../ARCHITECTURE_VIOLATIONS.md).

---

## 15. Lo que este ADR **no** intenta resolver

Para evitar sobreingeniería declarada, las siguientes áreas quedan fuera de alcance:

- **Crashlytics / Performance Monitoring.** El hook está listo (`AppLogger.report` centraliza errores); falta suscribir Crashlytics, y requiere F0 desbloqueado.
- **Offline-first explícito.** `cloud_firestore` trae persistencia local activada por defecto. No se cablea un `floor` mirror porque duplicaría esfuerzo sin agregar casos de uso actuales.
- **Internacionalización.** Todos los strings están en inglés en el código. No se añade `intl`/ARB porque la prueba no lo pide y habría inflado el alcance.
- **Modularización con melos.** Una sola feature nueva no justifica el costo de melos; se recomienda revisar cuando la segunda feature aterrice.
- **Widget tests exhaustivos.** La cobertura está en bloc_test (lógica) + un widget test representativo (`PrimaryButton`). Ampliarla a todas las páginas requiere imagen binaria para el thumbnail picker y pruebas de golden images — fuera del presupuesto de 72 h.

---

## 16. Cuando este ADR debe actualizarse

Este documento es de "sólo lectura" hasta que alguna de estas cosas ocurra:

1. **F0 desbloquea Firebase real.** Entonces: tachar el `TODO(F0)` en `bootstrap.dart`, actualizar este ADR §12 con el estado final, y añadir `ADR-0004 — Wiring de Firebase productivo` si hay decisiones nuevas (p. ej. sobre modo offline).
2. **Se elimina `floor` de `daily_news`** (F10/futuro). Entonces se libera el corredor de ADR-0002 y hay que revisar tanto ADR-0002 como §8 de este documento (freezed/analyzer bands).
3. **Se agrega autenticación real** (Firebase Auth UI, login, etc.). Entonces actualizar §11 (ports) porque el `DevAuthSession` se retira.

Cualquier cambio mayor debe llegar como un ADR nuevo que **supersede** la sección correspondiente aquí, no como una edición silenciosa. Este documento es histórico: describe la versión del código que ingresó al PR.

---

## 17. Referencias

- [ADR-0001 — lints + info budget](./0001-lint-migration-and-info-debt-budget.md)
- [ADR-0002 — version bands](./0002-dependency-version-bands.md)
- [Plan maestro (10 fases, 56 batches)](../prueba-tecnica/01_PLAN_FASES.md)
- [Checklist de validación](../prueba-tecnica/02_CHECKLIST.md)
- [Análisis arquitectónico inicial (R1–R10, D2–D15, #14, #15, #21)](../prueba-tecnica/03_ANALISIS_ARQUITECTURA.md)
- [Arquitectura oficial Symmetry](../APP_ARCHITECTURE.md)
- [Violaciones arquitectónicas prohibidas](../ARCHITECTURE_VIOLATIONS.md)
- [DB schema del backend](../../backend/docs/DB_SCHEMA.md)
- [Report técnico de entrega](../REPORT.md)
- [Solución técnica detallada](../SOLUCION.md)
- [Checklist manual pre-PR](../PRE_PR_MANUAL.md)
