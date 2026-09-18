# Publication persistence validation — Phase 5, Unit 6

## Scope

Unit 5 is omitted. No `confirmationPending`, new packages, credentials,
production configuration changes or rule changes are introduced.

The automated service integrations use the existing Firebase JavaScript SDK
(12.19.0). These tests do **not** execute Flutter datasources, repository, GetIt,
native Android plugins or UI. The complete Flutter-to-Firebase publication flow
was therefore validated separately through a controlled manual run on a physical
Android device against the configured Firebase project.

## Repeatable execution and protections

Requirements: Node.js >=20, installed backend dependencies, Firebase CLI, Java 21.

From `backend`, run sequentially:

```sh
npm run test:safety
npm test
npm run test:integration
```

`npm test` runs the original 52 rule tests unchanged. `test:integration` runs 8
safety unit tests and 12 integrations. Expected permission-denied logs belong to
negative assertions; they are not failures when those assertions pass.

Both emulator commands explicitly select `demo-symmetry-rules` and
`firebase.test.json`, which loads the existing rules and indexes. Endpoints:

| Service | Endpoint |
| --- | --- |
| Firestore | `127.0.0.1:18080` |
| Storage | `127.0.0.1:19199` |
| Hub / logging | `14400` / `14500` |
| Bucket | `demo-symmetry-rules.appspot.com` |

The CLI starts/stops both emulators. There is no data import/export. Integration
fixtures use unique IDs and disappear with the disposable emulator run. The new
integration suite does not bypass rules. The old rules suite retains its existing
emulator-only fixture reset mechanism.

Before initializing Firebase, the new integration suite requires the exact demo
project and BOTH emulator environment variables on their specified loopback ports.
Missing, remote or mismatched endpoints fail before Firebase initialization.
Every SDK session explicitly connects both services before any operation. Project
and bucket are fixed test constants, never loaded from `.firebaserc` or production
Flutter options. No Auth, API key or service account is configured.

Before fetching a returned download URL, the test requires HTTP, `127.0.0.1`, port
19199, the demo bucket path, and no user information. Redirects are disabled.
The HTTPS Firestore fixture is never fetched. The safety tests exercise missing
variables, a real-project name, wrong/remote endpoints and unsafe download URLs.
Direct invocation of the integration file without this environment intentionally
fails closed.

## Automated coverage and observed limitation

### Firestore emulator: 6 tests

- Allocate an automatic ID without creating a document.
- Write exactly eight fields with three server timestamps.
- Read using `getDocFromServer` from another SDK app/client, asserting no cached
  data or pending writes. This establishes server persistence beyond one client's
  state, not persistence across emulator restarts.
- Assert resolved timestamps, conversion to JavaScript dates and equality of all
  three timestamps for this immediate-publication workflow.
- Deny update/delete of an existing document and confirm unchanged content.
- Deny missing/extra fields, wrong type and non-server creation timestamp.

The thumbnail HTTPS Firebase Storage URL used by the isolated Firestore tests is a
**schema fixture only**. It has no uploaded object, is never fetched, and is not
end-to-end publication evidence.

### Storage emulator: 5 tests

- Upload a PNG byte fixture to `media/articles/{id}/thumbnail.png`.
- From another SDK app verify bucket, exact path, size, `image/png` metadata and
  exact bytes. Fetch the actual returned local URL and verify bytes/MIME again.
- Assert `storage/object-not-found` for an absent object.
- Deny replacement/deletion of an existing object and confirm it remains readable.
- Deny an invalid path and invalid MIME.

These verify transfer and metadata, not image decoding or the Android gallery.
The existing 52-rule suite also covers JPEG/WebP and the 5 MiB boundaries.

### Cross-service incompatibility: 1 negative test

Upload an image, get its actual URL, and try creating the matching article with
that unchanged URL. The observed URL is `http://127.0.0.1:19199/...`, which fails
the required `https://firebasestorage.googleapis.com/...` pattern. The test asserts
that creation is denied, the article is absent and the uploaded image still exists.

This expected rejection passes the negative test. It is **not** a successful
integral publication. No HTTPS substitution, alternate rule, proxy, mixed real/
emulated service or emulator-specific production branch is used.

