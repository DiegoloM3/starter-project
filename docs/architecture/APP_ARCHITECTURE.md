# Symmetry App Architecture

Symmetry follows an adaptation of **Clean Architecture** split into three layers with strict dependency rules, optimized for a **Hybrid Backend** environment.

---

## Hybrid Backend Strategy

A core architectural decision of Symmetry is its resilience through redundancy:

1.  **Primary API**: FastAPI + MongoDB (Local/Self-hosted).
2.  **High Availability Fallback**: Firebase Firestore + Firebase Storage.
3.  **Authentication**: Firebase Authentication.
4.  **AI Services**: Hybrid (Local Ollama → Fallback to OpenAI GPT-4o-mini).

---

## Folder Structure (Updated v1.2.0)

```
lib/
├── config/
│   ├── routes/          # Navigator 1 route definitions (AppRoutes)
│   └── theme/           # Cyber Night Theme Definitions
│
├── core/
│   ├── constants/       # App-wide constants (API URLs, timeouts)
│   ├── resources/       # DataState<T> wrappers
│   └── usecase/         # UseCase base classes
│
├── features/
│   ├── auth/            # NEW: Authentication & User Management
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/ # LoginPage, WelcomePage (Onboarding)
│   │
│   └── daily_news/      # Main Content Feature
│       ├── data/        # Repository implementations with fallback logic
│       ├── domain/
│       └── presentation/ # Feed, ArticleDetail, Publish
```

---

## Layer Responsibilities

### Data Layer
- **data_sources/** — Punto táctico de contacto con APIs (REST/Dio) y Firebase SDKs.
- **models/** — Extensiones de entidades con lógica de serialización JSON/Firestore.
- **repository/** — **Orquestadores de Fallback**. Implementan la lógica: *Si falla FastAPI → Consultar Firestore*.

### Domain Layer (Puro Dart)
- **entities/** — Objetos de negocio (Article, UserEntity).
- **repository/** — Contratos abstractos que definen qué operaciones son posibles (sin saber de dónde viene la data).

### Presentation Layer
- **bloc/cubit/** — Gestión de estados. El `AuthCubit` es global para toda la sesión.
- **pages/widgets/** — Implementación de la estética **Cyber Night** (Glassmorphism, Neon UI).

---

## Redundancia de IA (Patrón OPAD)

El `ChatService` implementa una cadena de responsabilidad:
1.  **Local Intent**: Intenta generar respuesta vía FastAPI (Ollama/Qwen 2.5b).
2.  **Graceful Fallback**: Ante fallos de conexión o timeout (10s), conmuta a la API de **OpenAI** usando la clave segura cargada desde `.env`.

---

## Multimedia Pipeline

Las imágenes siguen un flujo de **Autoría Verificada**:
- `users/{userId}/articles/{articleId}/thumbnail.jpg`
- Este esquema permite que cada activo multimedia esté vinculado a un autor traceable en el futuro sistema de recompensas.

---

## Design System: "Cyber Night"

Toda la UI debe adherirse a los tokens de diseño **Cyber Night**:
- Fondos: `#03050F` (Profundo)
- Acentos: `#00FFFF` (Cian Neón), `#FF00FF` (Magenta Neón)
- Transiciones: Animaciones cinéticas inspiradas en el "Cyber Pulse".

---

*Actualizado 21 de Abril, 2026 — Symmetry Engineering*
