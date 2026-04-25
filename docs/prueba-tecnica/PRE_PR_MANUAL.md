# Trabajo manual previo al PR

> **Propósito.** Lista de acciones que un humano debe ejecutar **antes** de abrir el Pull Request desde `chore/modernization` hacia `main`. Todo lo automatizable ya está hecho en los commits de la rama; lo que queda aquí son pasos que requieren **interacción con la consola Firebase**, **captura audiovisual**, o **validación manual con el simulador**.
>
> **Estado:** Firebase ya integrado al repo en el commit `ff2b2ed` (`symmetry-test-cf818`): `firebase_options.dart` generado, `google-services.json` presente, `build.gradle` cableado con el plugin, `.firebaserc` apuntando al project real, `Firebase.initializeApp` corriendo en `bootstrap.dart`. Por tanto este checklist **no repite la integración**.
>
> **Tiempo estimado:** 45 — 90 minutos.
>
> **Regla de oro:** ejecutar en orden. La captura de screenshots depende del deploy de reglas; el vídeo depende de las capturas.

---

## Índice

1. [Pre-flight check (5 min)](#1-pre-flight-check)
2. [Deploy de reglas y validación en el simulador (15 min)](#2-deploy-de-reglas-y-validación-en-el-simulador)
3. [Screenshots oficiales (20 min)](#3-screenshots-oficiales)
4. [Vídeo demo ≤ 2 min (20 min)](#4-vídeo-demo--2-min)
5. [Último barrido de calidad (10 min)](#5-último-barrido-de-calidad)
6. [Lanzamiento del PR (10 min)](#6-lanzamiento-del-pr)
7. [Post-merge (5 min)](#7-post-merge)

---

## 1. Pre-flight check

- [ ] `git status` → working tree limpio.
- [ ] `git log --oneline main..HEAD | wc -l` → al menos 64 commits.
- [ ] `cat backend/.firebaserc` → `"default": "symmetry-test-cf818"` (sin TODO).
- [ ] `grep "initializeApp" frontend/lib/bootstrap.dart` → la línea `await Firebase.initializeApp(...)` aparece sin estar comentada.
- [ ] `cd frontend && flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs` → termina sin errores.
- [ ] `flutter analyze` → 0 errors, 0 warnings (6 infos benignos aceptables).
- [ ] `flutter test` → 58 passing o superior, 0 failing.
- [ ] Abrir en GitHub preview: [`docs/REPORT.md`](../REPORT.md), [`docs/SOLUCION.md`](../SOLUCION.md), [`adr/0003-decisiones-consolidadas.md`](./adr/0003-decisiones-consolidadas.md), [`CHANGELOG.md`](../../CHANGELOG.md), [`frontend/README.md`](../../frontend/README.md). Confirmar que los links relativos resuelven y los code blocks están cerrados.

Si algo falla: **no proceder**. Arreglar y volver a 1.

---

## 2. Deploy de reglas y validación en el simulador

El cliente Flutter ya sabe hablar con `symmetry-test-cf818`, pero las reglas todavía viven solo en el repo. Este paso las sube al proyecto y prueba los casos críticos.

### 2.1 Firebase CLI autenticada

- [ ] `firebase login --reauth` si hay más de 24 h desde el último login.
- [ ] `firebase projects:list` → `symmetry-test-cf818` debe aparecer.
- [ ] `cd backend` (importante: el `firebase.json` y las reglas viven ahí).

### 2.2 Deploy de reglas

- [ ] `firebase deploy --only firestore:rules,storage:rules`
- [ ] Salida esperada:
  ```
  ✔ cloud.firestore: rules file firestore.rules compiled successfully
  ✔ storage: rules file storage.rules compiled successfully
  ✔ Deploy complete!
  ```
- [ ] En [console.firebase.google.com](https://console.firebase.google.com/project/symmetry-test-cf818) → **Firestore Database → Rules**: contenido debe coincidir con `backend/firestore.rules`.
- [ ] Misma verificación para **Storage → Rules**.

### 2.3 Prueba de fuego con el simulador de reglas

Guía visual completa con los casos a probar: [`backend/docs/RULES_VISUAL.md`](../../backend/docs/RULES_VISUAL.md).

- [ ] Ejecutar al menos **un caso permitido** y **un caso denegado** por regla (4 pruebas mínimo). Si alguna falla, contrastar con [`RULES_VISUAL.md`](../../backend/docs/RULES_VISUAL.md) y [`backend/docs/DB_SCHEMA.md`](../../backend/docs/DB_SCHEMA.md) campo por campo.

---

## 3. Screenshots oficiales

Objetivo: capturar el flujo end-to-end contra el Firestore real y guardarlo bajo `docs/assets/screenshots/`.

- [ ] `mkdir -p docs/assets/screenshots`.
- [ ] `cd frontend && flutter run --release --dart-define=NEWS_API_KEY=<tu-key>` en el dispositivo/emulador.
- [ ] Capturar (nombrar `NN-nombre.png`):
  - [ ] `01-home.png` — Daily News con FAB "My Articles".
  - [ ] `02-my-articles-empty.png` — Empty state.
  - [ ] `03-editor-empty.png` — Editor con hint de requisitos.
  - [ ] `04-editor-filled.png` — Editor con título, content, thumbnail picked.
  - [ ] `05-my-articles-populated.png` — Lista con ≥ 2 artículos.
  - [ ] `06-detail.png` — `UserArticleDetailPage`.
  - [ ] `07-edit.png` — Editor en modo edición.
  - [ ] `08-delete-confirm.png` — Diálogo de confirmación.
  - [ ] `09-error-state.png` — Modo airplane activado.
  - [ ] `10-dark-mode.png` — Sistema en dark mode.
  - [ ] (Opcional) `11-firestore-console.png` — Documento aparecen en la consola Firebase.
  - [ ] (Opcional) `12-storage-console.png` — Imagen subida en `media/articles/...`.
- [ ] Insertar grid en [`docs/REPORT.md`](../REPORT.md) §5 Proof of the project.

**Atajo:** si el tiempo es corto, priorizar 02, 04, 05, 06 y 10 (cubren el flujo completo + dark mode).

---

## 4. Vídeo demo ≤ 2 min

### 4.1 Guion sugerido

| Tiempo        | Contenido                                                              |
|---------------|------------------------------------------------------------------------|
| 00:00 — 00:20 | Home (Daily News) → FAB "My Articles" → MyArticlesPage vacío          |
| 00:20 — 00:50 | "New" → editor → picker → publish → SnackBar "Article published"       |
| 00:50 — 01:10 | Editar (icon ✏️) → Save changes → SnackBar "Article updated"          |
| 01:10 — 01:30 | Tap card → detail → pop · icon 🗑 → confirm → desaparece de la lista   |
| 01:30 — 01:50 | Toggle sistema a dark mode → recorrer las mismas pantallas             |
| 01:50 — 02:00 | (Opcional) Consola Firebase: documento en Firestore + imagen en Storage |

### 4.2 Herramientas

- **Android:** `adb shell screenrecord /sdcard/demo.mp4 --time-limit 120` o grabador nativo.
- **iOS:** Control Center → botón de grabar pantalla.
- **Web:** OBS, Loom, o Chrome DevTools Recorder.

### 4.3 Checklist post-grabación

- [ ] Duración ≤ 2 min.
- [ ] Ningún email/API key visible en pantalla (usar cuenta de prueba).
- [ ] Sin música con copyright.
- [ ] Guardar en `docs/assets/demo.mp4` **o** subir a Drive/YouTube unlisted y enlazar.
- [ ] Añadir referencia en [`docs/REPORT.md`](../REPORT.md) §5.

---

## 5. Último barrido de calidad

- [ ] `cd frontend && flutter clean && flutter pub get` (build from scratch).
- [ ] `flutter pub run build_runner build --delete-conflicting-outputs`.
- [ ] `dart format --set-exit-if-changed .` → exit 0.
- [ ] `flutter analyze` → 0 errors / 0 warnings.
- [ ] `flutter test --coverage` → 58+ pasando.
- [ ] `grep -R "TODO\|FIXME" frontend/lib` → sin nuevos TODOs sin owner.
- [ ] Regresión mental: arrancar la app una última vez, publicar un artículo, verificar que aparece en Firestore.

---

## 6. Lanzamiento del PR

### 6.1 Push del branch

- [ ] `git push -u origin chore/modernization`.
- [ ] Si hay conflictos con `main`: `git rebase origin/main`, re-ejecutar §5, push. **NO** force push.

### 6.2 Abrir el PR

- [ ] Título: `feat(user_articles): deliver publish/edit/list/delete with clean architecture`
- [ ] Body (HEREDOC listo para copiar):
  ```markdown
  ## Summary
  - Entrega la feature `user_articles` (publicar / editar / listar / borrar)
    con contrato `Either<AppFailure, T>`, persistencia Firestore + Storage
    y fallback a repositorio fake cuando Firebase no está inicializado.
  - Moderniza la plataforma: `freezed`/`json_serializable`/`dartz`/`go_router`,
    design tokens + `ThemeExtension`, CI con analyze/format/test, ADRs
    consolidados.
  - Firebase real (`symmetry-test-cf818`) integrado en el commit ff2b2ed;
    reglas deployadas según §2 del PRE_PR_MANUAL.

  ## Cambios por fase
  - F0 — Firebase (flutterfire configure + deploy reglas)
  - F1 — Modernización técnica (Dart 3.3, very_good_analysis, test tooling, CI)
  - F2 — core/shared + bootstrap (AppFailure, UseCase base, AppLogger)
  - F3 — Design tokens + go_router (overdelivery #15 y #21)
  - F4 — Refactor `daily_news` al nuevo estándar
  - F5 — Backend (schema + firestore.rules + storage.rules)
  - F6 — Domain `user_articles` (entidades, params, 5 use cases + fake repo)
  - F7 — Presentation `user_articles` (2 blocs, 3 páginas, 3 widgets, routes)
  - F8 — Data `user_articles` (Firestore + Storage data sources + repo impl)
  - F9 — QA, REPORT, SOLUCION, ADR consolidado, CHANGELOG, guía visual de reglas

  ## Documentación
  - [docs/REPORT.md](./docs/REPORT.md)
  - [docs/SOLUCION.md](./docs/SOLUCION.md)
  - [docs/prueba-tecnica/adr/0003-decisiones-consolidadas.md](./docs/prueba-tecnica/adr/0003-decisiones-consolidadas.md)
  - [docs/prueba-tecnica/PRE_PR_MANUAL.md](./docs/prueba-tecnica/PRE_PR_MANUAL.md)
  - [backend/docs/RULES_VISUAL.md](./backend/docs/RULES_VISUAL.md) — guía visual de reglas
  - [backend/docs/SCHEMA_RATIONALE.md](./backend/docs/SCHEMA_RATIONALE.md) — argumentación del schema
  - [CHANGELOG.md](./CHANGELOG.md)

  ## Métricas
  - `flutter analyze`: 0 errors, 0 warnings (6 infos benignos)
  - `flutter test`: 58/58 verde
  - 64+ commits atómicos en Conventional Commits

  ## Test plan
  - [ ] Clonar el repo y seguir `frontend/README.md`.
  - [ ] Publicar artículo real → aparece en Firestore console.
  - [ ] Probar las 4 reglas críticas en el Playground (ver §2 de PRE_PR_MANUAL).
  - [ ] Comparar con screenshots en `docs/assets/screenshots/`.

  🤖 Generated with [Claude Code](https://claude.com/claude-code)
  ```
- [ ] Confirmar que el PR apunta a `main`, no al revés.

### 6.3 CI

- [ ] GitHub Actions → `CI` workflow debe pasar automáticamente.
- [ ] Si falla: **no** merge. Commit nuevo (no force push) con el fix.

### 6.4 Auto-revisión

- [ ] Sin archivos binarios accidentales (`.DS_Store`, `.idea/`, `build/`).
- [ ] Sin API keys fuera de `firebase_options.dart` (que son públicas por diseño).
- [ ] TODO/FIXME nuevos tienen owner o ADR.

---

## 7. Post-merge

- [ ] `git checkout main && git pull`.
- [ ] `git tag -a v1.0.0 -m "First delivery of user_articles feature (Symmetry prueba técnica)"`.
- [ ] `git push origin v1.0.0`.
- [ ] GitHub → **Releases** → **Draft a new release** → tag `v1.0.0` → pegar [`CHANGELOG.md`](../../CHANGELOG.md) §1.0.0.
- [ ] Archivar la rama `chore/modernization` con **Delete branch** (history se preserva).

---

## Apéndice — Troubleshooting

| Síntoma                                                                   | Diagnóstico                                                   | Remedio                                                                              |
|---------------------------------------------------------------------------|---------------------------------------------------------------|--------------------------------------------------------------------------------------|
| `flutter pub get` falla con `Could not find package _macros`              | Pins de [ADR-0002](./adr/0002-dependency-version-bands.md) no aplicados | Confirmar `dependency_overrides` en `pubspec.yaml`                                   |
| `firebase deploy` dice "You don't have permission"                        | Cuenta no es owner/editor del proyecto                        | Agregar la cuenta como `Editor` en IAM del proyecto                                  |
| Reglas deploy correcto, pero el cliente sigue usando el fake              | `Firebase.initializeApp` no corrió antes de `initializeDependencies` | Verificar el orden dentro de `bootstrap.dart`                                        |
| Rules Playground dice "denied" con un doc aparentemente válido            | Algún campo fuera de rango (title < 5, content < 50, thumbnailURL sin https) | Contrastar con [`SCHEMA_RATIONALE.md`](../../backend/docs/SCHEMA_RATIONALE.md) campo por campo |
| App arranca pero `MyArticlesPage` vacía siempre                            | DI entró al branch fake (Firebase no inicializado)            | `flutter analyze` + recompile; `bootstrap.dart` debe tener `await Firebase.initializeApp` antes de DI |
| Botón "Publish" no se habilita                                            | `canSubmit` = false                                           | Title ≥ 5 chars, content ≥ 50 chars, thumbnail picked                                |
| PR en conflicto con `main` y `git pull --rebase` genera conflictos en `pubspec.lock` | Alguien mergeó deps antes                                      | Borrar el lockfile, `flutter pub get` regenera, commit `chore(deps): resync lockfile` |

Cualquier otro síntoma: antes de abrir hilo, consultar [`SOLUCION.md §11 Q&A`](../SOLUCION.md#11-preguntas-anticipadas-y-respuestas-qa).
