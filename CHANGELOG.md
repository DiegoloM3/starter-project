# Changelog

All notable changes to the Applicant Showcase App are tracked in this
file. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [1.0.0] — 2026-04-24

First delivery of the `user_articles` feature for the Symmetry prueba
técnica. Built on a 10-fase plan tracked in
[`docs/prueba-tecnica/01_PLAN_FASES.md`](./docs/prueba-tecnica/01_PLAN_FASES.md);
every commit on `chore/modernization` corresponds to one of the 56
planned batches.

### Added

- **Feature `user_articles`:** authors can publish, edit and delete
  their own articles. Three screens (`MyArticlesPage`,
  `ArticleEditorPage`, `UserArticleDetailPage`), two cubits/blocs
  (`MyArticlesCubit`, `ArticleEditorBloc`), five use cases, and a
  Firestore-backed repository with automatic fallback to an in-memory
  fake when Firebase isn't initialised.
- **Backend contract:** `articles/{articleId}` collection, schema
  frozen in [`backend/docs/DB_SCHEMA.md`](./backend/docs/DB_SCHEMA.md),
  enforced by [`backend/firestore.rules`](./backend/firestore.rules)
  (ownership, field validation, immutable `authorId`/`publishedAt`)
  and [`backend/storage.rules`](./backend/storage.rules) (5 MiB cap +
  `image/*` only, path restricted to
  `media/articles/{authorId}/{articleId}`).
- **Cross-cutting platform:**
  - `AppFailure` sealed union (network / cache / validation / auth /
    unknown) replacing `DioError` leaks.
  - Base `UseCase<R, P>` returning `Either<AppFailure, R>`.
  - `AppEnv` reading `NEWS_API_KEY` via `--dart-define`.
  - `AppLogger` + global zoned error handlers.
  - `AuthSession` port with `DevAuthSession` stub.
- **Design system (overdelivery):** `AppTheme extends ThemeExtension<AppTheme>`
  driven by four token files (`app_colors`, `app_spacing`, `app_radii`,
  `app_typography`) with `light()`/`dark()` presets.
- **Declarative routing (overdelivery):** `go_router ^14` with typed
  `AppRoutes` helpers; nested routes under `/me/articles`.
- **Tooling:** `very_good_analysis ^6.0.0` with `strict-casts`,
  `strict-inference`, `strict-raw-types`; `freezed` / `json_serializable`
  codegen; `mocktail` / `bloc_test` / `fake_cloud_firestore` /
  `firebase_storage_mocks` test stack.
- **CI:** GitHub Actions workflow running `flutter analyze`,
  `dart format --set-exit-if-changed` and `flutter test --coverage`
  on every push and pull request.

### Changed

- `daily_news` feature refactored to return `Either<AppFailure, T>`
  from every repository method; `freezed` applied to entity, model,
  and bloc states; `MultiBlocProvider` extracted to
  `lib/config/app_providers.dart`.
- `main.dart` reduced to ≤ 10 lines; bootstrap moved to
  `lib/bootstrap.dart`; `MaterialApp` migrated to `MaterialApp.router`.

### Removed

- `DataState<T>` wrapper and its `DioError` dependency.
- Legacy `onGenerateRoute` wiring (`lib/config/routes/routes.dart`).

### Architecture Decision Records

- [ADR-0001 — Lint migration and info-debt budget](./docs/adr/0001-lint-migration-and-info-debt-budget.md)
- [ADR-0002 — Dependency version bands (analyzer + dart_style pins)](./docs/adr/0002-dependency-version-bands.md)

### Delivery metrics

- **56 atomic commits** on `chore/modernization`, conventional-commits
  throughout.
- `flutter analyze`: 0 errors, 0 warnings, 6 infos (all benign, budgeted
  in ADR-0001).
- `flutter test`: 58/58 passing.

[1.0.0]: https://github.com/Symmetry-Institute-GmbH/starter-project-symmetry/compare/main...chore/modernization
