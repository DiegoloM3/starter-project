# AGENTS.md

Muse Code reads this file as project rules when it runs in this directory.

## Project

- Name: starter-project (Symmetry applicant showcase: Flutter news app + Firebase backend).
- Frontend: `frontend/` (Flutter, `flutter test`, `flutter analyze`).
- Backend: `backend/` (Firestore rules, Storage rules, emulator config; run emulators from `backend/`).

## Architecture

Clean Architecture adapted per `docs/APP_ARCHITECTURE.md`. Every feature is a *clean folder* with exactly 3 layers; `test/` mirrors `lib/` with `{fileName}_test.dart`.

- `lib/config/` — routes, theme.
- `lib/core/` — constants, resources (`DataState`), usecase base, DI.
- `lib/shared/{feature}/` and `lib/features/{feature}/` — each split into:
  - `data/` (`data_sources/`, `models/`, `repository/`): sole layer touching external services (APIs, Firestore, Storage, local DB). Models extend domain entities and expose `toEntity()` + `fromRawData`-style factories. Repository impls are named `{Interface}Impl` and return `DataState<T>`.
  - `domain/` (`entities/`, `repository/`, `use_cases/`): pure Dart, zero project/Flutter imports. Entities hold business logic; each use case is one operation via a `call` method on repository interfaces (never models, never the data layer).
  - `presentation/` (`bloc/`, `screens|pages/`, `widgets/`): UI only. Only blocs/cubits touch use cases; screens use entities; widgets are reusable and logic-free.
- Hard bans (see `docs/ARCHITECTURE_VIOLATIONS.md`): data never imports presentation; domain imports nothing project-internal; presentation never touches data providers; business logic lives outside blocs' UI-state role and outside screens/widgets.
- DI via `get_it` + `injectable` (`frontend/lib/injection_container.dart` + `.config.dart`); Firebase Auth uid is the `users/{uid}` doc id; article cards resolve author avatars live from `users/{authorId}` through the cached repository path.

## Governing Docs (strict)

`docs/*` is binding, not advisory. Before implementing, re-read the docs relevant to the task:

- `docs/APP_ARCHITECTURE.md` — layer contents and communication rules.
- `docs/ARCHITECTURE_VIOLATIONS.md` — numbered bans; treat every `x.y.z` item as a rejection-grade violation.
- `docs/CODING_GUIDELINES.md` — naming, small functions/classes (nesting ≤ 2, SRP), Boy Scout rule.
- `docs/CONTRIBUTION_GUIDELINES.md`, `docs/REPORT_INSTRUCTIONS.md`, `docs/notes.md` — process, report, and environment gotchas.

## Acceptance Criteria

A change is done only if, in addition to the requested behavior working:

1. Every applicable rule in `docs/CODING_GUIDELINES.md` holds (meaningful names, small single-purpose functions/classes, abstract classes isolating change, tests added/updated for touched behavior, integration coverage for changed user journeys).
2. No `docs/ARCHITECTURE_VIOLATIONS.md` item is introduced.
3. Focused tests pass: `flutter test` on the touched area (repo runner is the oracle — never weaken a failing test to get green).
4. `flutter analyze` is clean.

## Commit Discipline

Commit once per finished clean-architecture unit — one commit per completed folder/layer slice, in dependency order:

1. `data/` layer done → commit.
2. `domain/` layer done → commit.
3. `presentation/` pages/widgets done → commit.
4. Tests written/updated → commit.
5. Final bugfixes green (tests + analyze pass) → commit.

Commit messages use the type prefix plus a short description, naming the feature and the layer, e.g. `add: news community feed data layer` or `fix: sidebar avatar fallback`. Never mix layers in one commit; never commit generated code by hand (see below).

## DI Codegen Rule

The sandbox cannot execute Dart (`dart`/`flutter` fail in this environment), so the agent must NEVER run `build_runner` itself. Whenever codegen output is stale or needed (new `@injectable`/`@lazySingleton`, new `@GenerateMocks`, changed entity/model/table fields):

1. Stop and explicitly ask the user to run it: `cd frontend && dart run build_runner build --delete-conflicting-outputs`.
2. Wait for confirmation, then verify the regenerated files (`*.config.dart`, `*.g.dart`, `*.mocks.dart`) contain the expected registrations before continuing.
3. Treat unrelated churn in regenerated files as-is and leave it; only revert a regenerated hunk if it breaks the build.
