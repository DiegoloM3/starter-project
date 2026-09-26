# Change Inventory and Source Navigation

> **Purpose.** This document is a review map for the current worktree. It identifies changed/new areas and where to inspect the implementation; it is not forensic authorship evidence. A Git diff proves that a file differs from its base, not who wrote each line. Generated outputs, dependency locks, Firebase client configuration, and binary proof artifacts are labeled accordingly.

## Current validation snapshot

| Check | Result |
| --- | --- |
| Flutter analyzer | Clean |
| Flutter tests | Latest targeted Community/default-key coverage: **13 passed**, plus the configured-key test; full-suite result: **124 passed, 5 skipped** |
| Web release build | Passed; output `frontend/build/web` |
| Backend install | `npm ci` passes with tracked `backend/package-lock.json` |
| Backend security validation | **8 grouped suites passed** |
| DEMO seed | 2 representative article manifests pass dry-run/CLI checks; no writes by default |
| Live Firebase | Firestore rules, `publishedAt DESC` index, and Storage rules match local definitions |
| Hosting | Disabled at the applicant’s request; the original assignment does not require public Hosting. Both Firebase Hosting domains returned HTTP 404 after disablement. The local `firebase.hosting.json` remains optional configuration. |
| Android | Unverified; no Android SDK/Android Studio (`flutter build apk --debug` reports `No Android SDK found`) |
| iOS | Unsupported by the current implementation |

## Review order

1. [`frontend/lib/main.dart`](../frontend/lib/main.dart) — startup order.
2. [`frontend/lib/injection_container.dart`](../frontend/lib/injection_container.dart) — GetIt composition root.
3. [`frontend/lib/features/community_articles/domain/`](../frontend/lib/features/community_articles/domain/) — provider-independent contracts.
4. [`frontend/lib/features/community_articles/data/data_sources/community_firestore_data_source.dart`](../frontend/lib/features/community_articles/data/data_sources/community_firestore_data_source.dart) — article write sequence.
5. [`frontend/lib/features/community_articles/presentation/bloc/social_interactions_cubit.dart`](../frontend/lib/features/community_articles/presentation/bloc/social_interactions_cubit.dart) — realtime likes/comments.
6. [`frontend/lib/features/community_articles/presentation/services/article_share_service.dart`](../frontend/lib/features/community_articles/presentation/services/article_share_service.dart) — native/Web Share/fallback behavior.
7. [`backend/firestore.rules`](../backend/firestore.rules) and [`backend/storage.rules`](../backend/storage.rules) — server-side enforcement.
8. [`backend/tests/security.test.js`](../backend/tests/security.test.js) — adversarial rules proof.
9. [`IMPLEMENTATION_GUIDE.md`](IMPLEMENTATION_GUIDE.md) — architecture narrative.
10. [`REPORT.md`](REPORT.md) and [`proof/README.md`](proof/README.md) — evidence and limitations.

## Application source inventory

### Composition, configuration, and shared core

| Path | Responsibility | Review note |
| --- | --- | --- |
| `frontend/lib/main.dart` | Firebase initialization, optional emulator wiring, DI, root Bloc providers, query-based initial route | Provider setup must precede DI |
| `frontend/lib/injection_container.dart` | GetIt registrations for NewsAPI, bookmarks, Auth, Community, and social features | Interfaces are registered before dependent repositories |
| `frontend/lib/config/firebase_options.dart` | Generated public Firebase client options | Generated; not a server credential |
| `frontend/lib/config/firebase_runtime.dart` | Explicit emulator selection and named Firestore configuration | Production is default; emulator mode requires defines |
| `frontend/lib/config/routes/routes.dart` | Home, Auth, publish, article detail, Community detail, and deep-link routes | `?article=<id>` is resolved before `/` |
| `frontend/lib/config/theme/app_themes.dart` | Current visual theme and Figma-oriented palette | Presentation-only |
| `frontend/lib/core/constants/constants.dart` | NewsAPI endpoint and optional empty-by-default local key | No credential is committed in current source |
| `frontend/lib/core/resources/data_state.dart` | Provider-independent success/failure boundary | Keeps Firebase/Dio errors out of domain contracts |

