# Report — Symmetry Applicant Showcase App

> Author: Abraham Jiménez · Branch: `chore/modernization` ·
> Delivery window: 72 h

---

## 1. Introduction

I approached this challenge coming from a Flutter/Dart background, with
comfort in clean architecture and BLoC but limited production exposure
to Firestore security rules and Cloud Storage. My first read of the
starter repo revealed the bones of a clean-architecture app
(`features/daily_news/{data,domain,presentation}`) but several gaps
I wanted to close before building on top:

- `DataState<T>` leaked `DioError` into the presentation layer.
- `Firebase.initializeApp` wasn't wired anywhere.
- No `test/` folder, no CI, no lints beyond the old `flutter_lints ^1`.
- Models used manual `?? ''` defaults instead of `json_serializable`.
- No design tokens / ThemeExtension, no declarative routing.

Rather than ship the new feature on top of that, I invested the first
third of the window in a platform pass so the new code wouldn't be
the odd one out.

## 2. Learning Journey

| Technology / Concept | What I needed | What I did |
|---|---|---|
| **`freezed` sealed unions**   | replacing Equatable while keeping dart 3 exhaustiveness | migrated `ArticleEntity`, all bloc states and `AppFailure` |
| **`go_router ^14`**           | declarative nav + typed helpers | built `AppRoutes` helper + nested routes under `/me/articles` |
| **Firestore security rules**  | express "only the author can write, never rewrite `authorId`/`publishedAt`" in the rules DSL | wrote `firestore.rules#isValidArticle` in sync with `backend/docs/DB_SCHEMA.md` |
| **`fake_cloud_firestore`**    | test the repo without touching the cloud | wrote `user_article_repository_impl_test.dart` that round-trips publish/update/delete/upload |
| **`firebase_storage_mocks`**  | ditto for Storage | verified the `media/articles/{authorId}/{articleId}/` path on upload |
| **`very_good_analysis ^6`**   | stricter lints under Dart 3 | adopted + catalogued the remaining info-level debt in [ADR-0001](./adr/0001-lint-migration-and-info-debt-budget.md) |

Primary references: official Flutter docs, `bloclibrary.dev`, Firebase's
rules language reference, and Reso Coder's clean architecture tutorial.

## 3. Challenges Faced

1. **Analyzer / Floor version conflict.** `floor_generator 1.4.x`
   requires `analyzer ^5 || ^6.0.0 <6.5.0`, which neither Flutter
   3.19's toolchain nor `freezed ^2.4.7` agreed with. I pinned both
   `analyzer` and `dart_style` under `dependency_overrides` — the
   reasoning is written up in
   [ADR-0002](./adr/0002-dependency-version-bands.md).

2. **Firebase init blocked at F0.** The challenge window didn't include
   a real Firebase project, so `flutterfire configure` couldn't run.
   Rather than stub `Firebase.initializeApp` into a partially-working
   state, I made the DI container branch on `Firebase.apps.isNotEmpty`:
   real Firestore when available, in-memory fake otherwise. The
   `user_articles` feature therefore runs end-to-end locally without
   credentials while staying one flag away from the real backend.

