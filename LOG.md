# LOG

Registro de cambios realizado durante esta sesión de trabajo.

## 2026-04-08

### 1) Análisis y planificación del proyecto
- Se realizó revisión completa del repositorio, README y documentación técnica.
- Se preparó un plan integral de ejecución en `NEXT_STEPS.md` (roadmap por fases, checklist y estrategia de calidad).
- Se creó una guía maestra de arquitectura y entrega en `docs/PROJECT_BIBLE.md`.

### 2) Definición de backend y esquema de datos
- Se creó `backend/docs/DB_SCHEMA.md` con un esquema completo para artículos y usuarios:
  - contrato de campos,
  - validaciones,
  - estados de publicación,
  - patrones de consulta e índices esperados,
  - contrato de Cloud Storage para thumbnails.

### 3) Seguridad y performance en Firebase (commitado)
- Se implementaron reglas de seguridad de Firestore en `backend/firestore.rules`:
  - control de acceso por rol (`journalist`/`admin`),
  - validación de shape/tipos para artículos,
  - inmutabilidad de campos críticos (`createdBy`, `createdAt`),
  - transiciones válidas de estado (`draft/published/archived`).
- Se implementaron reglas de Storage en `backend/storage.rules`:
  - alcance en `media/articles`,
  - control de acceso por rol,
  - validación de tipo y tamaño de imagen.
- Se definieron índices compuestos en `backend/firestore.indexes.json` para consultas reales de feed, filtros y autor.
- Commit asociado:
  - `3a5b855` — `feat(backend): enforce article security rules and query indexes`

### 4) Integración Flutter + Firebase (commitado)
- Se instaló y configuró `flutterfire_cli`.
- Se conectó el proyecto Flutter Android al proyecto Firebase.
- Se generaron archivos de configuración:
  - `frontend/lib/firebase_options.dart`
  - `frontend/android/app/google-services.json`
- Se actualizó arranque de app para inicializar Firebase en `frontend/lib/main.dart`.
- Se ajustaron archivos Gradle requeridos por FlutterFire:
  - `frontend/android/settings.gradle`
  - `frontend/android/app/build.gradle`
- Se actualizó referencia de proyecto en `backend/.firebaserc`.
- Commit asociado:
  - `da891a2` — `chore(firebase): configure Flutter app with Firebase project`

### 5) Corrección de build para Flutter/Android modernos (completado)
- Se resolvieron errores de compilación por incompatibilidades de tooling y dependencias.
- Se actualizaron versiones de build Android:
  - Gradle wrapper -> `8.7` (`frontend/android/gradle/wrapper/gradle-wrapper.properties`)
  - Android Gradle Plugin -> `8.6.1` (`frontend/android/settings.gradle`)
  - Kotlin plugin -> `2.1.0` (`frontend/android/settings.gradle`)
- Se limpió configuración legacy de Kotlin en `frontend/android/app/build.gradle`.
- Se actualizó restricción de SDK Dart en `frontend/pubspec.yaml` a `>=3.0.0 <4.0.0`.
- Se añadieron `dependency_overrides` para compatibilidad con Flutter/Dart actuales:
  - `win32`
  - `path_provider`
  - `path_provider_android`
  - `path_provider_windows`
  - `sqflite`
- Resultado validado:
  - Build de Android exitoso (`app-debug.apk` generado).
- Commit asociado:
  - `a840178` — `build(android): upgrade toolchain and plugin compatibility for modern Flutter`

### 6) Implementación inicial de `upload_article` (mock-first, clean feature-first)
- Se creó la nueva feature `frontend/lib/features/upload_article` con separación por capas:
  - `domain/entities/upload_article.dart`
  - `domain/repository/upload_article_repository.dart`
  - `domain/usecases/upload_article.dart`
  - `data/repository/upload_article_repository_mock.dart`
  - `presentation/bloc/upload_article_cubit.dart`
  - `presentation/bloc/upload_article_state.dart`
  - `presentation/pages/add_article/add_article.dart`
- Se implementó flujo mock de publicación:
  - formulario con validaciones de negocio básicas,
  - estados de carga/éxito/error con `Cubit`,
  - retorno de `DataState<ArticleEntity>` desde repositorio mock.
- Se integró navegación y wiring:
  - nueva ruta `'/AddArticle'` en `frontend/lib/config/routes/routes.dart`,
  - FAB de `DailyNews` ahora navega a la pantalla de alta de artículo,
  - DI actualizado en `frontend/lib/injection_container.dart` para registrar repositorio, use case y cubit de upload.
- Verificación:
  - análisis estático ejecutado sin errores nuevos (solo avisos preexistentes del proyecto).

### 7) `upload_article` conectado a Firebase real (Firestore + Storage)
- Se implementó data source real en:
  - `frontend/lib/features/upload_article/data/data_sources/upload_article_firebase_data_source.dart`
- El flujo real ahora:
  - crea documento en `articles`,
  - sube imagen a `media/articles/{articleId}.jpg` cuando el valor de imagen es una ruta local de archivo,
  - conserva URL directa cuando el valor de imagen ya es `http/https`.
