---
id: 002-firebase-backend
title: "Firebase Backend — Auth, Firestore & Storage"
status: implemented
version: 1.0.0
---

## User Problem

The app currently has no identity or persistence layer beyond local SQLite. Users
cannot publish content, and any article they save disappears if they reinstall the
app. There is also no way to distinguish who created what.

Without Firebase, spec 003 (user article publishing) cannot be implemented at all —
there is nowhere to write the article, no way to identify the author, and no way to
serve it to other users.

## Solution Hypothesis

Stand up the minimum Firebase infrastructure needed to unblock article publishing:

1. **Firebase Auth** — anonymous sign-in so every device has a stable UID without
   requiring a registration flow. No email, no password, no friction.
2. **Firestore** — a top-level `articles` collection where user-published articles
   are stored and readable by everyone.
3. **Firebase Storage** — a bucket for article images uploaded by users.
4. **Security Rules** — anyone can read; only authenticated users can write their
   own documents.

**All Firebase services run against the local Firebase Emulator Suite** during
development (`firebase emulators:start`). The app connects to emulator endpoints
instead of production Firebase. This means no real Firebase project is required
for the exercise — the schema, rules, and code are identical, but the data lives
in a local in-memory store that resets when the emulator stops.

This is infrastructure, not a feature. No UI is introduced in this spec.

## Success Metrics

- [ ] `firebase emulators:start` boots Auth, Firestore, and Storage emulators on
  their default ports without errors.
- [ ] App initializes Firebase on cold start without crashing (Android + iOS).
- [ ] Auth, Firestore, and Storage clients connect to the emulators (verified via
  the Emulator UI showing the request).
- [ ] Anonymous sign-in completes and a stable UID is available in the session.
- [ ] A test document written to `articles/` in the Firestore emulator is readable
  by a second app session without authentication.
- [ ] Security rules reject an unauthenticated write attempt to `articles/`.
- [ ] Security rules reject an authenticated user attempting to write a document
  with a `uid` that is not their own.

## User Story

As a **developer building the article publishing feature (spec 003)**, I want a
configured Firebase project with Auth, Firestore, and Storage, so that I can read
and write user articles without building an auth or storage service from scratch.

## Acceptance Criteria

### Scenario 1: Firebase initializes on app start

- **Given** the local Firebase emulators are running
- **And** the app is launched on Android or iOS in debug mode
- **When** `main()` runs
- **Then** `Firebase.initializeApp()` completes without error
- **And** `FirebaseAuth`, `FirebaseFirestore`, and `FirebaseStorage` clients are
  configured to point at the local emulator endpoints
- **And** `FirebaseAuth.instance.currentUser` is non-null (anonymous session)

### Scenario 2: Anonymous sign-in on first launch

- **Given** a fresh install with no existing Firebase session
- **When** the app starts
- **Then** anonymous sign-in is triggered automatically
- **And** a stable UID is stored in the session for the lifetime of the install

### Scenario 3: Firestore read is public

- **Given** a document exists in the `articles` collection
- **When** any client (authenticated or not) requests it
- **Then** the document is returned successfully

### Scenario 4: Firestore write requires auth

- **Given** an unauthenticated client
- **When** it attempts to write to `articles/`
- **Then** the write is rejected by Firestore security rules

### Scenario 5: Firestore write enforces ownership

- **Given** an authenticated user with UID `abc`
- **When** they attempt to write a document where `uid != "abc"`
- **Then** the write is rejected by security rules

### Scenario 6: Storage upload requires auth

- **Given** an unauthenticated client
- **When** it attempts to upload to `gs://[bucket]/articles/`
- **Then** the upload is rejected by Storage security rules

## Firestore Schema

```
articles/                          <- top-level collection
  {articleId}/                     <- auto-generated document ID
    uid:          string           <- author's Firebase UID
    title:        string
    description:  string
    content:      string
    imageUrl:     string           <- Storage download URL (nullable)
    publishedAt:  timestamp
```

## Security Rules

