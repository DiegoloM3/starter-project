# Flutter frontend

Case Study Symmetry is a Flutter news reader with a public Firebase Community feed and an authenticated journalist publishing flow. The original Latest News reader and its bookmark persistence remain separate from Community articles.

## Supported delivery scope

- **Web:** verified with the current Flutter web build and browser acceptance flow.
- **Android:** intended target, but an Android build has not been verified because the reference environment did not provide the Android SDK/toolchain.
- **iOS:** not supported by the current implementation; no iOS build is claimed.

The current web output is `frontend/build/web`. The obsolete `build/web-production` path must not be used in delivery documentation or deployment commands.

## Requirements

- Flutter 3.32.1 / Dart 3.8.1, or a compatible stable release
- Chrome for web development and browser verification
- Node.js, Java 21, and the Firebase CLI for local emulator tests
- Android SDK and Gradle only when Android verification is explicitly attempted

## Production Firebase setup

The checked-in public client configuration targets Firebase project `case-study-symmetry`, the named Enterprise Firestore database `articles` in `europe-southwest1`, and its linked Storage bucket. It contains no passwords or service-account credentials. Production Firebase is the default runtime:

```bash
cd frontend
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d chrome
```

The publish flow uses Firebase email/password authentication. Published Community reads are public; creating an article, like, or comment requires authentication. Article documents and thumbnails are immutable after creation.

## Local emulator mode

Emulator mode is explicit and never silently replaces production. Start the backend suite in a separate terminal:

```bash
cd backend
npm ci
npx -y firebase-tools@latest emulators:start \
  --project case-study-symmetry \
  --config firebase.json \
  --only auth,firestore,storage
```

Then launch the web client with explicit defines:

```bash
cd frontend
flutter run -d chrome \
  --dart-define=USE_FIREBASE_EMULATOR=true \
  --dart-define=FIREBASE_EMULATOR_HOST=127.0.0.1
```

The app configures Auth on `9099`, named Firestore `articles` on `8080`, and Storage on `9199` before dependency injection accesses provider instances. The emulator-only Storage URL overlay is used only by local backend verification and is never deployed.

## Validation

```bash
cd frontend
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter build web --release
```

Current validation status:

- `flutter analyze`: clean.
- Latest targeted Community/default-key tests: **13 passed**, plus the configured-key test; the full-suite result is **124 passed, 5 skipped**.
- Release web build: passed; output is `build/web`.
- Backend rules suite: **8 grouped suites passed** with `npm ci` and `npm test` against the named Enterprise `articles` emulator workflow.
- Live Firebase verification: local Firestore rules, index, and Storage rules match the deployed definitions; the 12-article DEMO seed validates without writing by default.
- Hosting: disabled at the applicant’s request; both Firebase Hosting domains returned HTTP 404. The root-level `firebase.hosting.json` is optional configuration, not a delivery requirement.

The full technical evidence is in [`../docs/REPORT.md`](../docs/REPORT.md), and the proof manifest is [`../docs/proof/README.md`](../docs/proof/README.md).

## NewsAPI boundary

The current source and default web build contain no NewsAPI credential. The default web build opens Community when no key is provided; Latest remains fail-closed. A developer may use `--dart-define=NEWS_API_KEY=...` for a local-only experiment, but Dart embeds that value into the client bundle and it is visible to anyone who can inspect the build. The NewsAPI Developer plan is not a licensed hosted-production solution. Any previously exposed key must be revoked or rotated by its owner; do not place a replacement key in source, Firebase Hosting, or a public web build.

## Web sharing and deep links

Community article sharing uses the platform share sheet where available. Browsers without a usable Web Share API receive a fallback sheet with WhatsApp, Telegram, email, and copy-link actions. The shared web URL contains `?article=<article-id>`; a fresh web load resolves that ID to the public Community detail route.

## Optional Hosting deployment (currently disabled)

Firebase Hosting was disabled at the applicant’s request. The earlier public verification is historical evidence only; there is no current live web demo.

Do not deploy without the applicant's explicit authorization. If authorization is granted later, rebuild and deploy from the repository root:

```bash
flutter build web --release
npx -y firebase-tools@latest deploy \
  --only hosting \
  --config firebase.hosting.json \
  --project case-study-symmetry
```