3. **Article id ↔ thumbnail path coupling.** `firestore.rules` requires
   `data.id == articleId` and `storage.rules` whitelists
   `media/articles/{authorId}/{articleId}/{file}`. That meant the
   thumbnail had to know the id *before* the Firestore document
   existed. I solved it by generating a client-side id in the editor
   bloc on submit and threading it through both `UploadThumbnail` and
   `PublishArticle` (see [commit
   `4a48ebb`](https://github.com/.../commit/4a48ebb)).

4. **Bloc state diffing vs. rapid form input.** Each keystroke was
   emitting a fresh state, which rippled into a noisy `blocTest`. I
   moved the submission-related fields (`status`, `failure`, `saved`)
   into the same `freezed` state as the form fields and used `skip:`
   in `blocTest` to assert only the submission transitions.

## 4. Reflection and Future Directions

**What I'd do next if I had another 24 h:**

- Wire `Firebase.initializeApp` + `FirebaseAuth` anonymous sign-in so
  the fake session gets replaced for real.
- Add `image_picker` behind the existing `ThumbnailPickerService`
  port — the interface is in place; only the platform impl is missing.
- Add a proper widget test for the `ArticleEditorPage` with a fake
  `ThumbnailPickerService`, which will cover the full publish path
  end-to-end (currently the path is exercised only at the bloc layer).
- Integration test against the Firestore emulator in CI.

**What I'm proud of:**

- **Zero `DioError` / `DataState` leaks** above the data layer
  (`grep -R "DioError\|DataState" frontend/lib` returns nothing).
- **Design tokens drive every new widget.** Flipping `AppTheme.dark()`
  repaints the whole feature — I demoed this manually during F3.
- **58 tests green** covering use cases, repository implementations
  (real + fake), cubits, blocs, and a representative widget.
- **56 atomic commits** on a single branch, each one buildable and
  `flutter analyze`-clean, following conventional-commits throughout.

## 5. Proof of the project

*Screenshots and walkthrough live under `docs/assets/` — capturing them
in the challenge window is the one checkbox still pending. Until they
land, the best live demo is running the fake flow locally:*

```bash
cd frontend
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run --dart-define=NEWS_API_KEY=<key>
```

- Tap **"My Articles"** FAB on the home screen.
- Empty state → **"New"** FAB → pick thumbnail (stub provides a 1×1 PNG)
  → fill title/content/tags → **Publish**.
- Back on the list, tap edit → change fields → save.
- Swipe-to-refresh or delete the card.

The entire flow runs against `FakeUserArticleRepository`; once
Firebase init is enabled the same screens talk to Firestore and
Cloud Storage without a line of UI code changing.

## 6. Overdelivery

**Architectural / platform upgrades that weren't strictly required:**

1. **Declarative routing.** Replaced the manual `onGenerateRoute`
   switch with `go_router ^14` plus typed `AppRoutes` helpers. Every
   call site navigates via `context.push(AppRoutes.articleEditorNew())`
   instead of a magic string. Deep-linking (`/me/articles/:id`) works
   out of the box.

2. **Design tokens + `ThemeExtension`.** Four token files
   (`app_colors`, `app_spacing`, `app_radii`, `app_typography`) feed an
   `AppTheme extends ThemeExtension<AppTheme>` class. Widgets consume
   `context.appTheme.spacing.lg` instead of hard-coded constants, and
   `AppTheme.light()` / `AppTheme.dark()` derive from the same tokens.

3. **Strict lints + ADR trail.** Bumped to `very_good_analysis ^6.0.0`
   with `strict-casts`, `strict-inference` and `strict-raw-types` on.
   Every deviation (pinned analyzer, info-level debt budget) is tracked
   in `docs/adr/`.

4. **CI on push + pull_request.** `.github/workflows/ci.yml` runs
   `flutter analyze`, `dart format --set-exit-if-changed`, and
   `flutter test --coverage`. Every one of the 56 commits on this
   branch had to pass this gate.

5. **`AuthSession` port + Firebase-less fallback.** The DI container
   auto-selects `UserArticleRepositoryImpl` vs. `FakeUserArticleRepository`
   based on whether `Firebase.apps.isNotEmpty`. The app therefore runs
   with and without Firebase credentials, without a feature flag the
   developer has to remember to flip.

6. **`_guard` exception-mapper.** A single `_guard<T>` helper in the
   repository translates `FirebaseException` codes
   (`permission-denied`, `unavailable`, `not-found`, …) onto the
   domain's `AppFailure` union. Nothing above the repository ever sees
   a Firebase type.

**Prototypes:**

- [`docs/prueba-tecnica/01_PLAN_FASES.md`](./prueba-tecnica/01_PLAN_FASES.md)
  — a 10-fase execution plan with commit-level batch tables that the
  branch follows commit-for-commit.
- [`backend/docs/DB_SCHEMA.md`](../backend/docs/DB_SCHEMA.md) — a full
  field/constraint catalogue for `articles/{id}`, including a mermaid
  ER diagram and future `comments` / `likes` subcollections that the
  current rules leave headroom for.

**Further improvement ideas:**

- Offline-first reads with `cloud_firestore`'s local persistence +
  `floor` mirror.
- Crashlytics + Performance wired into `AppLogger`.
- Splitting `daily_news` and `user_articles` into `melos` packages so
  each feature can be opened independently.

## 7. Extra — Metrics

| Metric                    | Value at delivery                              |
|---------------------------|------------------------------------------------|
| Commits on the branch     | 56 atomic, conventional-commits                |
| `flutter analyze`         | 0 errors, 0 warnings, 6 infos (all benign)     |
| `flutter test`            | 58 passing, 0 failing                          |
| Files touched             | ~85 across `lib/` and `test/`                  |
| New public classes        | `AppFailure`, `AppTheme`, `AppRoutes`, 5 use cases, 2 blocs/cubits, 3 widgets, 3 pages, 2 data sources, 1 repository impl, 1 auth session |
| Architecture invariants verified via grep | `domain/` never imports Flutter/Firebase; `presentation/` never imports a concrete data source |
