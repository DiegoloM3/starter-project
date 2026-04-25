# Flutter Frontend

This is the Flutter app that surfaces Symmetry's daily news feed and lets
authenticated users publish their own articles (`user_articles` feature,
added for the 72h prueba técnica).

---

## Running the app

### 1. Install dependencies

```bash
cd frontend
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Provide required secrets via `keys.json` / `keys.local.json`

The NewsAPI key is read through `core/env/app_env.dart` and must be
injected at build time — nothing is hard-coded.

Two files drive the flow:

- **`frontend/keys.json`** — committed template with placeholder values.
- **`frontend/keys.local.json`** — gitignored local copy with your real
  keys. Created on demand via the Makefile target below.

```bash
# From the repo root
make keys                 # one-time: copies keys.json → keys.local.json
# now edit frontend/keys.local.json and replace REPLACE_WITH_YOUR_NEWSAPI_KEY
make run                  # picks keys.local.json automatically
```

If you need to run `flutter run` directly instead of `make`:

```bash
flutter run --dart-define-from-file=keys.local.json
```

The `--dart-define-from-file` flag is supported since Flutter 3.7 and
replaces the older `--dart-define=KEY=VALUE` style. Multiple keys go in
the same JSON file.

### 3. (Optional) Wire Firebase for the user_articles feature

Until `flutterfire configure` has produced a `lib/firebase_options.dart`
and `Firebase.initializeApp` runs in `bootstrap.dart`, the DI container
automatically falls back to an in-memory fake repository
(`FakeUserArticleRepository`). This keeps the app runnable locally and
under CI without requiring Firebase credentials.

To use the real Firestore + Storage backend:

```bash
# Once, to generate firebase_options.dart
dart pub global activate flutterfire_cli
flutterfire configure

# Then enable the Firebase.initializeApp call in bootstrap.dart
# (search for the TODO(F0) block)
```

The emulator workflow is documented in [`backend/README.md`](../backend/README.md).

---

## Development commands

Every common task is wrapped in the root [`Makefile`](../Makefile) so you
don't have to remember flag combinations. From the repo root:

| Task                                | Make target         | Underlying command                                                |
|-------------------------------------|---------------------|-------------------------------------------------------------------|
| Static analysis                     | `make analyze`      | `flutter analyze`                                                 |
| Format check (fails on diffs)       | `make format`       | `dart format --set-exit-if-changed .`                             |
| Auto-format                         | `make format-fix`   | `dart format .`                                                   |
| Run tests                           | `make test`         | `flutter test`                                                    |
| Run tests with coverage             | `make test-coverage`| `flutter test --coverage`                                         |
| Regenerate freezed / retrofit / g.dart | `make codegen`   | `flutter pub run build_runner build --delete-conflicting-outputs` |
| Launch app (debug)                  | `make run`          | `flutter run --dart-define-from-file=<keys file>`                 |
| Full local CI gate                  | `make ci`           | analyze + format + test                                           |
| Deploy Firestore + Storage rules    | `make deploy-rules` | `firebase deploy --only firestore:rules,storage:rules`            |
| Arch invariants grep check          | `make grep-violations` | (combined greps that cross-check domain/data/presentation)     |

Run `make help` to see the full list with any targets added later.

CI mirrors `analyze`, `format` and `test` on every push and PR via
[`.github/workflows/ci.yml`](../.github/workflows/ci.yml).

---

## Project layout (clean architecture)

```
lib/
├── config/
│   ├── app_providers.dart         # MultiBlocProvider root
│   ├── routes/                    # go_router + typed AppRoutes helpers
│   └── theme/                     # design tokens + ThemeExtension
├── core/
│   ├── env/                       # --dart-define readers
│   ├── error/                     # AppFailure sealed union
│   ├── logger/                    # zoned error reporting
│   ├── session/                   # AuthSession port + DevAuthSession stub
│   └── usecase/                   # base UseCase<R, P>
├── features/
│   ├── daily_news/                # pre-existing feature, migrated to Either
│   └── user_articles/             # new feature for the prueba técnica
│       ├── data/                  # Firestore/Storage data sources + repo
│       ├── domain/                # entities, params, usecases (no Flutter/Firebase imports)
│       └── presentation/          # cubits, pages, widgets, services
├── shared/                        # cross-feature UI helpers
├── app.dart
├── bootstrap.dart
├── injection_container.dart
└── main.dart
```

See [`docs/APP_ARCHITECTURE.md`](../docs/APP_ARCHITECTURE.md) and
[`docs/ARCHITECTURE_VIOLATIONS.md`](../docs/ARCHITECTURE_VIOLATIONS.md)
for the invariants each layer must respect.

---

## Architectural decisions

The moves that deviate from the starter skeleton are captured as ADRs:

- [`docs/adr/0001-lint-migration-and-info-debt-budget.md`](../docs/prueba-tecnica/adr/0001-lint-migration-and-info-debt-budget.md)
- [`docs/adr/0002-dependency-version-bands.md`](../docs/prueba-tecnica/adr/0002-dependency-version-bands.md)

And the full fase-by-fase plan lives under
[`docs/prueba-tecnica/01_PLAN_FASES.md`](../docs/prueba-tecnica/01_PLAN_FASES.md).
