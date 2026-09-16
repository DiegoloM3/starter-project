# Headline News · Flutter frontend

The Android app: a newsprint-styled reader for the NewsAPI headlines plus the articles
journalists publish from the app itself, backed by the Firebase project in [`../backend`](../backend/README.md).

## What the app does

- **Feed.** Top headlines for a default category (US, English) merged with the articles published
  from the app, one numbered list led by the first story. Pull to refresh; the section strip
  changes the default category.
- **Search.** Full-text search on the provider with recent queries and section shortcuts.
- **Reader.** The article with two AI lenses, *Brief it* (three bullets) and *Plain words*
  (the same facts in short sentences), read-aloud with adjustable speed, and a text size stepper.
- **Today's Brief.** Pick topics, swipe through five stories, save or read them, and get a summary.
- **Write.** Publish and edit your own articles with an optional photo. The draft autosaves per
  account. *Ask the editor* proposes headlines and a summary from the body alone.
- **Saved.** Bookmarks stored on the device, per account.
- **Profile and settings.** Display name and photo, theme, text size, reading speed, default
  category. Everything local is scoped to the signed-in account and cleared on sign-out.
- **Accounts.** Email/password and Google sign-in through Firebase Authentication.

## Architecture

Clean Architecture with one folder per feature (`auth`, `daily_news`, `settings`) and three layers
in each: `domain` (entities, repository interfaces, use cases), `data` (models, data sources,
repository implementations) and `presentation` (cubits, screens, widgets). Code two features need
lives under `lib/shared/<module>/` with the same layers (`media` for picked and stored images,
`firebase` for the failure mapper). `lib/core/` holds framework-free plumbing (`DataState`,
`Failure`, `UseCase`). Dependencies are wired once in `lib/injection_container.dart`.

State management is `flutter_bloc` cubits; navigation is `go_router` with session-aware
redirects; bookmarks use Floor over SQLite; settings and drafts use `shared_preferences`.

The project-wide documents live at the repository root:
[Contribution Guidelines](../docs/CONTRIBUTION_GUIDELINES.md),
[Architecture Violations](../docs/ARCHITECTURE_VIOLATIONS.md),
[Coding Guidelines](../docs/CODING_GUIDELINES.md),
[App Architecture](../docs/APP_ARCHITECTURE.md).

## Running the app

Requirements: Flutter 3.41 (stable), an Android device or emulator, and the Firebase project
already configured (`lib/firebase_options.dart` and `android/app/google-services.json` are in
the repository).

The NewsAPI key is supplied at build time so it never sits in the source. Copy
`env.example.json` to `env.json`, put your key in it (the file is git-ignored) and run:

```
flutter pub get
flutter run --dart-define-from-file=env.json
```

Without a key the app still runs; the feed shows the provider error and your own articles.

## Tests

```
flutter analyze
flutter test
flutter test --coverage   # writes coverage/lcov.info
```

Every layer is tested: entities and use cases as plain unit tests, repositories with their data
sources mocked at the SDK seam, cubits by driving them and asserting the states they emit, and
screens with widget tests that tap through the real flows (sign in, publish, read, brief,
settings). Files that only wrap an SDK (Firebase, Dio, the platform plugins) and the
composition root are marked `coverage:ignore-file`; everything inside that boundary sits above
98% line coverage. The same commands run on every pull request through
[GitHub Actions](../.github/workflows/ci.yml).

## Regenerating assets

```
dart run flutter_launcher_icons        # launcher icons from assets/launcher/
dart run flutter_native_splash:create  # splash screens
```

The Floor database code (`app_database.g.dart`) is maintained by hand because the generator
pins an analyzer version the rest of the toolchain has outgrown; see the migration history in
`lib/features/daily_news/data/data_sources/local/migrations.dart`.