- Se implementó repositorio real en:
  - `frontend/lib/features/upload_article/data/repository/upload_article_repository_impl.dart`
  - manejo de éxito/error en formato `DataState`.
- Se reemplazó el wiring de mock por implementación real en:
  - `frontend/lib/injection_container.dart`
  - registro de `FirebaseFirestore`, `FirebaseStorage`, data source y repository real.
- Verificación:
  - análisis estático ejecutado,
  - sin errores nuevos introducidos (solo avisos históricos del proyecto).

### 8) Paso ideal de autenticación para cumplir reglas de seguridad
- Se añadió autenticación Firebase en frontend:
  - dependencia `firebase_auth` en `frontend/pubspec.yaml`.
- Se implementó bootstrap de sesión en `frontend/lib/main.dart`:
  - login anónimo al arranque cuando no existe sesión activa,
  - creación/actualización de `users/{uid}` con rol `journalist` usando `merge`.
- Se alineó `upload_article` con reglas backend:
  - `createdBy` ahora usa `auth.currentUser.uid`,
  - se valida sesión activa antes de permitir upload.
- Se actualizó DI para inyectar `FirebaseAuth`:
  - `frontend/lib/injection_container.dart`.
- Verificación:
  - dependencias instaladas y análisis estático ejecutado,
  - sin errores nuevos (solo avisos preexistentes del proyecto).

### 9) Cierre de flujo producto: "My Articles" conectado a Firestore
- Se extendió contrato de `upload_article` para soportar lectura de artículos propios:
  - `getMyUploadedArticles()` en repository y use case dedicado.
- Se implementó lectura real en Firebase data source:
  - query por `createdBy == currentUser.uid`,
  - orden por `createdAt` descendente,
  - mapeo robusto a `ArticleEntity`.
- Se implementó estado y lógica de presentación:
  - `MyUploadedArticlesCubit` + estados (`loading/done/error`).
- Se creó pantalla de producto:
  - `MyArticlesPage` con lista de artículos propios, estados de loading/error/empty y navegación a detalle.
- Se integró navegación principal:
  - nueva ruta `'/MyArticles'`,
  - nuevo acceso desde `DailyNews` en AppBar.
- Se actualizó DI:
  - registro de `GetMyUploadedArticlesUseCase` y `MyUploadedArticlesCubit`.
- Compatibilidad:
  - se actualizó mock repository para implementar el nuevo contrato sin romper compilación.
- Verificación:
  - análisis estático ejecutado sin errores nuevos del cambio (solo avisos históricos).

### 10) Cobertura de tests ampliada para toda la lógica actual de la app
- Se creó estructura de tests por capas en `frontend/test`, cubriendo:
  - **Domain use cases (`daily_news`)**:
    - `get_article_usecase_test.dart`
    - `get_saved_article_usecase_test.dart`
    - `save_article_usecase_test.dart`
    - `remove_article_usecase_test.dart`
  - **Domain use cases (`upload_article`)**:
    - `upload_article_usecase_test.dart`
    - `get_my_uploaded_articles_usecase_test.dart`
  - **Presentation state management**:
    - `remote_article_bloc_test.dart`
    - `local_article_bloc_test.dart`
    - `upload_article_cubit_test.dart`
    - `my_uploaded_articles_cubit_test.dart`
  - **Data repositories**:
    - `article_repository_impl_test.dart`
    - `upload_article_repository_impl_test.dart`
- Ajustes de testing:
  - se añadió `mocktail` como dependencia de desarrollo en `frontend/pubspec.yaml`.
  - se evitó acoplamiento con `bloc_test` por conflicto de versiones del proyecto (retrofit_generator legacy), manteniendo tests robustos con `flutter_test` + streams/estado final.
- Resultado:
  - ejecución completa de `flutter test` en `frontend` con **todos los tests en verde**.

### 11) CI para Pull Requests con calidad mínima obligatoria
- Se añadió workflow de GitHub Actions en:
  - `.github/workflows/pr-quality.yml`
- Alcance del workflow:
  - se ejecuta **solo en eventos de Pull Request** (`opened`, `synchronize`, `reopened`, `ready_for_review`),
  - no corre en PRs draft (`if: github.event.pull_request.draft == false`).
- Pipeline implementado para `frontend`:
  - `flutter pub get`
  - `dart format --set-exit-if-changed lib test`
  - `flutter analyze`
  - `flutter test`
- Resultado esperado:
  - cada PR queda bloqueada automáticamente si falla formato, análisis o tests.

---

## Estado actual recomendado
- Backend de seguridad e índices: listo y commitado.
- Firebase en frontend: listo y commitado.
- Build Android en Flutter moderno: funcional y estable.
- `upload_article` ya opera con backend Firebase real (Firestore + Storage).
- sesión autenticada y usuario `journalist` inicializado al arranque para respetar reglas de escritura.
- visualización de artículos propios añadida e integrada en navegación.
- suite de tests de lógica de aplicación implementada y ejecutada con éxito.
- CI de PR instalada para enforcing de formato + análisis + tests.
- Siguiente objetivo funcional: tests de widget para flujos clave (`AddArticlePage`, `MyArticlesPage`) y polish UX del formulario (selector real de imagen, validación de URL/archivo más guiada).