### Authentication

| Path | Responsibility |
| --- | --- |
| `frontend/lib/features/auth/data/data_sources/firebase_auth_data_source.dart` | Firebase email/password adapter |
| `frontend/lib/features/auth/data/repository/auth_repository_impl.dart` | Maps Firebase users/errors to domain types |
| `frontend/lib/features/auth/domain/` | Identity, params, repository contract, sign-in/sign-up/sign-out use cases |
| `frontend/lib/features/auth/presentation/bloc/auth_cubit.dart` | Auth state machine |
| `frontend/lib/features/auth/presentation/screens/auth_screen.dart` | Sign-in/sign-up form and validation |

### Community articles, social interactions, and sharing

| Path | Responsibility |
| --- | --- |
| `frontend/lib/features/community_articles/data/data_sources/article_image_picker_data_source.dart` | Image picker and raster payload extraction |
| `frontend/lib/features/community_articles/data/data_sources/community_firestore_data_source.dart` | Deterministic Storage upload, Firestore article creation/read, server timestamps, retry identity |
| `frontend/lib/features/community_articles/data/data_sources/community_social_firestore_data_source.dart` | Realtime likes/comments snapshots and authenticated mutations |
| `frontend/lib/features/community_articles/data/models/` | Firestore serialization for articles/comments |
| `frontend/lib/features/community_articles/data/repository/` | Article, lookup, and social repository adapters |
| `frontend/lib/features/community_articles/domain/entities/` | Article, image, and comment values |
| `frontend/lib/features/community_articles/domain/params/` | Publish request payload |
| `frontend/lib/features/community_articles/domain/repository/` | Article, lookup, and social contracts |
| `frontend/lib/features/community_articles/domain/usecases/` | Read, publish, image-pick, and social orchestration/validation |
| `frontend/lib/features/community_articles/presentation/bloc/` | Feed, lookup, publish, and social Cubits |
| `frontend/lib/features/community_articles/presentation/screens/` | Feed, detail, deep-link, and publish screens |
| `frontend/lib/features/community_articles/presentation/widgets/` | Community list/article presentation |
| `frontend/lib/features/community_articles/presentation/services/article_share_service.dart` | Native share sheet, Web Share, app-specific fallback targets, clipboard |
| `frontend/lib/features/community_articles/presentation/services/web_share*.dart` | Conditional browser Web Share implementation |

### Original Latest News and bookmarks

| Path | Responsibility |
| --- | --- |
| `frontend/lib/features/daily_news/data/data_sources/remote/news_api_service.dart` | Retrofit HTTP contract |
| `frontend/lib/features/daily_news/data/data_sources/remote/news_api_data_source.dart` | Empty-key fail-closed behavior, envelope parsing, provider/rate-limit errors |
| `frontend/lib/features/daily_news/data/models/` | NewsAPI response/article mapping |
| `frontend/lib/features/daily_news/data/repository/article_repository_impl.dart` | NewsAPI and local bookmark adapter |
| `frontend/lib/features/daily_news/data/data_sources/local/` | Floor/native storage plus web SharedPreferences adapter |
| `frontend/lib/features/daily_news/domain/` | Article entity, repository, and legacy use cases |
| `frontend/lib/features/daily_news/presentation/` | Latest feed, detail, saved articles, and legacy Blocs |

The current source/default web build contains no NewsAPI credential. The public no-key build opens Community; an optional `NEWS_API_KEY` define is local-only and visible in the compiled client. Historical repository data may still contain an earlier key and requires owner rotation; this inventory does not claim complete historical-secret removal.

## Backend inventory

