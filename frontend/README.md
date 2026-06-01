# TortuTip

Plataforma móvil para compartir y descubrir artículos de bienestar. Los lectores exploran contenido personalizado por categorías; los escritores publican artículos con editor de texto enriquecido e imagen de portada.

---

## Stack

| Capa | Tecnología |
|---|---|
| Framework | Flutter 3.x / Dart 3.x |
| Auth | Firebase Auth + Google Sign-In |
| Base de datos | Cloud Firestore |
| Almacenamiento | Firebase Storage |
| Estado | flutter_bloc (Blocs & Cubits) |
| Navegación | go_router |
| Inyección de dependencias | get_it |
| Localización | flutter_localizations + intl (ES / EN) |

---

## Arquitectura

Clean Architecture con separación estricta en tres capas por feature:

```
features/{feature}/
├── domain/          # Entities, Repository interfaces, UseCases
├── data/            # Models, DataSources (Firebase), RepositoryImpl
└── presentation/    # Blocs/Cubits, Screens, Widgets
```

**Regla de dependencias:**
- `domain` — cero imports del proyecto (Dart puro)
- `data` — solo importa `domain` y Firebase
- `presentation` — solo importa `domain` (use cases)

---

## Features

| Feature | Descripción |
|---|---|
| **Auth** | Login con Google, guard de autenticación en el router |
| **Onboarding** | Selección de categorías, rol (lector / escritor) y perfil |
| **Feed** | Artículos personalizados según categorías del usuario |
| **Explore** | Búsqueda y exploración de artículos y categorías |
| **Search** | Búsqueda en tiempo real de artículos |
| **Bookmarks** | Guardado y gestión de artículos favoritos |
| **Create Article** | Editor con flutter_quill, crop de portada, publicación |
| **Profile** | Vista y edición del perfil del usuario |

---

## Estructura del proyecto

```
lib/
├── config/
│   ├── routes/        # go_router — app_router.dart, app_routes.dart
│   └── theme/         # Tokens de diseño (colores, tipografía, espaciado)
├── core/
│   ├── resources/     # DataState<T> (DataSuccess / DataFailed)
│   └── usecase/       # Contrato UseCase<Output, Params>
├── injection/         # DI con get_it — un archivo por feature
├── shared/
│   ├── user/          # Entidad y repositorio compartido de usuario
│   └── widgets/       # Widgets reutilizables (botones, cards, inputs…)
└── features/          # auth, articles, search, bookmarks, profile…
```

---

## Primeros pasos

### Requisitos

- Flutter >= 3.10
- Dart >= 3.0
- Xcode >= 15 con iOS deployment target **15.0**
- Cuenta Firebase con proyecto configurado

### Instalación

```bash
# Clonar el repositorio
git clone <repo-url>
cd tortutip

# Instalar dependencias
flutter pub get

# Generar archivos de localización
flutter gen-l10n

# Ejecutar en simulador
flutter run
```

### Firebase

Coloca los archivos de configuración en sus rutas correspondientes:

```
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
```

---

## Localización

La app soporta **español** (predeterminado) e **inglés**.  
Los archivos ARB viven en `lib/l10n/`:

```
lib/l10n/
├── app_es.arb
└── app_en.arb
```

Para añadir una cadena nueva, agrégala en ambos ARB y ejecuta `flutter gen-l10n`.

---

## Testing

```bash
# Ejecutar todos los tests
flutter test

# Análisis estático
flutter analyze
```

Se testean obligatoriamente: **UseCases**, **Blocs/Cubits** y **RepositoryImpl**.  
No se testean en el MVP: DataSources, Screens y Widgets.

---

## Diseño

Los tokens de diseño viven en `lib/config/theme/`:

| Archivo | Contenido |
|---|---|
| `app_colors.dart` | Paleta de colores |
| `app_typography.dart` | Estilos de texto |
| `app_spacing.dart` | Espaciados y border radii |
| `app_decorations.dart` | BoxDecorations reutilizables |
| `app_theme.dart` | ThemeData global |

Nunca usar colores, tamaños ni espaciados hardcodeados — siempre los tokens.

---

## Convenciones de commits

```
feat(auth): implement login with Google
fix(feed): resolve duplicate articles on refresh
chore(deps): upgrade firebase_auth to 6.5.1
refactor(articles): extract article card to shared widgets
```
