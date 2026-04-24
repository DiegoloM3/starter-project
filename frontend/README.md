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

### 2. Provide required secrets via `--dart-define`

The NewsAPI key is read through `core/env/app_env.dart` and must be
injected at build time — nothing is hard-coded.

```bash
flutter run \
  --dart-define=NEWS_API_KEY=<your-key>
```

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

| Task                                | Command                                                   |
|-------------------------------------|-----------------------------------------------------------|
| Static analysis                     | `flutter analyze`                                         |
| Auto-format                         | `dart format .`                                           |
| Run tests                           | `flutter test`                                            |
| Run tests with coverage             | `flutter test --coverage`                                 |
| Regenerate freezed / retrofit / g.dart | `flutter pub run build_runner build --delete-conflicting-outputs` |
| Launch app (debug)                  | `flutter run --dart-define=NEWS_API_KEY=xxx`              |

CI mirrors the first three on every push and PR via
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

- [`docs/adr/0001-lint-migration-and-info-debt-budget.md`](../docs/adr/0001-lint-migration-and-info-debt-budget.md)
- [`docs/adr/0002-dependency-version-bands.md`](../docs/adr/0002-dependency-version-bands.md)

And the full fase-by-fase plan lives under
[`docs/prueba-tecnica/01_PLAN_FASES.md`](../docs/prueba-tecnica/01_PLAN_FASES.md).