| Path | Responsibility | Status |
| --- | --- | --- |
| `backend/firebase.json` | Named Enterprise database, emulator ports, and Auth provider | Backend/emulator configuration |
| `firebase.hosting.json` | Root-level Hosting target for `frontend/build/web` with Flutter SPA rewrite | Verified deployment configuration |
| `backend/.firebaserc` | Default project `case-study-symmetry` | Project selection |
| `backend/firestore.rules` | Article, likes, comments, ownership, timestamps, query bounds, and immutable writes | Live definition matches local |
| `backend/storage.rules` | Public article-thumbnail reads and authenticated owner-only writes | Live definition matches local |
| `backend/firestore.indexes.json` | Descending `articles.publishedAt` feed index | Live index semantically matches local |
| `backend/cors.json` | Reviewed browser response-header policy | Does not grant Firebase access |
| `backend/docs/DB_SCHEMA.md` | Article, likes, comments, Storage, and failure contract | Schema source for review |
| `backend/package.json` | Pinned test/runtime dependencies and `npm test` script | Tracked delivery config |
| `backend/package-lock.json` | Reproducible npm dependency graph | Tracked and synchronized |
| `backend/seed/seed-community.mjs` | 2 representative DEMO article validation/apply tool | Dry-run default; apply explicit; never deletes omitted articles |
| `backend/seed/manifest.json` | Deterministic seed metadata and hashes | Synthetic content only |
| `backend/seed/test-cli.sh` | CLI safety/dry-run assertions | No Firebase writes |
| `backend/tests/security.test.js` | Eight grouped Firestore/Storage/Auth security scenarios | Emulator-only execution |
| `backend/tests/firestore.emulator.rules` | Loopback Storage URL overlay | Never deploy |

## Tests and generated outputs

| Area | Paths | Evidence |
| --- | --- | --- |
| Flutter unit/widget tests | `frontend/test/` | 13 targeted Community/default-key tests plus configured-key test passed; full-suite result 124 passed, 5 skipped |
| Generated Dart | `frontend/**` files ending `.g.dart`, Firebase options, web shell | Generated; regenerate from source where applicable |
| Backend tests | `backend/tests/` | 8 grouped suites passed with the named `articles` emulator |
| Web build | `frontend/build/web/` | Generated release output; correct Hosting target |

## Documentation and proof inventory

| Path | Purpose |
| --- | --- |
| `README.md` | Original assignment plus current delivery quickstart/status |
| `frontend/README.md` | Frontend setup, emulator mode, tests, platform boundaries, NewsAPI boundary |
| `backend/README.md` | Backend install, rules/tests, seed, Hosting, CORS, deployment boundaries |
| `docs/REPORT.md` | Report sections requested by `REPORT_INSTRUCTIONS.md`, with evidence-based reflection placeholder |
| `docs/IMPLEMENTATION_GUIDE.md` | Architecture, flow, contracts, limitations, and reviewer navigation |
| `docs/CHANGE_INVENTORY.md` | This inventory |
| `docs/proof/README.md` | MIME/dimensions/status/checksums for visual proof |
| `docs/proof/*.jpg` | 3 JPEG Figma visual references |
| `docs/proof/two-browser-live-demo.mp4` | Applicant's continuous two-browser mobile-viewport demonstration; local emulators only |

The proof directory intentionally keeps only the three Figma JPEG references and the continuous two-browser recording. Historical browser and production snapshots are excluded from the delivery evidence set.

## Validation recipes

```bash
# frontend
cd frontend
flutter analyze
flutter test
flutter build web --release

# backend
cd ../backend
npm ci
npm test
node seed/seed-community.mjs

# Optional Hosting deployment from repository root — only with explicit authorization
npx -y firebase-tools@latest deploy \
  --only hosting \
  --config firebase.hosting.json \
  --project case-study-symmetry
```

This command targets `frontend/build/web` through the root-level Hosting configuration. Hosting is currently disabled; do not run it without the applicant's explicit authorization.