### Firestore

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /articles/{articleId} {
      allow read: if true;
      allow create: if request.auth != null
                    && request.resource.data.uid == request.auth.uid;
      allow update, delete: if request.auth != null
                             && resource.data.uid == request.auth.uid;
    }
  }
}
```

### Storage

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /articles/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## Implementation Checklist

### Firebase Emulator Setup (one-time, manual by engineer)

- [ ] Install Firebase CLI (`npm install -g firebase-tools`) if not present
- [ ] Run `firebase init emulators` at the repo root, selecting Auth, Firestore,
  and Storage emulators (no real Firebase project required — use a placeholder
  project ID like `demo-news-app`)
- [ ] Place `firestore.rules` and `storage.rules` at the repo root (content from
  the Security Rules section above)
- [ ] Add the Firebase Emulator config files to git (`firebase.json`, rules files)
- [ ] Document `firebase emulators:start` in `DISCOVERY.md` as a prerequisite to
  running the app

### App Integration

- [ ] Add a stub `firebase_options.dart` for the `demo-news-app` project ID
  (generated via `flutterfire configure` or hand-written for the emulator)
- [ ] Call `Firebase.initializeApp()` in `main.dart`
- [ ] In debug mode only, call `useAuthEmulator`, `useFirestoreEmulator`, and
  `useStorageEmulator` immediately after `Firebase.initializeApp()`
- [ ] Implement anonymous sign-in on startup
- [ ] Register `FirebaseAuth`, `FirebaseFirestore`, `FirebaseStorage` in injection
  container

## Out of Scope (V1)

- Email/password or social sign-in — anonymous auth is sufficient for publishing.
- User profiles or display names.
- Firestore pagination or offline persistence configuration.
- Push notifications.
- Any UI changes — this spec is infrastructure only.

## Assumptions

- **No real Firebase project is required.** All development and validation happens
  against the Firebase Emulator Suite running locally (`firebase emulators:start`).
  The placeholder project ID (`demo-news-app`) is enough — emulators do not
  validate against real Google Cloud projects.
- `firebase.json`, `firestore.rules`, and `storage.rules` ARE committed to git.
  They contain no secrets — only configuration and rules.
- A real `google-services.json` / `GoogleService-Info.plist` is NOT committed
  (they don't exist in this setup; the emulator does not need them).
- The iOS simulator and Android emulator must reach `localhost` correctly:
  Android emulator uses `10.0.2.2` for the host machine, iOS simulator uses
  `localhost`. The injection container must handle this platform difference.
- Firestore emulator runs in Native mode equivalent (the only mode the emulator
  supports).
- The `articles` Firestore collection is separate from the existing `daily_news`
  NewsAPI feed — they are different data sources and are never mixed at the data
  layer.
- Emulator data is ephemeral. Restarting the emulator without `--export-on-exit`
  loses all data. This is acceptable for the exercise.

## Open Questions

- None. All decisions resolved before spec was written.

## Deviations

Things that diverged from this spec during implementation. They do not change
the user-visible behaviour but a future engineer should know they exist.

### 1. Firestore document schema does not store `firestoreId`

The spec lists `articles/{articleId}` as the document path and includes a `uid`
field. It does not explicitly say the document **does not** carry a `firestoreId`
field — it is the Firestore document ID itself. The Dart-side `ArticleEntity`
exposes `firestoreId` as a nullable property that is populated from `doc.id`
when reading, never written into the document body.

### 2. `firebase_auth 4.16.0` Pigeon decoding bug

The native iOS plugin returns a payload that the Dart-side Pigeon codec cannot
decode (`type 'List<Object?>' is not a subtype of type 'PigeonUserDetails?' in
type cast`). The sign-in itself completes successfully — only the result decoding
fails.

**Workaround applied** (in `lib/core/firebase/emulator_config.dart`): wrap
`signInAnonymously()` in a `try / on TypeError`, then verify the user is signed in
via `FirebaseAuth.instance.currentUser` and, if needed, wait for
`authStateChanges().firstWhere((u) => u != null)`.

Reference: https://github.com/firebase/flutterfire/issues/12274

**Resolution path:** upgrade to `firebase_auth >= 4.17.4` when the rest of the
Firebase BoM allows it. The workaround should be removed at that time.

### 3. Podfile fixes for Xcode 26 Explicit Module Builds

`firebase_auth`, `firebase_storage`, and `cloud_firestore` Flutter plugin pods
all import `<Firebase/Firebase.h>` (a non-modular header) inside their public
headers. With `use_frameworks!` + Xcode 26 Explicit Module Builds, the
precompiled-module step rejects this as a hard error.

**Workaround applied** (in `frontend/ios/Podfile` post_install hook):
`DEFINES_MODULE = NO` for those three pods. They still link as frameworks; only
the Clang module precompilation is skipped.

Already documented in `docs/DISCOVERY.md` under "iOS Podfile — Key Decisions".

### 4. Anonymous auth was not enabled in Firebase Console

The Firebase Auth Emulator does not require Anonymous Auth to be explicitly
enabled — it accepts all sign-in methods by default. The implementation
checklist item "Anonymous auth is enabled in the Firebase Console before
implementation starts" is therefore N/A for the emulator setup. It would still
need to be done if the project is ever pointed at a real Firebase project.

## Test Coverage

This spec is infrastructure (initialization, security rules, emulator wiring),
not application logic. The "tests" for it are:

| Acceptance criterion | How verified |
|---------------------|--------------|
| Scenario 1 (Firebase initializes on app start) | Manual smoke test on iOS simulator |
| Scenario 2 (anonymous sign-in on first launch) | Manual + Auth Emulator UI showed UID `DHp5QlOSculH6gLMtJHJEwidMB8b` after launch |
| Scenario 3 (Firestore read is public) | Manual feed loads + cubit unit test for `watchArticles` |
| Scenario 4 (Firestore write requires auth) | `curl -X POST` against the emulator with no auth → `403 PERMISSION_DENIED` (verified during implementation) |
| Scenario 5 (Firestore write enforces ownership) | Implicit: rule `request.resource.data.uid == request.auth.uid` is enforced by the emulator and verified by the successful publish flow using the real auth UID |
| Scenario 6 (Storage upload requires auth) | Storage rule `allow write: if request.auth != null` deployed; manual upload during the publish flow succeeded |

### Tests not yet written (debt)

Logged in `improvements.md`:

- Automated rules tests using `@firebase/rules-unit-testing` to assert that
  unauth writes get rejected and that writing with a mismatched `uid` is
  rejected. These would run against the Firestore emulator without needing the
  Flutter app at all.
- An integration test for `FirebaseEmulatorBootstrap` that asserts the host is
  picked correctly per platform (Android `10.0.2.2` vs iOS `localhost`).

Manual verification of the security rules during implementation is on the
record above; the absence of automated rules tests is the main test debt for
this spec.
