# Case Study Symmetry Firebase backend

This directory contains the deployable Firestore and Storage rules, Enterprise index configuration, Firebase Hosting configuration, seed validation, schema documentation, and emulator security tests for the Community article feature.

## Firebase target

- **Project:** `case-study-symmetry`
- **Firestore:** named Enterprise database `articles` in `europe-southwest1`
- **Storage:** `case-study-symmetry.firebasestorage.app`
- **Authentication:** email/password
- **Hosting:** disabled at the applicant’s request; both Firebase Hosting domains return HTTP 404. The root-level `../firebase.hosting.json` is retained for optional, explicitly authorized deployment.

The original NewsAPI/Floor bookmark flow remains separate from this backend. The article, likes, and comments contract is documented in [`docs/DB_SCHEMA.md`](docs/DB_SCHEMA.md).

## Install and local verification

Use the tracked lockfile for a reproducible install:

```bash
npm ci
```

Start the local suite in one terminal:

```bash
npx -y firebase-tools@latest emulators:start \
  --project case-study-symmetry \
  --config firebase.json \
  --only auth,firestore,storage
```

The checked-in configuration uses Auth `9099`, Firestore `8080`, Storage `9199`, and Emulator UI `4000`. Firestore tests explicitly use the named `articles` database; they never target `(default)`.

Run the security rules suite in another terminal:

```bash
npm test
```

The current validation covers **8 grouped security suites**: anonymous bounded feed reads, authenticated article creation, exact schema and timestamp validation, pre-publish auth preflight, immutable article documents, one-like-per-UID enforcement, comment ownership/limits, and Storage path/MIME/metadata/size/ownership enforcement. The positive image fixture is a real tiny PNG.

Rules cannot inspect object bytes or prove that a Firestore document and Storage object exist across services. The client validates raster signatures before upload and uses deterministic retry identity and payload hashes. `tests/firestore.emulator.rules` is an emulator-only overlay for loopback Storage URLs; it is never deployed.

## Seed validation

The default seed command is a local validation-only dry-run. It describes **2 representative DEMO articles**, validates dimensions, ratios, sizes, signatures, lengths, and hashes, and performs no Firebase writes:

```bash
node seed/seed-community.mjs
sh seed/test-cli.sh
```

Applying the seed is intentionally separate and requires explicit authorization and Firebase Admin credentials:

```bash
node seed/seed-community.mjs --apply --project case-study-symmetry
```

Do not run `--apply` as part of ordinary tests or documentation verification. The compact manifest does not delete previously seeded articles that are no longer listed.

## Rules, indexes, and live verification

Review these files together before any infrastructure change:

- `firestore.rules` — immutable articles plus authenticated, owner-scoped likes/comments.
- `storage.rules` — public article-thumbnail reads and authenticated owner-only writes.
- `firestore.indexes.json` — descending `articles.publishedAt` feed index.
- `firebase.json` — named database, emulator ports, and Auth provider for backend/emulator workflows.
- `../firebase.hosting.json` — root-level Hosting target for `frontend/build/web` and the Flutter SPA rewrite.
- `docs/DB_SCHEMA.md` — document and subcollection contract.

The live Firestore rules, `publishedAt DESC` index, and Storage rules were verified against the `case-study-symmetry` project and match the local definitions. No rules, index, Storage, or Hosting deployment is performed by `npm test` or the seed dry-run.

For an explicitly authorized rules/data deployment only:

```bash
npx -y firebase-tools@latest deploy \
  --project case-study-symmetry \
  --only firestore:rules,firestore:indexes,storage \
  --config firebase.json
```

## Firebase Hosting

The root-level [`firebase.hosting.json`](../firebase.hosting.json) targets `frontend/build/web`, ignores configuration/hidden files and `node_modules`, and rewrites unknown paths to `/index.html` for Flutter web deep links. Hosting is currently disabled and both Firebase Hosting domains return HTTP 404. The previous public Community deep-link smoke check is historical evidence, not a current live demo.

Do not deploy without the applicant's explicit authorization. If authorization is granted later, run `flutter build web --release` from the repository root and deploy with:

```bash
npx -y firebase-tools@latest deploy \
  --only hosting \
  --config firebase.hosting.json \
  --project case-study-symmetry
```

## Browser image CORS

`cors.json` is the reviewed configuration for the production Storage bucket. It allows browser `GET`/`HEAD` responses to expose `Content-Type` with a 3600-second cache lifetime. CORS controls response headers only; it does not grant Storage access or bypass Firebase rules/IAM.

After explicit infrastructure authorization, apply and verify it with:

```bash
gcloud storage buckets update \
  gs://case-study-symmetry.firebasestorage.app \
  --cors-file=cors.json

gcloud storage buckets describe \
  gs://case-study-symmetry.firebasestorage.app \
  --format='json(cors)'
```

## Security boundary

The current client source and default web build contain no NewsAPI credential. The optional local `NEWS_API_KEY` define is embedded into a client build and is not a secret-management mechanism. Do not add a Functions proxy, secret, or production key as part of this backend-only configuration. Any historical key in repository history must be rotated by its owner.
