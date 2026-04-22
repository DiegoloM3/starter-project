# 10_USER_EXPERIENCE.md

## 1. Purpose

Este documento define los principios de UX y los flujos de usuario principales
de la aplicación, como guía para la implementación del frontend en Flutter.

---

## 2. Principios de Diseño

La aplicación debe cumplir simultáneamente dos criterios de Symmetry:

> **"Tu abuela de 90 años debe poder usarla."**
> **"Un NPC de 18 años debe pensar 'this shit goes hard'."**

Traducido a principios concretos:

### 2.1 Claridad absoluta
- Jerarquía visual clara en cada pantalla
- Un único CTA por pantalla cuando sea posible
- Textos cortos, sin jerga innecesaria
- Iconos con labels

### 2.2 Performance perceptiva
- Skeleton loaders en vez de spinners
- Optimistic updates para acciones del usuario
- Imágenes con placeholder y fade-in
- Paginación infinita, no paginación por botón

### 2.3 Identidad visual sólida
- Tipografía editorial (serif para cuerpo, sans para UI)
- Palette de alto contraste
- Modo oscuro desde el primer día
- Espaciado generoso (no cramped)

---

## 3. Flujos de Usuario Principales

### 3.1 Onboarding

```
App launch
    ↓
Splash screen (logo + animación breve)
    ↓
¿Nuevo usuario?
    ├── Sí → Registro (email + username + password)
    │         ↓
    │         Selección de categorías de interés
    │         ↓
    │         Feed principal
    │
    └── No → Login (email + password)
              ↓
              Feed principal
```

### 3.2 Lectura de artículo

```
Feed principal
    ↓
Card de artículo (thumbnail + título + fuente + tiempo lectura)
    ↓
Tap → Article Detail View
    ↓
Contenido completo con:
    - Header con imagen
    - Metadatos (autor, fecha, fuente, categoría)
    - Cuerpo del artículo (tipografía editorial)
    - Barra de progreso de lectura
    ↓
Acciones al terminar:
    - Compartir
    - Guardar
    - Ver fuentes relacionadas
    - Comentar
```

### 3.3 Creación de artículo (Journalist Mode)

```
Feed → FAB (+) o menú "Publicar"
    ↓
Editor de artículo:
    - Título
    - Descripción
    - Cuerpo (rich text básico)
    - Categoría (picker)
    - Imagen de portada (gallery o cámara)
    ↓
Preview del artículo
    ↓
Publicar → Confirmación → Artículo en feed
```

### 3.4 Perfil de usuario

```
Perfil:
    - Avatar + nombre + bio
    - Estadísticas: artículos leídos, tokens ganados, artículos publicados
    - Artículos propios (si es periodista)
    - Historial de lectura
    - Ajustes de cuenta
```

---

## 4. Pantallas Requeridas (MVP)

| Pantalla | Descripción |
|---|---|
| `SplashScreen` | Animación de carga inicial |
| `LoginScreen` | Email + password |
| `RegisterScreen` | Email + username + password |
| `FeedScreen` | Lista de artículos paginada |
| `ArticleDetailScreen` | Contenido completo del artículo |
| `CreateArticleScreen` | Formulario de creación |
| `ProfileScreen` | Perfil y estadísticas del usuario |
| `CategoryFilterScreen` | Selector de categorías |

---

## 5. Componentes Flutter Clave

### 5.1 `ArticleCard`
Componente reutilizable para el feed:
```
ArticleCard(
  article: Article,
  onTap: () → navigación a detalle,
  showCategory: bool,
)
```

### 5.2 `ReadingProgressBar`
Barra de progreso de lectura visible en el detail view.
Alimenta el sistema de eventos de lectura.

### 5.3 `TokenBadge`
Badge que muestra los tokens ganados del usuario.
Actualizable desde el BLoC de tokens.

---

## 6. State Management (BLoC/Cubit)

| Cubit | Responsabilidad |
|---|---|
| `AuthCubit` | Login, registro, sesión activa |
| `FeedCubit` | Carga y paginación de artículos |
| `ArticleDetailCubit` | Carga de artículo + tracking de lectura |
| `CreateArticleCubit` | Formulario, validación, subida de imagen |
| `ProfileCubit` | Datos del perfil, estadísticas |
| `TokenCubit` | Balance de tokens, historial |

---

## 7. Navigation

Routing con `go_router`:

```
/                    → FeedScreen
/article/:id         → ArticleDetailScreen
/create              → CreateArticleScreen
/profile             → ProfileScreen
/login               → LoginScreen
/register            → RegisterScreen
```

---

## 8. Accessibility

- Todos los botones tienen `Semantics` labels
- Textos escalables (no tamaños fijos en sp)
- Contraste mínimo WCAG AA
- Touch targets mínimos de 48x48dp

---

## 9. Métricas UX a Monitorear

- Time to first article: < 2 segundos tras login
- Completion rate de artículos leídos: objetivo >40%
- Retention D1 / D7 / D30
- Tiempo medio por sesión

---

## 10. MVP Scope

**Implementar:**
- Todas las pantallas de la tabla de la sección 4
- Componentes `ArticleCard`, `ReadingProgressBar`
- BLoC: `AuthCubit`, `FeedCubit`, `ArticleDetailCubit`, `CreateArticleCubit`

**Diferir:**
- `TokenCubit` y balance visible
- Modo oscuro
- Comentarios y valoraciones
- Historial de lectura detallado
