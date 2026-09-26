# Case Study Symmetry — Technical Report

> **Evidence scope.** This report describes the current worktree and separates current implementation evidence from explicit delivery limitations. It does not claim an Android or iOS build that was not verified or expose credentials. Firebase Hosting was disabled at the applicant's request; no live web demo is claimed. The current web output is `frontend/build/web`.

## 1. Introduction

The project started as a Flutter NewsAPI reader with local article bookmarks. The assignment was to add a Firebase-backed journalist publishing flow while preserving the existing reader. The current implementation separates the two products:

- **Latest News** is the original external NewsAPI flow and bookmark experience.
- **Community** is the Firebase-backed public feed, article detail, authenticated publishing flow, realtime social interaction, and shareable deep-link experience.

The implementation uses Firebase Authentication, the named Enterprise Firestore database `articles`, Cloud Storage, and Flutter Bloc/Cubits. Public readers can browse published Community articles. Authenticated users can publish, like, and comment; article records and thumbnails are immutable after creation.

At the outset, I approached the project as a chance to turn an existing news reader into a complete publishing workflow. The work called for understanding the app's architecture, defining a secure Firebase data model, and connecting it to a usable Flutter interface. I have not included a claim about my prior experience or initial feelings because those are personal details that the implementation cannot establish.

## 2. Learning Journey

The repository demonstrates the following applied learning outcomes. These statements are based on source structure, tests, and validation rather than invented personal history:

| Area | Applied understanding | Evidence |
| --- | --- | --- |
| Flutter and Dart | Feature code is separated into data, domain, and presentation layers; Cubits coordinate state transitions. | `frontend/lib/features/`, `frontend/lib/core/` |
| Firebase | Production and local-emulator runtimes are explicit; Auth, named Firestore, and Storage are initialized before dependency injection. | `frontend/lib/config/firebase_runtime.dart`, `backend/firebase.json` |
| Firestore and Storage | Immutable articles, ownership, bounded queries, thumbnail linkage, likes, and comments are enforced at the rules boundary. | `backend/firestore.rules`, `backend/storage.rules`, `backend/docs/DB_SCHEMA.md` |
| Bloc/Cubit | Publishing, authentication, feed loading, realtime social listeners, crop approval, retry identity, and failure states are modeled explicitly. | `frontend/lib/features/*/presentation/`, focused Flutter tests |
| Browser-specific behavior | Web bookmark persistence, Web Share API fallback, deep-link query parsing, and browser-safe request IDs are tested separately from native paths. | `frontend/lib/features/*/presentation/services/`, `frontend/test/` |

### Reference resources

The project brief and implementation record point to these resources as the learning/reference set. This list describes what each resource supports; it does not invent a personal study log:

| Resource | Applied area |
| --- | --- |
| [Flutter documentation](https://docs.flutter.dev/) | Widget composition, navigation, platform builds, and web output |
| [Flutter and Firebase documentation](https://firebase.google.com/docs/flutter/setup) | Firebase initialization, Auth, Firestore, and Storage integration |
| [Bloc documentation](https://bloclibrary.dev/) | Cubit state transitions and testable presentation logic |
| [Firestore security rules documentation](https://firebase.google.com/docs/firestore/security/rules-structure) | Rule structure, ownership checks, and query constraints |
| [`APP_ARCHITECTURE.md`](APP_ARCHITECTURE.md) and the repository READMEs | Project-specific Clean Architecture, setup, and contribution boundaries |
| [Figma prototype](https://www.figma.com/file/EVpa82aUzPJuJfewjAA5ke/High-Fidelity-Prototype?type=design&mode=design) | Current proportional UI reference |

## 3. Challenges Faced

| Challenge | Resolution | Evidence |
| --- | --- | --- |
| The reader and Community feature need different persistence and provider contracts. | Kept NewsAPI/bookmarks separate from Firebase articles and introduced Community-specific domain contracts and adapters. | `frontend/lib/features/daily_news/`, `frontend/lib/features/community_articles/` |
| Client validation cannot provide security. | Duplicated important invariants in Firestore and Storage rules, including ownership, exact fields, timestamps, path linkage, MIME type, size, and bounded queries. | `backend/firestore.rules`, `backend/storage.rules`, security suite |
| A Firestore write can be acknowledged while a convenience read-back fails. | Treat the acknowledged write as the commit boundary and return a deterministic local fallback; retries reuse request identity and payload hash. | Community Firestore data source and focused tests |
| Browser builds do not behave exactly like VM/native builds. | Added browser-safe request IDs, web bookmark storage, explicit emulator wiring, deep-link tests, and a separate web build validation. | Flutter tests and `flutter build web --release` |
| Users need control over the published crop. | Added a fixed 1.82:1 crop approval step and preserved the previous image when replacement or crop selection is canceled. | Publish screen/domain tests and Figma reference captures |
| Realtime counts must not rely on client-controlled counters. | Likes and comments use Firestore subcollections; listeners derive counts and comments from the server snapshots. Likes are keyed by UID, while comment reads are bounded. | `SocialInteractionsCubit`, `backend/firestore.rules`, security tests |
| A share action must work on both native surfaces and browsers. | Use `share_plus`/Web Share when available, then provide a browser fallback with app links and copy-link behavior. Shared web URLs resolve through `?article=<article-id>`. | Article share service and route/deep-link tests |
| NewsAPI is an external, plan-limited dependency. | Removed the credential from current source/default build, fail closed without a local key, and make Community the honest fallback. | `frontend/lib/core/constants/constants.dart`, NewsAPI data source tests |

## 4. Reflection and Future Directions

The most reusable engineering lessons are to make provider boundaries explicit, treat acknowledged writes differently from read-after-write convenience checks, and validate browser compilation independently from VM tests. Security rules remain the authority even when the client provides fast feedback. The immutable article model also makes ownership and retry identity part of correctness rather than optional optimization.

The next improvements should be prioritized as follows:

1. Add moderation, reporting, and abuse-rate controls before expanding public interaction.
2. Add cursor pagination and observability for feed, likes, comments, uploads, and orphaned thumbnails.
3. Add accessibility checks for the publishing form, crop controls, social composer, and focus order.
4. Refresh screenshots after major UI changes and add device-native validation when the corresponding toolchain is available. The current continuous recording is a mobile-viewport browser demonstration, not a native device build.
5. Verify Android when an Android SDK/Android Studio environment is available. The current `flutter build apk --debug` cannot run because no Android SDK is installed.
6. Keep iOS out of the delivery claim unless a deliberate iOS implementation and toolchain are added.
7. Move any future hosted NewsAPI access behind a provider-approved server-side plan and secret-management boundary; do not put a replacement key in a web client.

## 5. Proof of the Project

The evidence manifest is [`proof/README.md`](proof/README.md). It records MIME types, dimensions, checksums, and evidence status for the three retained visual references and the continuous video.

### Visual references

- [`proof/figma-home.jpg`](proof/figma-home.jpg) — constrained home layout, article rows, and publish FAB.
- [`proof/figma-editor-empty.jpg`](proof/figma-editor-empty.jpg) — empty editor state.
- [`proof/figma-editor-filled.jpg`](proof/figma-editor-filled.jpg) — selected-image editor state.

These are current visual reference captures. They are not a substitute for the automated validation or the live social smoke.

### Video

[`proof/two-browser-live-demo.mp4`](proof/two-browser-live-demo.mp4) is the applicant's 75-second continuous screen recording, showing two independent mobile-viewport Brave windows against local Firebase emulators. It demonstrates the image/crop controls and the eventual convergence of live like and comment counts in both article details. It is not a native mobile recording or a public web deployment.


### Current validation snapshot

| Check | Result |
| --- | --- |
| Flutter analyzer | Clean (`flutter analyze`) |
| Flutter tests | Latest targeted Community/default-key coverage: **13 passed**, plus the configured-key test; full-suite result: **124 passed, 5 skipped** |
| Web release build | Passed; output is `frontend/build/web` |
| Backend install | Clean tracked-lockfile install with `npm ci` |
| Backend rules validation | **8 grouped suites passed** |
| Seed validation | 2 representative DEMO article manifests pass dry-run and CLI checks; no writes by default |
| Live Firebase state | Deployed Firestore rules, `publishedAt DESC` index, and Storage rules match local definitions for `case-study-symmetry` |
| Share/deep-link behavior | Native/platform share path and browser fallback are implemented and covered by focused tests |
| Hosting | Disabled at the applicant’s request; the original assignment does not require public Hosting. Both Firebase Hosting domains returned HTTP 404 after disablement. The local `firebase.hosting.json` remains optional configuration. |
| Android | Not verified; no Android SDK/Android Studio is available and `flutter build apk --debug` exits with `No Android SDK found` |
| iOS | Explicitly unsupported by the current implementation |

## 6. Overdelivery

### 6.1 New Features Implemented

1. **Visible Latest/Community navigation** — the two data sources are discoverable without relying on a title tap.
2. **Authenticated publishing** — email/password authentication protects article creation while Community reads remain public.
3. **Image crop approval** — the user chooses the visible portion of a required image at the fixed published ratio.
4. **Immutable Firebase articles** — Storage and Firestore records use deterministic paths, hashes, server timestamps, and owner rules.
5. **Realtime likes and comments** — UID-keyed likes, author-owned comments, bounded comment reads, deletion ownership, and snapshot-driven counts.
6. **Native and fallback sharing** — platform share/Web Share where available, plus browser app-link and copy-link actions when it is not.
7. **Shareable web deep links** — `?article=<article-id>` resolves to a public Community detail route after a fresh web load.
8. **Idempotent publishing** — deterministic request IDs and payload hashes make identical retries safe and changed payloads distinguishable.
9. **Production/emulator separation** — production rules reject loopback URLs; the emulator overlay is local-only.
10. **Web bookmark persistence** — the original NewsAPI bookmark behavior has a web-compatible local data source without changing the native Floor contract.
11. **Honest NewsAPI failure mode** — no credential is present in current source/default builds; the no-key web build opens Community and Latest remains unavailable by design. Any old exposed key requires owner rotation, and the Developer plan is not a hosted-production license.
12. **Runnable DEMO seed and backend proof** — 2 representative, clearly labeled synthetic articles, deterministic payload checks, and eight grouped security-rule suites.

### 6.2 Prototypes Created

No separate UML or visual prototype is claimed beyond the supplied Figma direction. The following runnable/supporting artifacts serve as implementation prototypes and review aids:

- [`backend/docs/DB_SCHEMA.md`](../backend/docs/DB_SCHEMA.md) — Firestore/Storage article, likes, and comments contract.
- [`backend/tests/security.test.js`](../backend/tests/security.test.js) — emulator security proof.
- [`docs/IMPLEMENTATION_GUIDE.md`](IMPLEMENTATION_GUIDE.md) — architecture and code walkthrough.
- [`docs/CHANGE_INVENTORY.md`](CHANGE_INVENTORY.md) — changed-file inventory and navigation map.
- [`docs/proof/README.md`](proof/README.md) — visual evidence and integrity manifest.
- `backend/seed/seed-community.mjs` — validation-only DEMO dataset, with an explicit apply mode that is not part of ordinary tests.

Run the backend proof with `npm ci`, start the Auth/Firestore/Storage emulators, then run `npm test` from `backend/`. Run the web app with the recipes in [`frontend/README.md`](../frontend/README.md).

### 6.3 How Can This Improve

The overdelivery would become stronger with native-device verification, cursor pagination, moderation/reporting, accessibility audits, orphan-thumbnail cleanup, provider monitoring, and a server-side NewsAPI integration only under an authorized plan. These are future recommendations, not completed claims.

## 7. Extra Sections: Acceptance Gaps and Operational Boundaries

### Platform boundary

Web is the verified demonstration target. Android source/configuration is present, but native build verification is blocked by the missing SDK. iOS is explicitly outside the current implementation scope.

### NewsAPI boundary

The current source/default web build has no NewsAPI key. With no key, the web build opens Community and Latest remains unavailable by design. A local `NEWS_API_KEY` define is intentionally opt-in and is visible in that compiled client. The Developer plan is not licensed for hosted production. Historical repository data may still contain a previously exposed key; its owner must rotate/revoke it. This report does not claim complete historical-secret erasure.

### Firebase/Hosting boundary

Live rules, index, and Storage definitions match the local files. Hosting is disabled at the applicant's request; both Firebase Hosting domains returned HTTP 404 after disablement. A prior public deep-link check is historical evidence only.

Do not deploy without the applicant's explicit authorization. If authorization is granted later, the verified command from the repository root is:

```bash
npx -y firebase-tools@latest deploy \
  --only hosting \
  --config firebase.hosting.json \
  --project case-study-symmetry
```

The root-level config targets `frontend/build/web` directly and keeps Hosting separate from the backend emulator/Firestore configuration.

### Security and scale boundary

The rules enforce ownership and shape but cannot hash Storage bytes or coordinate a cross-service transaction. The current feed is bounded, comments are limited to 100 per list query, and there is no moderation, pagination, rate limiting, or automatic orphan cleanup. These constraints are documented design boundaries, not hidden capabilities.