### Flutter-to-emulator feasibility

The frontend does not include `integration_test` or a native integration entry
point. No Flutter-to-emulator test was added. Even with such a harness, the
unchanged integral flow would remain blocked by the observed Storage emulator URL
mismatch.

The production implementation was not changed to accommodate emulator behavior.
Instead, the complete Flutter-to-Firebase flow was validated manually against the
configured Firebase project after the emulator-based checks passed.

## Manual Android / Firebase validation

A controlled real-project validation was performed on 2026-09-18 after completing
the automated checks.

### Environment

- Firebase project: `symmetry-technical-test-62d73`.
- Storage bucket: `symmetry-technical-test-62d73.firebasestorage.app`.
- Android application ID: `com.example.news_app_clean_architecture`.
- Device: physical Android device running Android 16 (API 36).
- Build: debug APK generated successfully from the current
  `feature/technical-test` implementation.
- Test image: JPEG selected from the Android gallery.

No Firebase rules, production configuration or application code were changed
during this validation.

### Observed application flow

The publication form was completed and a JPEG image was selected from the Android
gallery. Publishing was triggered once.

The application:

1. Entered its publishing/loading state.
2. Disabled publication-related controls while the operation was pending.
3. Completed the publication without displaying an application error.
4. Returned to Home.
5. Displayed `Article published successfully.`

The existing Home feed remained backed by NewsAPI, so the newly published
Firestore article was not expected to appear in that feed.

### Firestore verification

Firebase Console showed a new document in the `articles` collection after the
publication completed.

The document contained exactly the expected eight fields:

- `author`
- `title`
- `description`
- `content`
- `thumbnailURL`
- `publishedAt`
- `createdAt`
- `updatedAt`

`thumbnailURL` contained a real HTTPS Firebase Storage URL. The three date fields
were stored as Firebase timestamps and resolved to the publication time.

The generated document ID observed during the validation was:

```text
WykV2RmVV6DYSbSqfY0v
```

### Storage verification

Firebase Storage showed a corresponding directory under:

```text
media/articles/WykV2RmVV6DYSbSqfY0v/
```

The Storage article directory therefore used the same generated ID as the
Firestore document, confirming that both persisted resources belong to the same
publication attempt.

### Persistence after application restart

After the successful publication, the Android application was completely closed.
The active `flutter run` debugging session consequently lost its connection to the
device.

The application was then opened again independently on the Android device.
Firebase Console was refreshed after reopening the application.

The same Firestore document and corresponding Storage directory were still
present. This confirms that the uploaded publication data is persisted remotely
in Firebase and is not dependent on the Flutter application's in-memory state or
the active debugging session.

## Test data cleanup

The resources created by this manual validation are test data. After preserving
the required evidence, they may be removed manually from Firebase Console.

Only the resources associated with the recorded test document ID should be
removed:

```text
articles/WykV2RmVV6DYSbSqfY0v
media/articles/WykV2RmVV6DYSbSqfY0v/
```

Existing fixtures such as `sample-article` and unrelated Firebase resources must
not be modified.

Cleanup consists of two separate operations:

1. Delete only the test document from Firestore.
2. Delete only the corresponding test image/object from Storage.

No application delete functionality, rule changes or deployment are required for
cleanup.

## Validation record

Validation completed on 2026-09-18:

- 8/8 emulator safety tests passed.
- 52/52 original Firebase rules tests passed.
- 20/20 new emulator suite tests passed: 8 safety tests and 12 service
  integration tests.
- 171/171 Flutter tests passed.
- `flutter analyze` completed with no analysis errors; existing non-blocking
  diagnostics remain.
- The Android debug APK built successfully.
- The Storage emulator local-URL incompatibility was reproduced and documented
  without changing Firebase rules.
- A real Android publication successfully created the corresponding Firebase
  Storage and Cloud Firestore resources.
- The Firestore document and Storage resource remained present after completely
  closing and reopening the Android application.

The Data Layer publication path is therefore validated both through repeatable
automated checks and through one controlled real-project Android publication.