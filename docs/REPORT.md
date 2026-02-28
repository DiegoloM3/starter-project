# REPORT

## 1. Introducción

Comencé este proyecto con foco en completar el flujo end-to-end de artículos creados por usuarios autenticados, manteniendo arquitectura limpia (data/domain/presentation) y priorizando estabilidad en entorno local con Firebase Emulator Suite.

El objetivo principal fue que la funcionalidad de periodista funcionara de forma real: autenticación, creación de artículos con imagen en Storage, visualización en "My Articles", presencia en el feed principal y borrado de artículos propios.

## 2. Learning Journey

Durante el desarrollo reforcé y apliqué:

- Integración Flutter + Firebase (Auth, Firestore, Storage).
- Configuración y uso de Firebase Emulator Suite para desarrollo local.
- Manejo de estado con Bloc/Cubit para flujos de autenticación y artículos.
- Organización por capas siguiendo Clean Architecture.
- Pruebas de capa de negocio con repositorios mockeados.

Recursos aplicados:

- Documentación Flutter y Firebase.
- Documentación de reglas Firestore/Storage.
- Estructura y guías internas del repositorio (`README.md`, `APP_ARCHITECTURE.md`, `ARCHITECTURE_VIOLATIONS.md`, `CODING_GUIDELINES.md`).

## 3. Desafíos enfrentados

### 3.1 Sesión no autenticada causando crash

Problema:
- Null check en flujo de "My Articles" cuando no había usuario autenticado.

Solución:
- Se agregó estado explícito de no autenticado y retorno temprano en cubit.
- La UI ahora muestra pantalla de login/estado claro en vez de crash.

### 3.2 Errores de Auth Emulator y tráfico HTTP en Android

Problema:
- `CONFIGURATION_NOT_FOUND` y errores de cleartext (`10.0.2.2 not permitted`).

Solución:
- Configuración de emuladores desde `main.dart` para Auth/Firestore/Storage.
- Variables por `--dart-define` y `.env.example`.
- `usesCleartextTraffic` en manifest debug para entorno local.

### 3.3 Creación de artículo guardando en lugar incorrecto

Problema:
- Al crear artículo se guardaba también en "Saved Articles".

Solución:
- Separación de casos de uso:
  - `createMyArticle` (Firestore)
  - `saveArticle` (local)

### 3.4 ProviderNotFound en creación de artículos

Problema:
- Context fuera del scope correcto de `BlocProvider`.

Solución:
- Ajuste del contexto interno (builder) para que el cubit esté disponible al hacer submit.

### 3.5 Campos inconsistentes de imagen

Problema:
- Diferencia entre `thumbnailURL` y `urlToImage` según flujo.

Solución:
- Estandarización a `urlToImage` en implementación y parseo robusto para compatibilidad.

## 4. Reflexión y futuras mejoras

### Aprendizajes técnicos

- La configuración local de Firebase emulators es crítica para evitar falsos errores de backend.
- Unidades pequeñas (use cases) con repositorios abstractos facilitan pruebas y cambios sin romper UI.
- Separar casos de uso similares pero conceptualmente distintos evita bugs funcionales (create vs save local).

### Aprendizajes profesionales

- Resolver primero estabilidad y corner cases (nulls, sesión, provider scope) acelera el desarrollo funcional posterior.
- Mantener trazabilidad entre requisitos y cambios reduce retrabajo.

### Mejoras futuras

- Implementar registro de usuarios desde UI (actualmente login con cuentas existentes del emulador).
- Mejorar borrado de artículos usando `documentId` explícito en entidad/modelo.
- Añadir pruebas de integración/UI (journeys de login, create, delete).
- Formatear fechas para mostrar `publishedAt` de forma más amigable.

## 5. Prueba del proyecto

Flujos validados funcionalmente:

- Login con Firebase Auth Emulator.
- Crear artículo autenticado con imagen opcional subida a Storage Emulator.
- Ver artículo en "My Articles".
- Ver artículo en feed principal ordenado por fecha.
- Eliminar artículo propio desde "My Articles".
- Guardar artículos en "Saved Articles" de forma independiente.
- Ocultar/mostrar acciones según sesión (`+`, logout, perfil/login).

Evidencia a adjuntar:

- Capturas de pantalla:
  - Home sin sesión
  - Login
  - Create article
  - My Articles
  - Saved Articles
  - Emulator UI (Auth, Firestore, Storage)
- Video corto del flujo completo (login -> create -> list -> delete).

## 6. Overdelivery

### 6.1 Nuevas funcionalidades implementadas

- Integración completa de Firebase Emulator Suite (Auth, Firestore, Storage) con configuración por entorno.
- Subida de imagen de artículo a Storage y guardado de URL en Firestore.
- Eliminación de artículos propios desde UI.
- Inclusión de artículos creados por usuarios en el feed principal.
- Estados de UI robustos para sesión no autenticada y casos nulos.

### 6.2 Prototipos/ajustes técnicos

- Flujo de configuración local documentado con `.env.example` y comandos con `--dart-define`.
- Reglas de Firestore/Storage reforzadas para ownership y acceso.

### 6.3 Cómo mejorar esta sección

- Añadir una propuesta de diseño visual mejorado (microinteracciones y refinamiento de layout).
- Añadir métricas de calidad (tiempo de carga, cobertura de tests, crash-free sessions).

## 7. Secciones extra

### 7.1 Tests de negocio (mock/fake)

Se añadieron pruebas unitarias para la capa domain:

- `frontend/test/features/auth/domain/usecases/auth_usecases_test.dart`
- `frontend/test/features/daily_news/domain/usecases/daily_news_usecases_test.dart`

Casos cubiertos:

- Auth: get current user, sign in, sign out.
- Daily news: get news, get saved, get my articles, get community articles, create my article, delete my article, save article, remove article, upload article image.

Resultado:

- Todos los tests pasan correctamente en ejecución local.
