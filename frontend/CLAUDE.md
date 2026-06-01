# CLAUDE.md — TortuTip

Este archivo define las reglas del proyecto.
Lee todo antes de escribir cualquier línea de código.
Estas reglas no son sugerencias — son requisitos.

---

## Índice

1. [Stack](#stack)
2. [Arquitectura](#arquitectura)
3. [Sistema de diseño](#sistema-de-diseño)
4. [Navegación](#navegación)
5. [Inyección de dependencias](#inyección-de-dependencias)
6. [Firestore — Schema](#firestore--schema)
7. [Testing](#testing)
8. [Convenciones de código](#convenciones-de-código)
9. [Git](#git)
10. [Checklist obligatorio](#checklist-obligatorio)

---

## Stack
- Flutter + Dart
- Firebase (Auth, Firestore, Storage)
- flutter_bloc (Blocs y Cubits)
- get_it (inyección de dependencias)
- go_router (navegación)

---

## Arquitectura

### Estructura de carpetas

```
lib/
├── config/
│   ├── routes/        ← navegación
│   └── theme/         ← sistema de diseño
├── core/
│   ├── resources/     ← DataState<T>
│   └── usecase/       ← contrato UseCase<Output, Params>
├── injection/         ← DI con get_it (un archivo por feature)
├── shared/
│   ├── user/          ← entidad y repositorio compartido
│   └── widgets/       ← widgets reutilizables
└── features/
    └── {feature}/
        ├── config/            ← *_routes.dart
        ├── domain/
        │   ├── entities/
        │   ├── repository/    ← abstract class
        │   └── use_cases/
        ├── data/
        │   ├── data_sources/
        │   ├── models/
        │   └── repository/    ← *_repository_impl.dart
        └── presentation/
            ├── bloc/
            ├── screens/
            └── widgets/
```

### Principios SOLID

- **S** — Single Responsibility: cada clase tiene una única razón para cambiar.
  UseCase = una operación. Widget = una responsabilidad visual. DataSource = un origen de datos.
- **O** — Open/Closed: extiende comportamiento via abstract classes y nuevas implementaciones,
  nunca modificando clases existentes.
- **L** — Liskov Substitution: cualquier implementación de un Repository o UseCase
  debe poder sustituir a su interface sin romper el sistema.
- **I** — Interface Segregation: los Repository interfaces definen solo los métodos
  que sus use_cases realmente necesitan — sin métodos innecesarios.
- **D** — Dependency Inversion: presentation y data dependen de abstracciones (domain),
  nunca de implementaciones concretas.

### Reglas de capas — NUNCA violar

```
domain/       → cero imports del proyecto (Dart puro)
data/         → solo importa domain/ y Firebase
presentation/ → solo importa domain/ (use_cases)
```

- Los `blocs/cubits` son el ÚNICO lugar que importa `use_cases`
- Los `data_sources` son el ÚNICO lugar que importa Firebase
- Los `repository` interfaces son `abstract class` — cero implementación
- Los `models` siempre extienden una `Entity` y tienen `fromRawData()` — `toEntity()`, el model ya es una entity por herencia
- Los `repository impl` siempre retornan `DataState<T>` — nunca `void`, nunca models
- Los `blocs` nunca importan `RepositoryImpl` ni `DataSource` — solo `UseCase`

### DataState — contrato obligatorio

```dart
abstract class DataState<T> extends Equatable {
  final T? data;
  final Exception? error;

  const DataState({this.data, this.error});

  bool get isSuccess => this is DataSuccess<T>;
  bool get isFailure => this is DataFailed<T>;

  @override
  List<Object?> get props => [data, error];
}

class DataSuccess<T> extends DataState<T> {
  const DataSuccess(T data) : super(data: data);
}

class DataFailed<T> extends DataState<T> {
  const DataFailed(Exception error) : super(error: error);
}
```

**Reglas:**
- `DataSuccess` nunca tiene `data` null — si no hay datos retorna `DataSuccess([])` o `DataSuccess(false)`
- `DataFailed` nunca tiene `error` null
- Siempre se comprueba `result.isSuccess` primero — nunca `result.data != null` directamente

### UseCase — contrato obligatorio

```dart
abstract class UseCase<Output, Params> {
  Future<Output> call(Params params);
}

// Para use_cases sin parámetros
class NoParams extends Equatable {
  const NoParams();
  @override
  List<Object?> get props => [];
}
```

**Reglas:**
- El método es siempre `call()` — permite invocar el use_case como función: `await _useCase(params)`
- `Output` es siempre `DataState<T>` — nunca un tipo raw
- `Params` es siempre una clase dedicada o `NoParams` — nunca primitivos sueltos

### CheckAuthUseCase — regla explícita

`AuthBloc` nunca inyecta `AuthRepository` directamente.
La verificación de sesión activa vive en `CheckAuthUseCase`.
El bloc solo recibe use_cases — nunca repositories ni data_sources.

### Estados de Blocs/Cubits — convención obligatoria

Todo Bloc o Cubit debe tener como mínimo estos 4 estados:

```dart
abstract class {Feature}State {}

class {Feature}Initial  extends {Feature}State {}  // estado inicial, pantalla vacía
class {Feature}Loading  extends {Feature}State {}  // operación en curso, muestra spinner
class {Feature}Loaded   extends {Feature}State { final T data; }  // éxito, muestra datos
class {Feature}Error    extends {Feature}State { final String message; }  // error recuperable
```

**Reglas:**
- `Initial` — siempre el estado del constructor: `super({Feature}Initial())`
- `Loading` — siempre se emite ANTES de llamar al UseCase
- `Loaded` — solo se emite si `result.isSuccess`
- `Error` — siempre incluye un mensaje legible para el usuario, nunca un stack trace

**Estados adicionales permitidos** cuando el flujo lo requiere:
```dart
class {Feature}Empty      extends {Feature}State {}  // éxito pero sin datos
class {Feature}Submitting extends {Feature}State {}  // para formularios — distinto de Loading
class {Feature}Submitted  extends {Feature}State {}  // formulario enviado con éxito
```

**Lo que NUNCA hacer:**
```dart
// ❌ Estado sin mensaje de error
class FeedError extends FeedState {}  // ¿qué le dices al usuario?

// ❌ Emitir Loaded con data nullable
class FeedLoaded extends FeedState { final List<Article>? articles; }

// ❌ Saltarse el estado Loading
Future<void> loadFeed() async {
  // sin emit(FeedLoading()) — la UI no sabe que está cargando
  final result = await _useCase(params);
}

// ❌ Un único estado con flags booleanos
class FeedState {
  final bool isLoading;
  final bool hasError;  // esto es un ViewModel de iOS, no un Bloc state
}
```

### Estrategia de errores end-to-end

Un error sigue este camino exacto desde Firebase hasta la UI:

```
Firebase lanza Exception
↓
DataSource        — deja que la excepción suba (no la captura)
↓
RepositoryImpl    — captura con try/catch → retorna DataFailed(exception)
↓
UseCase           — no maneja errores, retorna el DataState tal cual
↓
Bloc/Cubit        — comprueba isSuccess/isFailure → emite estado de error con mensaje legible
↓
Screen            — muestra SnackBar o estado de error en UI
```

**Tipos de excepción por capa:**

```dart
// DataSource — lanza excepciones específicas
throw FirebaseException(plugin: 'firestore', message: 'Not found');
throw Exception('Google Sign In cancelled');

// RepositoryImpl — captura y envuelve
} catch (e) {
  return DataFailed(e is Exception ? e : Exception(e.toString()));
}

// Bloc/Cubit — comprueba isSuccess, luego traduce a mensaje de usuario
if (result.isSuccess) {
  emit(FeedLoaded(result.data!));
} else {
  emit(FeedError(_mapErrorToMessage(result.error!)));
}

String _mapErrorToMessage(Exception error) {
  if (error is FirebaseException) {
    return switch (error.code) {
      'permission-denied' => 'No tienes permiso para realizar esta acción',
      'not-found'         => 'El contenido no existe',
      'unavailable'       => 'Sin conexión. Inténtalo de nuevo',
      _                   => 'Algo salió mal. Inténtalo de nuevo',
    };
  }
  return 'Algo salió mal. Inténtalo de nuevo';
}
```

**Reglas:**
- El mensaje de error que ve el usuario nunca contiene términos técnicos
- Cada Bloc/Cubit tiene su propio `_mapErrorToMessage()` — no hay un mapper global
- Los errores de cancelación del usuario (Google Sign In cancelled) no son errores — son `AuthInitial`
- Errores de red muestran opción de reintentar — el estado `Error` incluye la acción que falló

### Nombres de archivos y clases

```
Entidades:          article_entity.dart            → ArticleEntity
Models:             article_model.dart             → ArticleModel extends ArticleEntity
Repository iface:   article_repository.dart        → abstract class ArticleRepository
Repository impl:    article_repository_impl.dart   → ArticleRepositoryImpl implements ArticleRepository
Use case:           publish_article_use_case.dart  → PublishArticleUseCase
Data source:        article_remote_data_source.dart → ArticleRemoteDataSource (abstract) + Impl
Bloc:               feed_bloc.dart / feed_cubit.dart
State:              feed_state.dart
Event:              feed_event.dart
Screen:             feed_screen.dart               → FeedScreen
Widget:             article_card.dart              → ArticleCard
Routes:             articles_routes.dart           → ArticlesRoutes
Injection:          articles_injection.dart        → initArticlesDependencies()
```

---

## Sistema de diseño

### Archivos de tokens

```
lib/config/theme/
  app_colors.dart       ← ÚNICA fuente de colores
  app_typography.dart   ← ÚNICA fuente de estilos de texto
  app_spacing.dart      ← ÚNICA fuente de espaciados y radios
  app_decorations.dart  ← BoxDecorations reutilizables
  app_theme.dart        ← ThemeData
```

### Reglas de diseño — NUNCA violar

```dart
// ❌ MAL — nunca hardcodear
color: Color(0xFF4A7C3F)
fontSize: 16
padding: EdgeInsets.all(24)
borderRadius: BorderRadius.circular(14)

// ✅ BIEN — siempre usar tokens
color: AppColors.primary
style: AppTypography.body
padding: EdgeInsets.all(AppSpacing.xxl)
borderRadius: BorderRadius.circular(AppSpacing.radiusLg)
```

### Widgets compartidos

```
lib/shared/widgets/
  tortutip_button.dart        → TortuPrimaryButton, TortuSecondaryButton, TortuGoogleButton
  tortutip_chip.dart          → TortuCategoryChip, TortuOutlineChip
  tortutip_card.dart          → TortuArticleCard, TortuProfileCard
  tortutip_app_bar.dart       → TortuAppBar, TortuAppBar.main(), TortuAppBar.detail()
  tortutip_progress_dots.dart → TortuProgressDots
  tortutip_quote_block.dart   → TortuQuoteBlock
  tortutip_input.dart         → TortuTextField
```

- Antes de crear un widget nuevo, verifica si ya existe en `shared/widgets/`
- Si un widget se usa en más de una pantalla, vive en `shared/widgets/`
- Si un widget es específico de una pantalla, vive en `features/{feature}/presentation/widgets/`

---

## Navegación

### Archivos

```
lib/config/routes/
  app_routes.dart       ← constantes de rutas (AppRoutes.feed, etc.)
  app_router.dart       ← orquestador, solo ensambla *Routes.routes
  app_shell.dart        ← único propietario de la TabBar
  tortutip_tab_bar.dart ← widget visual de la TabBar

lib/features/{feature}/config/
  {feature}_routes.dart ← rutas del feature
```

### Rutas actuales

```
/landing                   → LandingScreen
/login                     → LoginScreen
/onboarding/categories     → OnboardingCategoriesScreen
/onboarding/role           → OnboardingRoleScreen
/onboarding/details        → OnboardingDetailsScreen
/feed                      → FeedScreen           (TabBar visible)
/feed/:articleId           → ArticleDetailScreen  (sin TabBar)
/create                    → CreateArticleScreen  (sin TabBar, modal)
/explore                   → ExploreScreen        (TabBar visible)
/explore/edit              → EditProfileScreen    (sin TabBar)
```

### Reglas de navegación

```dart
context.go()    // reemplaza el stack — entre tabs, tras login, tras onboarding
context.push()  // apila — detalle de artículo, editar perfil, modal crear
context.pop()   // vuelve atrás — back arrow, X del modal
```

- La TabBar vive SOLO en `AppShell` — ninguna pantalla la incluye
- `CreateArticleScreen` se abre con `context.push()` — es un modal, no un tab
- Añadir un feature nuevo = crear `{feature}_routes.dart` + una línea en `app_router.dart`

### ShellRoute — regla obligatoria

Existe UN ÚNICO ShellRoute en todo el proyecto.
Vive exclusivamente en `app_router.dart`.
Ningún `*_routes.dart` de feature puede instanciar un ShellRoute.

```dart
// ✅ CORRECTO — un único ShellRoute en app_router.dart
ShellRoute(
  builder: (_, __, child) => AppShell(child: child),
  routes: [
    ...ArticlesRoutes.shellRoutes,  // solo las rutas, sin ShellRoute
    ...ProfileRoutes.shellRoutes,   // solo las rutas, sin ShellRoute
  ],
),

// ❌ MAL — ShellRoute dentro de un *_routes.dart
class ArticlesRoutes {
  static final routes = <RouteBase>[
    ShellRoute(  // NUNCA — rompe el estado del shell entre tabs
      builder: (_, __, child) => AppShell(child: child),
      ...
    ),
  ];
}
```

**Por qué:**
Dos ShellRoute separados destruyen y recrean AppShell al navegar entre `/feed` y `/explore`
con `context.go()`. Esto pierde el estado de scroll y cualquier estado local de la pantalla.
Un único ShellRoute mantiene AppShell vivo durante toda la sesión.

**Convención para los `*_routes.dart` de features con tabs:**
Exponen dos listas separadas — `routes` para rutas fuera del shell y `shellRoutes` para rutas dentro del shell:

```dart
class ArticlesRoutes {
  // Fuera del shell — sin TabBar
  static final routes = <RouteBase>[
    GoRoute(path: AppRoutes.create, builder: ...),
  ];

  // Dentro del shell — con TabBar
  static final shellRoutes = <RouteBase>[
    GoRoute(
      path: AppRoutes.feed,
      routes: [
        GoRoute(path: ':articleId', builder: ...),
      ],
    ),
  ];
}
```

### Guard de autenticación

El redirect vive exclusivamente en `app_router.dart` → método `_redirect`.
Nadie más toma decisiones de navegación basadas en auth.

**Fuente de verdad: `AuthBloc`**
El router escucha el stream de `AuthBloc` via `_AuthNotifier`.
Cada vez que `AuthBloc` emite un nuevo estado, el router reevalúa el redirect.

**Lógica de decisión:**

```dart
// No autenticado → landing
if (!isAuthenticated && !isOnLanding && !isOnLogin && !isOnboarding)
  → AppRoutes.landing

// Autenticado en login o landing → onboarding o feed
if (isAuthenticated && (isOnLogin || isOnLanding))
  → user.role.isEmpty ? AppRoutes.onboardingCategories : AppRoutes.feed

// Autenticado pero sin completar onboarding
if (isAuthenticated && !isOnboarding)
  → user.role.isEmpty ? AppRoutes.onboardingCategories : null
```

**Estados de `AuthBloc` y qué implican:**

| Estado | Significado | Redirect |
|---|---|---|
| `AuthInitial` | Sin sesión activa | → `/landing` |
| `AuthLoading` | Verificando sesión | ninguno — espera |
| `AuthAuthenticated(user)` | Sesión activa | depende de `user.role` |
| `AuthError` | Fallo de auth | → `/login` |

**Lo que NUNCA hacer:**
```dart
// ❌ Navegar desde una Screen según el estado de auth
if (state is AuthAuthenticated) context.go(AppRoutes.feed);

// ❌ Lógica de redirect fuera de app_router.dart
// ❌ Leer FirebaseAuth.instance directamente en una Screen
```

---

## Inyección de dependencias

### Archivos

```
lib/injection/
  injection_container.dart   ← orquestador (Firebase + llama a los demás)
  auth_injection.dart
  user_injection.dart
  categories_injection.dart
  articles_injection.dart
  profile_injection.dart
```

### Reglas

```dart
registerLazySingleton()  // DataSources, Repositories, UseCases
registerFactory()        // Blocs y Cubits — instancia nueva por pantalla
```

- Añadir use_case nuevo = registrarlo en el injection de su feature
- Añadir feature nuevo = crear `{feature}_injection.dart` + una línea en `injection_container.dart`
- Injection solo importa de `presentation/bloc/` — nunca de `screens/` ni `widgets/`

---

## Firestore — Schema

### Colecciones

```
users            → id, name, email, avatar_url, bio, role, gender, age_range, created_at
articles         → id, author_id, category_id, title, body, cover_vertical_url,
                   cover_horizontal_url, status, read_time_minutes, save_count,
                   published_at, created_at
categories       → id, name, description, icon_url
user_categories  → user_id, category_id  (ID compuesto: {userId}_{categoryId})
saved_articles   → user_id, article_id, saved_at
```

### Reglas

- `role` en users: solo `'reader'` o `'writer'`
- `status` en articles: solo `'draft'` o `'published'`
- `user_categories` usa ID determinista `${userId}_${categoryId}` — evita duplicados
- No añadir campos nuevos sin actualizar este archivo

---

## Testing

### Dependencias

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.0
  bloc_test: ^9.1.0
```

### Qué se testea obligatoriamente

| Capa | Qué | Por qué |
|---|---|---|
| `domain/use_cases` | Cada UseCase | Son el contrato de negocio |
| `presentation/bloc` | Cada Bloc/Cubit | Cada estado que puede emitir |
| `data/repository` | Cada RepositoryImpl | Verifica transformación DataSource → DataState |

### Qué NO se testea

- Entities y Models — son structs sin lógica
- DataSources — dependen de Firebase, fuera del scope del MVP
- Screens y Widgets — fuera del scope del MVP

### Estructura de archivos de test

Espejo exacto de `lib/`:

```
test/
├── shared/
│   └── user/
│       ├── domain/use_cases/
│       │   ├── get_current_user_use_case_test.dart
│       │   ├── update_user_role_use_case_test.dart
│       │   ├── select_user_categories_use_case_test.dart
│       │   └── update_user_profile_use_case_test.dart
│       └── data/repository/
│           └── user_repository_impl_test.dart
└── features/
    ├── auth/
    │   ├── domain/use_cases/
    │   │   ├── sign_in_with_google_use_case_test.dart
    │   │   └── sign_out_use_case_test.dart
    │   ├── data/repository/
    │   │   └── auth_repository_impl_test.dart
    │   └── presentation/bloc/
    │       └── auth_bloc_test.dart
    ├── onboarding/
    │   └── presentation/bloc/
    │       └── onboarding_cubit_test.dart
    ├── categories/
    │   ├── domain/use_cases/
    │   │   └── get_all_categories_use_case_test.dart
    │   ├── data/repository/
    │   │   └── category_repository_impl_test.dart
    │   └── presentation/bloc/
    │       └── category_cubit_test.dart
    ├── articles/
    │   ├── domain/use_cases/
    │   │   ├── get_feed_articles_use_case_test.dart
    │   │   ├── get_article_detail_use_case_test.dart
    │   │   ├── publish_article_use_case_test.dart
    │   │   ├── save_article_use_case_test.dart
    │   │   └── get_user_articles_use_case_test.dart
    │   ├── data/repository/
    │   │   └── article_repository_impl_test.dart
    │   └── presentation/bloc/
    │       ├── feed/
    │       │   └── feed_cubit_test.dart
    │       ├── article_detail/
    │       │   └── article_detail_cubit_test.dart
    │       └── create_article/
    │           └── create_article_cubit_test.dart
    └── profile/
        └── presentation/bloc/
            └── profile_cubit_test.dart
```

### Convenciones de test

- Un archivo de test por clase testeada
- Nombre del test: `should_{resultado}_when_{condicion}`
- Agrupa con `group()` por método o estado testeado
- Usa `mocktail` para mockear Repository interfaces
- Usa `bloc_test` para testear Blocs y Cubits
- El `setUp()` inicializa mocks y la clase bajo test
- Nunca compartas estado entre tests — cada test es independiente

### Plantillas

#### UseCase

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/articles/domain/repository/article_repository.dart';
import 'package:tortutip/features/articles/domain/use_cases/get_feed_articles_use_case.dart';

// Mock del repository interface — nunca del impl
class MockArticleRepository extends Mock implements ArticleRepository {}

void main() {
  late GetFeedArticlesUseCase useCase;
  late MockArticleRepository mockRepository;

  setUp(() {
    mockRepository = MockArticleRepository();
    useCase = GetFeedArticlesUseCase(mockRepository);
  });

  group('GetFeedArticlesUseCase', () {
    final categoryIds = ['cat_1', 'cat_2'];
    final articles = <ArticleEntity>[];

    test('should_return_articles_when_repository_succeeds', () async {
      // Arrange
      when(() => mockRepository.getFeedArticles(categoryIds))
          .thenAnswer((_) async => DataSuccess(articles));

      // Act
      final result = await useCase(categoryIds);

      // Assert
      expect(result, isA<DataSuccess<List<ArticleEntity>>>());
      expect(result.data, equals(articles));
      verify(() => mockRepository.getFeedArticles(categoryIds)).called(1);
    });

    test('should_return_failure_when_repository_throws', () async {
      // Arrange
      final exception = Exception('Firestore error');
      when(() => mockRepository.getFeedArticles(categoryIds))
          .thenAnswer((_) async => DataFailed(exception));

      // Act
      final result = await useCase(categoryIds);

      // Assert
      expect(result, isA<DataFailed<List<ArticleEntity>>>());
      expect(result.error, equals(exception));
    });
  });
}
```

#### Cubit

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/articles/domain/use_cases/get_feed_articles_use_case.dart';
import 'package:tortutip/features/articles/presentation/bloc/feed/feed_cubit.dart';
import 'package:tortutip/features/articles/presentation/bloc/feed/feed_state.dart';

class MockGetFeedArticlesUseCase extends Mock
    implements GetFeedArticlesUseCase {}

void main() {
  late FeedCubit cubit;
  late MockGetFeedArticlesUseCase mockGetFeedArticles;

  setUp(() {
    mockGetFeedArticles = MockGetFeedArticlesUseCase();
    cubit = FeedCubit(mockGetFeedArticles);
  });

  tearDown(() => cubit.close());

  group('FeedCubit', () {
    final categoryIds = ['cat_1'];
    final articles = <ArticleEntity>[];

    blocTest<FeedCubit, FeedState>(
      'should_emit_loading_then_loaded_when_feed_succeeds',
      build: () {
        when(() => mockGetFeedArticles(categoryIds))
            .thenAnswer((_) async => DataSuccess(articles));
        return cubit;
      },
      act: (c) => c.loadFeed(categoryIds),
      expect: () => [
        isA<FeedLoading>(),
        isA<FeedLoaded>(),
      ],
    );

    blocTest<FeedCubit, FeedState>(
      'should_emit_loading_then_error_when_feed_fails',
      build: () {
        when(() => mockGetFeedArticles(categoryIds))
            .thenAnswer((_) async => DataFailed(Exception('error')));
        return cubit;
      },
      act: (c) => c.loadFeed(categoryIds),
      expect: () => [
        isA<FeedLoading>(),
        isA<FeedError>(),
      ],
    );
  });
}
```

#### RepositoryImpl

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/articles/data/data_sources/article_remote_data_source.dart';
import 'package:tortutip/features/articles/data/models/article_model.dart';
import 'package:tortutip/features/articles/data/repository/article_repository_impl.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';

class MockArticleRemoteDataSource extends Mock
    implements ArticleRemoteDataSource {}

void main() {
  late ArticleRepositoryImpl repository;
  late MockArticleRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockArticleRemoteDataSource();
    repository = ArticleRepositoryImpl(mockDataSource);
  });

  group('ArticleRepositoryImpl.getFeedArticles', () {
    final categoryIds = ['cat_1'];
    final models = <ArticleModel>[];

    test('should_return_DataSuccess_with_entities_when_datasource_succeeds',
        () async {
      // Arrange
      when(() => mockDataSource.getFeedArticles(categoryIds))
          .thenAnswer((_) async => models);

      // Act
      final result = await repository.getFeedArticles(categoryIds);

      // Assert
      expect(result, isA<DataSuccess<List<ArticleEntity>>>());
    });

    test('should_return_DataFailed_when_datasource_throws', () async {
      // Arrange
      when(() => mockDataSource.getFeedArticles(categoryIds))
          .thenThrow(Exception('Firestore error'));

      // Act
      final result = await repository.getFeedArticles(categoryIds);

      // Assert
      expect(result, isA<DataFailed<List<ArticleEntity>>>());
    });
  });
}
```

### Tests como contrato — regla de oro

Los tests existentes son contratos firmados.
Antes de modificar cualquier clase testeada, ejecuta `flutter test`.

**Si un test falla tras un cambio:**
- No modifiques el test para que pase — entiende por qué falló
- Si el cambio es intencionado y correcto, actualiza el test y documenta el motivo en el commit
- Si el cambio rompe comportamiento esperado, revierte y replantea

**Lo que NUNCA hacer:**
```dart
// ❌ Saltarse el test porque "es solo un refactor"
// ❌ Comentar un test que falla para que el CI pase
// ❌ Cambiar el expected de un test sin entender por qué falló
// ❌ Entregar una tarea con flutter test en rojo
```

**Commits que tocan clases testeadas deben incluir:**
- El cambio en la clase
- El test actualizado o el test nuevo
- Nunca uno sin el otro

---

## Convenciones de código

### Dart / Flutter

- Usa `const` siempre que sea posible
- Prefiere `StatelessWidget` sobre `StatefulWidget` — usa Bloc para el estado
- Usa `super.key` y `super.{param}` en constructores
- Máximo 2 niveles de anidación en widgets — extrae métodos o widgets
- Un archivo = una clase pública principal
- Nombres en inglés — comentarios en inglés si son necesarios

### Comentarios

Añade comentario SOLO en estos casos:
- Lógica no obvia que no se explica sola con el nombre
- Workaround o fix de un bug externo (indica el motivo)
- Decisión de arquitectura que podría sorprender a otro desarrollador

Nunca comentar:
- Lo que ya dice el nombre de la variable, función o clase
- Imports
- Getters y setters simples
- Widgets de UI estándar

### Immutabilidad — Equatable

El proyecto usa `equatable: ^2.0.7`. No se usa `freezed`.

**Reglas:**
- Todas las `Entity` extienden `Equatable`
- Todos los `State` de Blocs/Cubits extienden `Equatable`
- Los `Params` de use_cases extienden `Equatable`
- Los `Model` heredan Equatable a través de su Entity

```dart
// ✅ Entity
class ArticleEntity extends Equatable {
  final String id;
  final String title;

  const ArticleEntity({required this.id, required this.title});

  @override
  List<Object?> get props => [id, title];
}

// ✅ State
class FeedLoaded extends FeedState {
  final List<ArticleEntity> articles;

  const FeedLoaded(this.articles);

  @override
  List<Object?> get props => [articles];
}

// ✅ Params
class PublishArticleParams extends Equatable {
  final String title;
  final String body;

  const PublishArticleParams({required this.title, required this.body});

  @override
  List<Object?> get props => [title, body];
}
```

**Lo que NUNCA hacer:**
```dart
// ❌ Entity sin Equatable — los tests de comparación fallarán
class ArticleEntity {
  final String id;
}

// ❌ State sin Equatable — bloc_test no puede comparar estados
class FeedLoaded extends FeedState {
  final List<ArticleEntity> articles;
}

// ❌ props incompleto — comparación parcial genera bugs difíciles de detectar
@override
List<Object?> get props => [id]; // falta title, body, etc.
```

### Manejo de errores

**Data layer — DataSource:**
- Lanza siempre excepciones tipadas, nunca códigos de error ni strings
- Usa try/catch solo en `RepositoryImpl` — nunca en `DataSource`

**Data layer — RepositoryImpl:**
- Envuelve toda llamada al DataSource en try/catch
- Retorna `DataSuccess(data)` si todo va bien
- Retorna `DataFailed(exception)` si hay error — nunca relanza la excepción

**Domain layer:**
- Nunca maneja errores — solo define contratos

**Presentation layer — Bloc/Cubit:**
- Comprueba siempre `result.isSuccess` antes de emitir estado de éxito
- Emite estado de error con mensaje legible para el usuario
- Nunca expone stack traces ni mensajes técnicos de Firebase a la UI

**UI — Screens:**
- Muestra errores via `SnackBar` para errores transitorios
- Muestra estado de error en pantalla para errores que bloquean el flujo
- Nunca muestra un error sin dar al usuario una acción para recuperarse

**Lo que NUNCA hacer:**
```dart
// ❌ Excepción silenciada
try { ... } catch (e) { }

// ❌ String de error hardcodeado en el Bloc
emit(FeedError('Error de Firestore: ${e.toString()}'));

// ❌ DataSource capturando su propia excepción
Future<ArticleModel> getArticle() async {
  try { ... } catch (e) { return ArticleModel.empty(); }
}
```

### Archivos

- snake_case para archivos: `article_detail_screen.dart`
- PascalCase para clases: `ArticleDetailScreen`
- Imports ordenados: dart → flutter → packages → proyecto (relativo)

### Lo que NUNCA hacer

```dart
// ❌ Color hardcodeado
Container(color: Color(0xFF5B8A3C))

// ❌ FontSize hardcodeado
Text('Hola', style: TextStyle(fontSize: 16))

// ❌ Padding hardcodeado
Padding(padding: EdgeInsets.all(24))

// ❌ Bloc importando Repository directamente
class FeedCubit {
  final ArticleRepositoryImpl _repo; // NUNCA
}

// ❌ Screen importando UseCase directamente
class FeedScreen {
  final GetFeedArticlesUseCase _useCase; // NUNCA — va en el Cubit
}

// ❌ DataSource sin Firebase
class ArticleRemoteDataSourceImpl {
  // si no importa Firebase, no es un DataSource
}

// ❌ Model retornado por Repository interface
abstract class ArticleRepository {
  Future<ArticleModel> getArticle(); // NUNCA — debe retornar ArticleEntity
}
```

---

## Git

### Ramas

```
main
└── develop
    ├── feature/{nombre}   → nueva funcionalidad
    ├── bugfix/{nombre}    → corrección de bug
    └── chore/{nombre}     → deuda técnica, limpieza
```

### Commits

```
feat(auth): implement login with Google
fix(user): resolve user-categories duplicates
chore(deps): remove unused dartz dependency
refactor(articles): extract article card to shared widgets
```

---

## Checklist obligatorio

### Antes de crear cualquier archivo

1. ¿Ya existe un widget similar en `shared/widgets/`? → úsalo
2. ¿El color/tamaño/espaciado está en los tokens? → usa el token
3. ¿La ruta ya está en `app_routes.dart`? → úsala
4. ¿El use_case ya está registrado en el injection? → compruébalo
5. ¿La capa es correcta? → domain no importa data, presentation no importa data

### Antes de entregar cualquier tarea

```bash
flutter test          # cero fallos
flutter analyze      # cero errores
```

- Si añadiste lógica nueva, añadiste su test
- Commits que tocan clases testeadas incluyen siempre el test — nunca uno sin el otro