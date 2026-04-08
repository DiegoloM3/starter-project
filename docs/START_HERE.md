# START HERE

Entry point for anyone reviewing this submission. Read this first; everything
else linked from here.

## What this project is

A Flutter app for the Symmetry applicant showcase. The base repository was a
news reader (NewsAPI + local SQLite). This submission:

1. Cleans up architecture violations in the existing code.
2. Stands up a local Firebase backend (Auth + Firestore + Storage) via the
   Firebase Emulator Suite.
3. Adds a "Community" feed where users can publish their own articles, with
   optional images.

The work follows Spec Driven Development — every feature has a spec in `specs/`
that was written, accepted, then implemented. See `AGENTS.md` for the protocol.

## How to run it

### Prerequisites

- macOS with Xcode 26.x (iOS) and/or Android Studio (Android)
- Flutter 3.22.2 (pinned via FVM in `frontend/.fvmrc`)
- Firebase CLI (`npm install -g firebase-tools`)
- Java 11+ (for the Firestore emulator)

### One-time setup

```bash
cd frontend
fvm use 3.22.2
PUB_HOSTED_URL=https://pub.flutter-io.cn flutter pub get
cd ios && pod install && cd ..
```

> The `PUB_HOSTED_URL` mirror is used because pub.dev is unreachable from this
> network. Once dependencies are cached you can use `flutter pub get --offline`.

### Every run

Open two terminals:

**Terminal A — Firebase emulators:**
```bash
cd /path/to/starter-project
firebase emulators:start --project demo-news-app
```
Emulator UI: http://localhost:4000

**Terminal B — the Flutter app:**
```bash
cd /path/to/starter-project/frontend

# iOS (iPhone 17 Pro simulator used during development)
flutter run -d {DEVICE_ID_FOR_IPHONE}

# Android (default emulator)
flutter run -d emulator-5554
```

> **Important:** the app expects the emulators to be running. If they are not,
> Firestore reads/writes silently fail with connection errors.

## What you can do in the app

- **Daily News tab** — the original NewsAPI feed (unchanged from the base).
- **Community tab** — feed of user-published articles, real-time via Firestore
  `snapshots()`.
- **FAB (+)** — opens the publish form. Title, description, content, optional
  image from gallery. Hit "Publish" → article appears in the Community feed.

## Where to read next

| If you want to understand... | Read |
|------------------------------|------|
| What the work is supposed to do | `specs/001-architecture-violations/spec.md`, `specs/002-firebase-backend/spec.md`, `specs/003-user-article-publishing/spec.md` |
| What was found in the existing codebase before any changes | `docs/DISCOVERY.md` |
| Honest list of shortcuts taken and known follow-ups | `docs/improvements.md` |
| The collaboration / SDD protocol used | `AGENTS.md` |
| Why the iOS Podfile has manual overrides | `docs/DISCOVERY.md` § "iOS Podfile — Key Decisions" |

## Status of the specs

| Spec | Status | Tests |
|------|--------|-------|
| 001 — Architecture violations | `implemented` | Entity, model, repository unit tests |
| 002 — Firebase backend (emulator) | `implemented` | Manual + cubit tests; rules tests are debt (IMP-003) |
| 003 — User article publishing | `implemented` | Cubit + repository + widget tests; some widget tests are debt (IMP-001) |
| 004 — View and delete your own community article | `implemented` | First spec that shipped with tests written alongside the code |
| 005 — Edit your own community article | `implemented` | Cubit + repository unit tests; widget tests for the edit form are debt (IMP-001) |
| 006 — Refactor presentation widgets to composition | `implemented` | Pure refactor — proved by the existing 41-test suite passing without modification + manual smoke test |
| 007 — Extract widgets to their own files under `widgets/` | `implemented` | Same exception as 006 — pure file move, 41/41 tests pass without modification |

Each spec has a `## Test Coverage` section listing what is covered and what is
not. Items not covered are tracked in `docs/improvements.md`.

## How to run the test suite

```bash
cd frontend
flutter test --no-pub
```

Expected: **41 tests pass** in ~2 seconds.

## Shortcuts taken — read this before judging code quality

Two classes of intentional debt are documented in `docs/improvements.md`:

1. **Tests** were not backfilled to 100% coverage for specs 001-003. The rule
   "tests mandatory" was added to `AGENTS.md` after those specs were already
   implemented. See `DEV-001`. Going forward, every new spec must ship with
   tests.
2. **Workarounds** in production code: a `try / on TypeError` around
   `signInAnonymously()` (DEV-002, `firebase_auth 4.16.0` Pigeon bug) and
   `DEFINES_MODULE = NO` for three Firebase pods in the iOS Podfile (DEV-003,
   Xcode 26 Explicit Module Builds incompatibility). Both have resolution
   paths documented.

## Submission notes for reviewers

- **Authorship transparency**: this submission was built using Claude Code as a
  pair programmer, under the SDD protocol in `AGENTS.md`. The engineer authored
  every spec, took every product decision, and ran every git command. AI was
  the implementation generator, not the architect. Git history reflects this:
  spec commits predate implementation commits.
- **Branch**: `feat/phase-0-specs` is the working branch. `main` carries the
  onboarding/discovery setup. Both should be reviewed.
- **The Firebase emulator is required** to run the app. There is no real
  Firebase project — `demo-news-app` is a placeholder ID that only the
  emulator accepts.
