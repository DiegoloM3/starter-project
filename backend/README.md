# Firebase Firestore Backend
In this folder are all the [Firebase Firestore](https://firebase.google.com/docs/firestore) related files. 
You will use this folder to add the schema of the *Articles* you want to upload for the app and to add the rules that enforce this schema. 

## DB Schema
**TODO: ADD YOUR DB SCHEMA (SCHEMA FOR "ARTICLES" AND ANY OTHER SCHEMAS) HERE**

## Getting Started
Before starting to work on the backend, you must have a Firebase project with the [Firebase Firestore](https://firebase.google.com/docs/firestore), [Firebase Cloud Storage](https://firebase.google.com/docs/storage) and [Firebase Local Emulator Suite](https://firebase.google.com/docs/emulator-suite) technologies enabled.
To do this, create a project but enable only Firebase Cloud Storage, Firebase Firestore, and Firebase Local Emulator Suite technologies.


## Deploying the Project
In order to deploy the Firestore rules from this repository to the [Firebase console](https://firebase.google.com/)  of your project, follow these steps:

### 1. Install firebase CLI
```
npm install -g firebase-tools
```
### 2. Login to your account
```
firebase login
```

### 3. Add your project id to the .firebasesrc file 
This corresponds to the project Id of the firebase project you created in the Firebase web-app.
[Change project id](.firebaserc)

### 4. Initialize the project
```
firebase init
```

You should leave everything as it is, choose:
- emulators
- firestore
- cloud storage

### 5. Deploy to firebase
```
firebase deploy
```
This will deploy all the rules you write in `firestore.rules` to your Firebase Firestore project.
Be careful becasuse it will overwrite the existing firestore.rules file of your project.

## Automated security rules tests

Requirements: Node.js 20 or newer, Firebase CLI (validated with 15.30.1),
and Java 21 on `PATH`. No Firebase login or real credentials are needed.
From `backend`, run:

```sh
npm ci
npm test
```

`npm test` uses `firebase emulators:exec` with `firebase.test.json` to start
Firestore (18080) and Storage (19199), run the native Node.js test runner,
and stop the emulators. The test configuration loads the same rules and indexes,
disables the UI, and uses dedicated hub/logging ports (14400/14500) so a manual
session on 8080/9199/4000 can remain running. Initial execution may download
emulator binaries. The command explicitly selects
`demo-symmetry-rules`, overriding the default project in `.firebaserc`.
Tests also require that demo project and localhost emulator environment variables;
running the test file directly fails before any SDK requests are made.

The tests use unauthenticated clients, reset both emulators between tests, and
cover public reads, valid creates, required/extra fields, types, string limits,
thumbnail URLs, server timestamps, publication dates, image MIME types,
exact upload paths, size boundaries, and denied updates/deletes. Fixtures used by
read/update/delete tests are created through the same rules, so a missing object
cannot accidentally satisfy a denied-operation test.

Storage cleanup traverses the explicit demo bucket recursively under the test
library's local rules-disabled context. In version 5.0.2, `clearStorage()` lists
only root-level objects, leaving nested fixtures behind; using it initially
caused cross-test interference after replacement protection was added.

Current contract and limitations:

- Creation is public under the current rules; tests do not add authentication.
- Firestore checks the thumbnail URL's HTTPS Firebase Storage domain, not the
  bucket, object existence, or association with the article ID.
- Storage checks declared MIME metadata and byte size, not image decoding.
  Upload fixtures use synthetic bytes for that reason.
- The size limit is inclusive: `5 * 1024 * 1024` bytes (5 MiB).
- Storage paths are checked structurally; the rules do not require a corresponding
  Firestore article. Cross-service consistency and orphan cleanup are not enforced.
- Emulator results validate local rules; they do not verify a deployed project,
  production indexes, Flutter integration, or real image rendering.

Reference: [Firebase rules testing documentation](https://firebase.google.com/docs/rules/unit-tests).

The first emulator run passed 51/52 tests: uploading to an existing object path
unexpectedly succeeded despite `allow update: if false`. Storage now explicitly
requires `resource == null` on creation to prevent replacement. This preserves
the intended immutable-file contract; the replacement test remains an assertion
that the operation must fail. See the
[Firebase Tools overwrite issue](https://github.com/firebase/firebase-tools/issues/10302)
and [Storage rules resource reference](https://firebase.google.com/docs/reference/security/storage).

Validation on 2026-09-17: `npm test` completed with 52/52 passing tests
(40 Firestore, 12 Storage), using Firebase CLI 15.30.1 and Java 21.
Both test emulators shut down automatically. `git diff --check` also passed.

## Publication persistence integration tests

Run `npm run test:integration` here for JavaScript SDK service integrations and
emulator safety checks. No new dependencies are needed. The command starts BOTH
emulators with `firebase.test.json` and `demo-symmetry-rules`, ignoring the real
default project in `.firebaserc`. The original `npm test` remains the 52-test
rules suite. Run these commands sequentially because they share emulator ports.

These are not Flutter end-to-end tests. A negative cross-service test verifies
that the actual Storage emulator URL is rejected by the existing Firestore HTTPS
rule. The HTTPS fixture in isolated Firestore tests is never downloaded and does
not represent an uploaded image.

See [publication persistence validation](docs/PUBLICATION_PERSISTENCE_VALIDATION.md)
for coverage, safeguards, results and the pending Android/Console checklist.

## Running the project in a local emulator
To run the application locally, use the following command:

```firebase emulators:start```
