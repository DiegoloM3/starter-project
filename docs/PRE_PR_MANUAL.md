# Trabajo manual previo al PR

> **Propósito.** Lista de acciones que un humano debe ejecutar **antes** de abrir el Pull Request desde `chore/modernization` hacia `main`. Todo lo automatizable ya está hecho en los 60 commits de la rama; lo que queda aquí son pasos que requieren credenciales, interacción con hardware real (cámara/galería) o captura audiovisual.
>
> **Tiempo estimado:** 2.5 — 4 horas dependiendo de lo rápido que se consigan las credenciales Firebase.
>
> **Regla de oro:** ejecutar los pasos **en orden**. Varias casillas dependen de pasos anteriores (p. ej. no se pueden grabar screenshots reales sin haber desbloqueado F0).

---

## Índice

1. [Pre-flight check (5 min)](#1-pre-flight-check)
2. [Desbloquear F0: proyecto Firebase (30–60 min)](#2-desbloquear-f0-proyecto-firebase)
3. [Screenshots oficiales (30 min)](#3-screenshots-oficiales)
4. [Vídeo demo ≤ 2 min (30 min)](#4-vídeo-demo--2-min)
5. [Último barrido de calidad (15 min)](#5-último-barrido-de-calidad)
6. [Lanzamiento del PR (10 min)](#6-lanzamiento-del-pr)
7. [Post-merge (5 min)](#7-post-merge)

---

## 1. Pre-flight check

Antes de tocar nada, confirmar el estado del working tree y la salud del branch.

- [ ] `git status` → working tree limpio, sin archivos untracked inesperados.
- [ ] `git log --oneline main..HEAD | wc -l` → 60 (o más si este documento añadió commits).
- [ ] `cd frontend && flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs` → termina sin errores.
- [ ] `flutter analyze` → `6 issues found` o menos, sin errors ni warnings.
- [ ] `flutter test` → `58 passing` o superior, 0 failing.
- [ ] Abrir `docs/REPORT.md`, `docs/SOLUCION.md`, `docs/adr/0003-decisiones-consolidadas.md`, `CHANGELOG.md`, `frontend/README.md`: confirmar que render en GitHub se verá correctamente (links relativos, títulos con `#`, code blocks cerrados).

**Si algo falla:** NO proceder. Arreglar y volver a empezar este checklist desde 1.

---

## 2. Desbloquear F0: proyecto Firebase

Este es el paso que permite grabar screenshots y vídeo contra Firestore real, y demostrar que las reglas funcionan end-to-end.

### 2.1 Crear / seleccionar proyecto Firebase

- [ ] Login en [console.firebase.google.com](https://console.firebase.google.com).
- [ ] Crear proyecto nuevo (recomendado: `symmetry-prueba-<tu-nombre>`) o reutilizar uno existente.
- [ ] En **Build → Firestore Database** → crear base de datos en **modo producción** (no test). Región: `us-central` por defecto.
- [ ] En **Build → Storage** → activar con default bucket.
- [ ] En **Build → Authentication** → tab **Sign-in method** → activar **Email/Password** y **Anonymous** (el segundo nos sirve para demos sin onboarding).
- [ ] En **Project settings** (engranaje superior) → registrar la app Android, iOS y/o web. Copiar el `projectId` que aparece ahí.

### 2.2 Actualizar `.firebaserc`

- [ ] Editar [`backend/.firebaserc`](../backend/.firebaserc) y reemplazar `// TODO: ADD PROJECT ID` por el `projectId` real.
  ```json
  {
    "projects": {
      "default": "symmetry-prueba-abraham"
    }
  }
  ```

### 2.3 Firebase CLI autenticada

- [ ] `firebase login --reauth` en una terminal. Si falla porque la CLI no está instalada: `npm i -g firebase-tools`.
- [ ] `firebase projects:list` → el proyecto recién creado debe aparecer.

### 2.4 Generar `firebase_options.dart` para Flutter

- [ ] Si no está: `dart pub global activate flutterfire_cli`.
- [ ] Desde la raíz: `cd frontend && flutterfire configure`. Seleccionar el proyecto. Elegir las plataformas (al menos Android + web, más iOS si se va a grabar en Mac).
- [ ] Verificar que apareció `frontend/lib/firebase_options.dart`.
- [ ] **Decidir si se compromete al repo.** Para esta prueba técnica: sí, comprometerlo. Las claves que contiene son públicas por diseño (Google las valida con `SHA-1` del app en Android y `bundleId` en iOS). Asegurarse de que `.gitignore` NO lo excluye. Si lo excluye, documentar por qué en el PR.

### 2.5 Cablear `Firebase.initializeApp` en el bootstrap

- [ ] Abrir [`frontend/lib/bootstrap.dart`](../frontend/lib/bootstrap.dart). Buscar el bloque `TODO(F0)`.
- [ ] Descomentar / añadir:
  ```dart
  import 'package:firebase_core/firebase_core.dart';
  import 'package:news_app_clean_architecture/firebase_options.dart';

  // dentro de bootstrap(), antes de initializeDependencies():
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  ```
- [ ] Quitar el comentario `TODO(F0)`.
- [ ] `flutter analyze` → sigue en 0 errores / 0 warnings.

### 2.6 Deploy de reglas

- [ ] `firebase deploy --only firestore:rules,storage:rules`.
- [ ] Salida esperada: `✔ Deploy complete!`.
- [ ] En la consola Firebase → **Firestore → Rules** y **Storage → Rules**: verificar que el contenido refleja `backend/firestore.rules` y `backend/storage.rules`.

### 2.7 Prueba de fuego manual (sin escribir código)

Con el simulador de reglas de la consola Firebase:

- [ ] **Firestore Rules Playground:**
  - Crear documento `articles/test_pass` como usuario autenticado con un `authorId` que iguale su uid, todos los campos válidos → debería **permitir**.
  - Mismo documento pero con `authorId` distinto al uid → debería **denegar**.
  - Lectura sin auth → debería **permitir** (feed público).
- [ ] **Storage Rules Playground:**
  - Upload a `media/articles/<uid>/article1/thumb.png`, `contentType: image/png`, 2 MB → **permitir**.
  - Upload al mismo path con `contentType: application/pdf` → **denegar**.
  - Upload a `media/articles/<uid>/article1/big.jpg`, 10 MB → **denegar** por tamaño.

**Si alguno de estos casos no se comporta como se espera:** pausar. Revisar `backend/firestore.rules` y `backend/storage.rules`. El ADR-0003 §9 explica la alineación esperada entre schema y rules.

### 2.8 Commit de los cambios de F0

- [ ] `git add backend/.firebaserc frontend/lib/firebase_options.dart frontend/lib/bootstrap.dart`
- [ ] Commit:
  ```
  feat(f0): wire real Firebase (flutterfire configure + initializeApp)

  Unblocks F0 after the challenge window. Firebase.initializeApp now
  runs in bootstrap.dart, so the DI container flips from the fake
  repository to UserArticleRepositoryImpl automatically.

  firestore.rules and storage.rules deployed to <projectId>.
  ```

---

## 3. Screenshots oficiales

Objetivo: capturar las pantallas clave del flujo end-to-end contra Firestore real (ahora que F0 está desbloqueado) y guardarlas bajo `docs/assets/screenshots/`.

- [ ] Crear la carpeta: `mkdir -p docs/assets/screenshots`.
- [ ] `flutter run --release --dart-define=NEWS_API_KEY=<tu-key>` en el dispositivo / emulador de elección.
- [ ] Capturar (nombrar con el patrón `NN-nombre.png`):
  - [ ] `01-home.png` — Daily News home con FAB "My Articles".
  - [ ] `02-my-articles-empty.png` — Empty state de `MyArticlesPage` (antes de crear nada).
  - [ ] `03-editor-empty.png` — `ArticleEditorPage` vacío, mostrando el hint de requisitos.
  - [ ] `04-editor-filled.png` — mismo editor con título, contenido y thumbnail picked.
  - [ ] `05-my-articles-populated.png` — lista con al menos 2 artículos.
  - [ ] `06-detail.png` — `UserArticleDetailPage` para un artículo publicado.
  - [ ] `07-edit.png` — editor en modo edición (título prellenado, botón "Save changes").
  - [ ] `08-delete-confirm.png` — diálogo de confirmación al borrar.
  - [ ] `09-error-state.png` — `MyArticlesPage` en modo error (puedes cortar red para provocarlo).
  - [ ] `10-dark-mode.png` — cualquier pantalla con el sistema en modo oscuro, demostrando los tokens.
- [ ] Insertar una cuadrícula mini de estas capturas en `docs/REPORT.md` sección **5. Proof of the project**. Usar markdown:
  ```markdown
  ![My Articles — empty](./assets/screenshots/02-my-articles-empty.png)
  ```

**Tip:** si el tiempo es corto, priorizar 02, 04, 05, 06 y 10. Son las 5 más representativas.

---

## 4. Vídeo demo ≤ 2 min

### 4.1 Guion sugerido

00:00 — 00:20 · Intro en la home (Daily News), narra la adición del FAB "My Articles".

00:20 — 00:50 · Tap FAB → MyArticlesPage vacío → tap "New" → editor.
- Rellena título, content, picka thumbnail (stub o real imagen).
- Tap Publish → SnackBar "Article published" → vuelve a la lista con el nuevo item.

00:50 — 01:10 · Edita el artículo (icon lápiz), cambia título, Save changes → SnackBar "Article updated".

01:10 — 01:30 · Tap en el card → UserArticleDetailPage → Back. Luego icono papelera → diálogo → Delete → card desaparece.

01:30 — 01:50 · Enseña el modo oscuro (toggle del sistema) para mostrar que los tokens se propagan.

01:50 — 02:00 · (Opcional) Consola Firebase: mostrar el documento en Firestore y la imagen en Storage.

### 4.2 Herramientas

- **Android:** `adb shell screenrecord /sdcard/demo.mp4 --time-limit 120` o el grabador nativo.
- **iOS:** Control Center → botón de grabar pantalla.
- **Web:** OBS, Loom, o la feature nativa de Chrome DevTools.

### 4.3 Checklist post-grabación

- [ ] Duración ≤ 2 min.
- [ ] No se ve ninguna key API ni email privado en pantalla.
- [ ] Audio muteado o con narración clara (no música con copyright).
- [ ] Guardar como `docs/assets/demo.mp4` O subir a Drive/YouTube unlisted y enlazar en `docs/REPORT.md`.
- [ ] Añadir la referencia en `docs/REPORT.md` §5 (`🎬 [Demo (2 min)](./assets/demo.mp4)` o el link externo).

---

## 5. Último barrido de calidad

- [ ] `cd frontend && flutter clean && flutter pub get` (asegura build from scratch).
- [ ] `flutter pub run build_runner build --delete-conflicting-outputs`.
- [ ] `dart format --set-exit-if-changed .` → exit 0.
- [ ] `flutter analyze` → sin nuevos errors ni warnings. Ideal: 0 issues; aceptable: los 6 infos benignos documentados al cierre de F9.
- [ ] `flutter test --coverage` → 58 o más tests pasando.
- [ ] Opcional: `genhtml coverage/lcov.info -o coverage/html && open coverage/html/index.html` para ver el reporte.
- [ ] `grep -R "TODO\|FIXME" frontend/lib` → revisar que no haya TODOs nuevos sin owner. Los del código pre-existente de `daily_news` están documentados en los ADRs.
- [ ] Hacer un `git diff main..HEAD -- frontend/lib/features/user_articles/ | wc -l` y confirmar que la feature nueva está proporcionada con lo descrito en REPORT.md / SOLUCION.md.

---

## 6. Lanzamiento del PR

### 6.1 Push del branch

- [ ] `git push -u origin chore/modernization`.
- [ ] Si hay conflictos con `main`: **NO** hacer force push. Resolver localmente con `git rebase origin/main`, ejecutar el checklist §5 otra vez, y volver a push.

### 6.2 Abrir el PR en GitHub

- [ ] Título sugerido:
  ```
  feat(user_articles): deliver publish/edit/list/delete with clean architecture
  ```
- [ ] Descripción (pegar en el editor de GitHub):
  ```markdown
  ## Summary
  - Entrega la feature `user_articles` (publicar / editar / listar / borrar)
    con contrato `Either<AppFailure, T>`, persistencia Firestore + Storage
    y fallback a repositorio fake cuando Firebase no está inicializado.
  - Moderniza la plataforma: `freezed`/`json_serializable`/`dartz`/`go_router`,
    design tokens + `ThemeExtension`, CI con analyze/format/test, ADRs
    consolidados.

  ## Cambios por fase
  - F0 — Firebase (flutterfire configure + deploy reglas)
  - F1 — Modernización técnica (Dart 3.3, very_good_analysis, test tooling, CI)
  - F2 — core/shared + bootstrap (AppFailure, UseCase base, AppLogger)
  - F3 — Design tokens + go_router (overdelivery #15 y #21)
  - F4 — Refactor `daily_news` al nuevo estándar
  - F5 — Backend (schema en DB_SCHEMA.md + firestore.rules + storage.rules)
  - F6 — Domain `user_articles` (entidades, params, 5 use cases + fake repo)
  - F7 — Presentation `user_articles` (2 blocs, 3 páginas, 3 widgets, routes)
  - F8 — Data `user_articles` (Firestore + Storage data sources + repo impl)
  - F9 — QA, REPORT, SOLUCION, ADR consolidado, CHANGELOG

  ## Documentación
  - [ADR-0003 — Decisiones consolidadas](./docs/adr/0003-decisiones-consolidadas.md)
  - [docs/SOLUCION.md — solución técnica detallada](./docs/SOLUCION.md)
  - [docs/REPORT.md — reporte oficial](./docs/REPORT.md)
  - [docs/PRE_PR_MANUAL.md — checklist pre-PR (este archivo)](./docs/PRE_PR_MANUAL.md)
  - [CHANGELOG.md — 1.0.0](./CHANGELOG.md)

  ## Métricas
  - `flutter analyze`: 0 errors, 0 warnings (infos benignos documentados)
  - `flutter test`: 58/58 verde
  - 60 commits atómicos en Conventional Commits
  - CI verde en cada commit

  ## Test plan
  - [ ] Clonar el repo en limpio
  - [ ] Seguir `frontend/README.md` para instalar + correr
  - [ ] Verificar que la app arranca con fake (sin Firebase) y que el flujo
        publish/edit/delete funciona
  - [ ] Con Firebase real: probar las 3 reglas críticas en el Playground
        (ver `docs/PRE_PR_MANUAL.md` §2.7)
  - [ ] Comparar con screenshots en `docs/assets/screenshots/`

  🤖 Generated with [Claude Code](https://claude.com/claude-code)
  ```
- [ ] Revisar que el PR apunta desde `chore/modernization` hacia `main`, no al revés.
- [ ] Asignar reviewers si el workflow del equipo lo requiere.

### 6.3 Verificar CI

- [ ] GitHub Actions workflow `CI` debe pasar automáticamente.
- [ ] Si falla: **no** merge. Investigar, arreglar localmente, push (nuevo commit, no force).

### 6.4 Auto-revisión

Antes de marcar el PR como ready for review, leer en GitHub el diff completo:

- [ ] Ningún archivo binario accidental (ej. `.DS_Store`, `.idea/`, builds).
- [ ] Ninguna key API hardcodeada (grep visual por "AIza", "sk-", etc.).
- [ ] Las migraciones de lint style no están mezcladas con cambios semánticos en el mismo commit.
- [ ] Todos los comentarios TODO/FIXME nuevos tienen owner o están en un ADR.

---

## 7. Post-merge

Una vez el PR esté mergeado a `main`:

- [ ] `git checkout main && git pull` localmente.
- [ ] `git tag -a v1.0.0 -m "First delivery of user_articles feature (Symmetry prueba técnica)"`.
- [ ] `git push origin v1.0.0`.
- [ ] En GitHub → **Releases** → **Draft a new release** → seleccionar el tag → copiar el contenido de `CHANGELOG.md` §1.0.0 como description.
- [ ] Archivar la rama `chore/modernization` con el botón "Delete branch" de GitHub (git history preservada).
- [ ] Actualizar `docs/prueba-tecnica/02_CHECKLIST.md` §I marcando el tag `v1.0.0` como ✅.

---

## Apéndice — Si algo sale mal

| Síntoma                                                     | Diagnóstico típico                                   | Remedio                                            |
|-------------------------------------------------------------|------------------------------------------------------|----------------------------------------------------|
| `flutter pub get` falla con "Could not find package _macros" | Pins de ADR-0002 no se aplicaron                     | Confirmar `dependency_overrides` en `pubspec.yaml` |
| `flutterfire configure` pide iOS `minimumPlatformVersion` | iOS deployment target demasiado bajo                | Editar `ios/Podfile` → `platform :ios, '12.0'`     |
| Rules del simulador dicen "denied" con un documento que parece válido | Falta algún campo o type check               | Contrastar con [`backend/docs/DB_SCHEMA.md`](../backend/docs/DB_SCHEMA.md) campo por campo |
| App arranca pero `My Articles` está vacío siempre           | DI entró al branch fake (Firebase no inicializado)   | Revisar que `Firebase.initializeApp` corrió antes de `initializeDependencies()` |
| El botón Publish no se habilita                              | `canSubmit` false                                    | Título ≥ 5 chars, contenido ≥ 50 chars, thumbnail picked |
| PR falla con conflict en `pubspec.lock`                     | Alguien mergeó algo antes                            | `git pull --rebase origin main`, correr `flutter pub get`, commit nuevo `chore(deps): resync lockfile` |

Cualquier otro issue: consultar [`docs/SOLUCION.md` §11 (Q&A)](./SOLUCION.md#11-preguntas-anticipadas-y-respuestas-qa) antes de abrir hilo en Slack.
