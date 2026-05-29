# Project Report — News App Firebase Implementation

## 1. Introduction

When I first opened the project, I found a standard Clean Architecture Flutter app backed by a REST API with a local Floor database. The challenge was to replace the remote data layer with Firebase (Firestore, Storage, Auth) while maintaining strict architectural boundaries — something that 8 out of 23 previous PRs failed to do. My goal was not just to complete the requirements, but to deliver a production-grade implementation that none of the 23 prior submissions achieved: tested security rules, architecture boundaries enforced and checked in CI, and a complete error-handling pipeline.

## 2. Learning Journey

### Clean Architecture Enforcement
The biggest learning curve was keeping Firebase imports strictly within the data layer. Firestore's `withConverter<T>()` API was essential — it let me keep serialization logic in models and data sources without leaking Firebase types upstream. *Resources:* Reso Coder's [Flutter Clean Architecture tutorial](https://www.youtube.com/watch?v=7V_P6dovixg) (the one this repo's README recommends, which builds this exact project) and the official [Flutter docs](https://flutter.dev/docs).

### Firebase Security Rules
Writing production-grade rules required understanding Firestore's security model deeply: field validation, status transition enforcement, immutable field protection, and server timestamp requirements. I used `@firebase/rules-unit-testing` to test rules against the emulator — something no previous submission did. *Resources:* the [FlutterFire docs](https://firebase.flutter.dev/), Firebase's [Firestore security-rules guide](https://firebase.google.com/docs/firestore/security/rules-structure), and the `@firebase/rules-unit-testing` documentation for the emulator test harness.

### BLoC with Streams
Moving from Future-based data fetching (REST API) to Stream-based real-time updates (Firestore snapshots) required introducing `StreamUseCase<T, P>` and restructuring BLoCs to manage stream subscriptions properly, including cleanup in `close()`. *Resources:* the [BLoC library docs](https://bloclibrary.dev/) and the Kodeco chapter *Managing State with Cubits* recommended in the assignment.

## 3. Challenges Faced

### Boy Scout Rule — Fixing Existing Code
The original `ArticleModel` was missing `toEntity()` and used `fromJson` instead of the project's `fromRawData` convention. `ArticleRepositoryImpl` returned `ArticleModel` to the presentation layer, violating the data/domain boundary. Fixing these without breaking existing tests required careful refactoring.

### Error Handling Pipeline
Building a typed error flow (DataSource throws → Repository wraps `DataFailed` → BLoC emits `Failure` state → UI shows contextual error) required creating `AppException` hierarchy (`NetworkException`, `AuthException`, `StorageException`, `ValidationException`, `NotFoundException`) and an `ExceptionMapper` to convert Firebase/Dio exceptions consistently.

### Security Rules Complexity
Enforcing status transitions (`draft → published → archived`) and immutable fields (`id`, `authorId`, `createdAt`) in Firestore rules while keeping them readable was challenging. The append-only comment pattern (content can't be edited, only soft-deleted) added another layer of complexity.

## 4. Reflection and Future Directions

### What I Learned
- **Discipline > features.** A well-enforced architecture with verified boundaries is more valuable than 10 extra features with import violations.
- **Test your rules.** Security rules are not "set and forget" — they're code and need testing like any other code.
- **Stream lifecycle matters.** Leaked Firestore subscriptions cause real bugs in production (stale data, memory leaks).

### Future Improvements
- **Cloud Functions** for server-side validation, push notifications on new articles, and full-text search (replacing the current client-side filter).
- **Pagination** using Firestore cursors (`startAfterDocument`) for the feed instead of loading all articles.
- **Image optimization** pipeline via Cloud Functions to generate thumbnails at multiple resolutions on upload.
- **Offline-first** with explicit conflict resolution using Firestore's pending writes API.

## 5. Proof of the Project

A full video walkthrough of the final app — and the design prototype described in §6.2 — is available in this shared folder:

**▶️ [Demo video + design prototype (Google Drive)](https://drive.google.com/drive/folders/1B1CdR2p_gDyuVVA2ylihCo4wjyR5uOW0?usp=sharing)**

The recording exercises the core flows end-to-end: sign in / register, create and publish an article with a thumbnail, browse the real-time feed, read an article, comment, save it, and manage drafts.

### Key Screens (demonstrated in the video)
- **Feed** — Real-time article feed with featured card and skeleton loading
- **Create Article** — Full editor with thumbnail picker, auto-save drafts, reading time calculation
- **Article Preview** — Pre-publish preview matching the feed card layout
- **Article Detail** — Full article view with comments section
- **My Articles** — User's articles with status badges (draft/published/archived)
- **Drafts** — Draft management with edit and resume capability
- **Search** — Client-side search filtering by title and description
- **Profile** — User info, navigation to articles/drafts/saved, sign out

## 6. Overdelivery

The core requirement was narrow: *a journalist creates an article with a thumbnail, publishes it to a feed, and reads it.* Everything in §6.1 and §6.2 is additional. A live demonstration of every product feature is included in the walkthrough video linked in §5. Each entry below follows the same shape — **What it does / Why / How it works / Key files** — and every "how it works" was verified against the source, not assumed.

### 6.1 Product features (beyond create + publish + read)

#### 1. Authentication (email/password) with a route guard
- **What.** Email/password sign-up (with display name), sign-in, persistent sessions, and sign-out. An `AuthGate` decides at the root whether to show the app or the login screen.
- **Why.** Every article needs a verifiable author — the rules enforce `authorId == request.auth.uid` — and the ownership model (who can edit/delete/comment) only works if the app knows the current user.
- **How.** `AuthBloc` subscribes to `GetAuthStateChangesUseCase` (a `StreamUseCase`). The data source listens on `FirebaseAuth.userChanges()` (not `authStateChanges()`) so a post-sign-up `updateDisplayName()` propagates immediately. `AuthGate` is a `BlocConsumer`: `AuthAuthenticated` → render `DailyNews` and fire `FeedSubscriptionRequested`; `AuthUnauthenticated`/`AuthFailure` → `LoginPage`; otherwise a spinner. Sign in/up/out flow through their use cases → `AuthRepositoryImpl` → `FirebaseAuthDataSource`.
- **Files.** `lib/features/auth/presentation/pages/auth_gate.dart`, `lib/features/auth/presentation/bloc/auth_bloc.dart`, `lib/features/auth/data/data_sources/firebase_auth_data_source.dart`, `lib/features/auth/domain/usecases/{sign_in,sign_up,sign_out,get_auth_state_changes}.dart`.

#### 2. Article status workflow (draft → published → archived)
- **What.** Every article carries a `status` and may only move along a fixed state machine.
- **Why.** A journalist works privately on a draft, publishes when ready, and retires old pieces without destroying them.
- **How.** `ArticleStatus.isValidTransition(from, to)` allows same→same, `draft→published`, and `published→archived`; everything else is rejected. The BLoC gates on it client-side and `firestore.rules` enforces the identical matrix server-side, so the workflow can't be bypassed by a crafted write.
- **Files.** `lib/features/daily_news/domain/entities/article_status.dart`, `lib/features/daily_news/presentation/bloc/article/create/create_article_bloc.dart`, `backend/firestore.rules`.

#### 3. Debounced autosave of drafts
- **What.** While editing, the draft saves itself a short time after the user stops typing — no explicit "save" tap.
- **Why.** Prevents lost work and makes the editor feel modern; pairs with the live reading-time badge so saving feels responsive.
- **How.** `TitleChanged`, `DescriptionChanged`, `ContentChanged`, `ThumbnailSelected`, and `ThumbnailRemoved` each emit state then `add(AutosaveRequested())`. `AutosaveRequested` is registered with `transformer: debounceRestartable(Duration(seconds: 2))` (debounce 2s + `switchMap`, so only the last keystroke in a burst saves). The first save *creates* the article (capturing the new `articleId`); later saves *update* it. Shared in-flight futures (`_pendingCreate`, `_pendingUpload`) stop a racing autosave and an explicit save from double-creating or double-uploading.
- **Files.** `lib/features/daily_news/presentation/bloc/article/create/create_article_bloc.dart`, `lib/core/utils/bloc_transformers.dart`.

#### 4. Article preview before publishing
- **What.** A full-screen render of the article exactly as it will appear, reachable from the editor before publishing.
- **Why.** Lets the author proofread the rendered result (image, badge, layout) before it goes live.
- **How.** `ArticlePreviewPage` is a pure presentation widget that receives the current `CreateArticleState` directly — no extra fetch or write — and renders it with the same layout as the feed/detail. Returning from it can drive the publish action via `Navigator.pop`.
- **Files.** `lib/features/daily_news/presentation/pages/article_preview/article_preview_page.dart`, consumed from `.../pages/create_article/create_article_page.dart`.

#### 5. Reading-time calculator + badge
- **What.** Computes "N min read" from the body and shows it in the editor and on article views, updating live as you type.
- **Why.** A familiar editorial signal that helps readers triage, and live feedback while writing.
- **How.** `ReadingTimeCalculator.calculate(content)` splits trimmed content on whitespace, divides the word count by **100 words/minute**, takes `ceil()`, and clamps to a minimum of 1. It is recomputed in `_onContentChanged` and persisted as `readingTimeMinutes` (a rules-validated field, min 1). `ReadingTimeBadge` renders it.
- **Files.** `lib/features/daily_news/domain/utils/reading_time_calculator.dart`, `lib/features/daily_news/presentation/widgets/reading_time_badge.dart`.

#### 6. Editing / resuming an existing draft
- **What.** Opening a saved draft re-hydrates the editor with its content so editing continues in place rather than creating a duplicate.
- **Why.** Completes the draft lifecycle: save → leave → return → continue → publish.
- **How.** `LoadExistingDraft` copies the article's `id`, fields, thumbnail URL/path, status, and reading time into state. Because `articleId` is now set, subsequent autosaves take the *update* branch instead of *create*.
- **Files.** `lib/features/daily_news/presentation/bloc/article/create/create_article_bloc.dart`.

#### 7. Saved / bookmarked articles (local device storage)
- **What.** Bookmark articles to a personal list that persists on the device across sessions and offline.
- **Why.** Readers want to keep articles for later, and doing it locally needs no network round-trip.
- **How.** `SavedArticles` uses `LocalArticleBloc` (`GetSavedArticles`/`SaveArticle`/`RemoveArticle`) → `ArticleRepositoryImpl` → `AppDatabase.articleDAO` (Floor/SQLite: `getArticles`/`insertArticle`/`deleteArticle`). The tab refreshes when it becomes active (`didUpdateWidget`). **Note:** this is *local SQLite*, not the Firestore `users/{uid}/savedArticles` subcollection — that subcollection is documented and rule-protected in `DB_SCHEMA.md` as a forward-looking design for cross-device sync (see §6.4).
- **Files.** `lib/features/daily_news/presentation/pages/saved_article/saved_article.dart`, `.../presentation/bloc/article/local/local_article_bloc.dart`, `.../data/data_sources/local/{app_database.dart,DAO/article_dao.dart}`, `.../domain/usecases/{get_saved_article,save_article,remove_article}.dart`.

#### 8. Soft-delete for articles
- **What.** Deleting an article hides it everywhere but keeps the document.
- **Why.** Avoids irreversible loss and keeps each article's comment subcollection referentially intact.
- **How.** `ArticleActionCubit.deleteArticle` (and the delete paths in `UserArticlesBloc`/`DraftsListBloc`) call `DeleteArticleUseCase` → `firestore_article_data_source.deleteArticle()`, which runs `update({'isDeleted': true, ...})`. Every read stream filters `where('isDeleted', isEqualTo: false)`, and the rules make `isDeleted: true` terminal (no un-delete, no later edits) while denying hard deletes entirely.
- **Files.** `.../presentation/bloc/article/action/article_action_cubit.dart`, `.../data/data_sources/remote/firestore_article_data_source.dart`, `.../domain/usecases/delete_article.dart`.

#### 9. My Articles with status-filter tabs
- **What.** A management screen listing the user's own articles with All / Drafts / Published / Archived tabs and per-item actions.
- **Why.** Authors need a hub separate from the public feed.
- **How.** `UserArticlesBloc` subscribes to `GetUserArticlesUseCase(userId)` (real-time stream of the author's non-deleted articles), caches the full list in `_allArticles`, and applies the selected tab **client-side** in `_applyFilter` — so switching tabs is instant with no re-query. Delete uses the soft-delete path.
- **Files.** `.../presentation/pages/my_articles/my_articles_page.dart`, `.../presentation/bloc/article/user/user_articles_bloc.dart`, `.../domain/usecases/get_user_articles.dart`.

#### 10. Drafts page (real-time)
- **What.** A live list of the user's drafts with edit/resume and delete.
- **Why.** Quick access to unfinished work that updates instantly as drafts are created or published elsewhere.
- **How.** `DraftsListBloc` does `emit.forEach` over `GetDraftArticlesUseCase(userId)` — a Firestore stream of docs where `authorId == userId && status == 'draft' && isDeleted == false`, ordered by `createdAt` desc.
- **Files.** `.../presentation/pages/drafts/drafts_page.dart`, `.../presentation/bloc/article/drafts/drafts_list_bloc.dart`, `.../domain/usecases/get_draft_articles.dart`.

#### 11. Search (debounced, restartable)
- **What.** A search tab that filters the feed by title/description as the user types.
- **Why.** Discovery across the merged feed without a network round-trip per keystroke.
- **How.** `SearchArticlesBloc` subscribes once to `GetFeedArticlesUseCase` and caches results. `SearchQueryChanged` runs through a `_debounceRestartable(300ms)` transformer (debounce + `restartable`, so only the last query in a burst executes). Filtering is **client-side**, case-insensitive `contains` on title or description.
- **Files.** `.../presentation/pages/search/search_page.dart`, `.../presentation/bloc/article/search/search_articles_bloc.dart`.

#### 12. Comments (real-time, append-only, soft-delete)
- **What.** Per-article comments shown in real time; authors can delete their own; comment text can never be edited.
- **Why.** Reader engagement, with an append-only + soft-delete model that keeps a tamper-evident thread.
- **How.** `CommentBloc` subscribes to `GetCommentsUseCase(articleId)` — a stream of the `articles/{id}/comments` subcollection filtered `isDeleted == false`, ordered by `createdAt` asc. `AddCommentUseCase` writes a new doc with `FieldValue.serverTimestamp()` (returning a locally-stamped model so the UI never renders a null date); the live stream re-delivers it, so no success state is needed. `DeleteCommentUseCase` sets `isDeleted: true`. Content is never updated → append-only, enforced again in the rules.
- **Files.** `.../presentation/bloc/comment/comment_bloc.dart`, `.../data/data_sources/remote/firestore_comment_data_source.dart`, `.../domain/usecases/{add_comment,get_comments,delete_comment}.dart`.

#### 13. Mixed feed (News API + Firestore published)
- **What.** The feed merges the original News-API articles with user-published Firestore articles into one chronological list.
- **Why.** Preserves the original app's content while seamlessly adding journalist-authored articles, and stays resilient when either source is down.
- **How.** `ArticleRepositoryImpl.getFeedArticles()` first calls `_fetchApiArticlesSafely()` (a `getNewsArticles()` call with a **10s timeout**, returning `[]` on any failure), then streams `getPublishedArticles()`. A `StreamTransformer` maps each Firestore emission through `_mergeSorted(api, firestore)` — Firestore items first, then API, sorted by `publishedAt` desc (null dates sink to the bottom). If the Firestore stream errors, it falls back to the API list when non-empty, else emits `DataFailed`.
- **Files.** `.../data/repository/article_repository_impl.dart` (`getFeedArticles`, `_fetchApiArticlesSafely`, `_mergeSorted`), `.../presentation/bloc/article/feed/feed_bloc.dart`.

#### 14. Thumbnail upload to Firebase Storage
- **What.** Picks a local image, uploads it as the article thumbnail, and stores only the download URL on the article.
- **Why.** The assignment explicitly requires thumbnails to live in Cloud Storage under `media/articles` with just a reference in Firestore.
- **How.** `UploadThumbnailUseCase(articleId, filePath)` → `ArticleRepositoryImpl.uploadThumbnail` (resolves the current `uid`, returns `AuthException` if unauthenticated) → `FirebaseStorageDataSource.uploadThumbnail`, which writes to `media/articles/{uid}/{articleId}/thumbnail` and returns `getDownloadURL()` *after* the upload completes. In the editor the upload is wrapped in a 30s timeout and deduped via `_pendingUpload`. Storage rules validate MIME (`jpeg/png/webp`) and size (≤5 MB).
- **Files.** `.../domain/usecases/upload_thumbnail.dart`, `.../data/data_sources/remote/firebase_storage_data_source.dart`, `.../data/repository/article_repository_impl.dart`, `backend/storage.rules`.

#### 15. Bottom-navigation app shell (IndexedStack) + Profile tab
- **What.** A 4-tab shell — Feed / Search / Saved / Profile — with a global "create" FAB. Profile shows the user identity and links to My Articles, Drafts, Saved, and Sign out.
- **Why.** Standard mobile information architecture; `IndexedStack` keeps each tab's scroll position and stream subscription alive across switches.
- **How.** `DailyNews` holds `_currentTab` and renders an `IndexedStack` of `_FeedTab`, embedded `SearchPage`, embedded `SavedArticles`, and `_ProfileTab`. `_ProfileTab` reads `AuthBloc` for the display name/initials and routes to the management screens or dispatches `AuthSignOutRequested`.
- **Files.** `.../presentation/pages/home/daily_news.dart`.

#### 16. Status badge, dialogs, and empty states
- **What.** A color-coded `StatusBadge` (draft/published/archived), a reusable `EmptyStateWidget`, a `DeleteConfirmationDialog`, and a `StatusChangeDialog`.
- **Why.** Consistent, legible feedback for the workflow and a guard rail in front of destructive/irreversible actions.
- **How.** Stateless presentational widgets driven by entity `status` and callbacks, reused across My Articles, Drafts, Feed, and the editor/preview.
- **Files.** `.../presentation/widgets/{status_badge,empty_state_widget,delete_confirmation_dialog,status_change_dialog}.dart`.

#### 17. Internationalization (EN / ES)
- **What.** Full English and Spanish localization via ARB files and generated `AppLocalizations`.
- **Why.** Broadens the audience and demonstrates a production i18n setup; every UI string is keyed rather than hardcoded.
- **How.** `lib/l10n/app_en.arb` and `app_es.arb` feed Flutter's `gen-l10n` (configured in `l10n.yaml`), producing `app_localizations.dart` + per-locale classes. UI reads `AppLocalizations.of(context)!.<key>`.
- **Files.** `lib/l10n/{app_en.arb,app_es.arb}`, `l10n.yaml`, generated `lib/l10n/app_localizations*.dart`.

#### 18. Skeleton / shimmer loading
- **What.** Shimmering placeholders for the feature card, article tiles, and comment tiles during load instead of spinners.
- **Why.** Lower perceived latency and a more polished first paint.
- **How.** Loading states render `Skeleton*` widgets (e.g. the feed shows one `SkeletonFeatureCard` + several `SkeletonArticleTile`s) built on the `shimmer` package.
- **Files.** `.../presentation/widgets/{skeleton_article_tile,skeleton_feature_card,skeleton_comment_tile}.dart`.

### 6.2 Platform / architecture / quality overdelivery

These are engineering investments rather than user-facing screens — they are the reason the product features above could be added without eroding the architecture.

#### 19. Typed error-handling pipeline (`AppException` + `ExceptionMapper`)
- **What.** Every provider failure becomes a typed domain error that flows DataSource → Repository (`DataFailed`) → BLoC (`*Failure` state) → contextual UI message.
- **Why.** Consistent, testable error semantics with zero leakage of Firebase/Dio types past the data layer.
- **How.** `AppException` (Equatable) plus five subclasses — `NetworkException`, `AuthException`, `StorageException`, `ValidationException` (carries `fieldErrors`), `NotFoundException`. `ExceptionMapper` converts `FirebaseException` codes (e.g. `permission-denied`→`AuthException`, `not-found`→`NotFoundException`, `unavailable`→`NetworkException`, storage codes→`StorageException`) and Dio error types into these. Repositories catch the provider exceptions and wrap them in `DataFailed`; BLoCs never use `try/catch`.
- **Files.** `lib/core/errors/app_exception.dart`, `lib/shared/data/errors/exception_mapper.dart`.

#### 20. `DataState<T>` + `UseCase` / `StreamUseCase` abstractions
- **What.** A uniform success/failure envelope and two use-case contracts — one Future-based, one Stream-based.
- **Why.** Migrating from REST (futures) to Firestore (real-time streams) needed a first-class streaming use-case type while keeping the domain layer free of provider types.
- **How.** `DataState<T>` with `DataSuccess`/`DataFailed`; `UseCase<T,Params>` exposes `Future<T> call({Params params})`; `StreamUseCase<T,Params>` exposes `Stream<T> call({Params params})`. Feed/Published/User/Drafts/Comments/Auth-state use cases implement `StreamUseCase`; CRUD/upload/auth-action use cases implement `UseCase`.
- **Files.** `lib/core/resources/data_state.dart`, `lib/core/usecase/usecase.dart`, `lib/core/usecase/stream_usecase.dart`.

#### 21. Tested Firebase security rules (Firestore + Storage)
- **What.** Production-grade rules enforcing auth, field presence/type/size validation, status-transition and immutable-field rules, terminal soft-delete, and Storage MIME/size — backed by an emulator test suite.
- **Why.** No prior submission tested its rules; rules are code and deserve the same scrutiny.
- **How.** `backend/firestore.rules` and `backend/storage.rules` enforce the schema; `backend/test/firestore.rules.test.js` (62 cases) and `storage.rules.test.js` (19 cases) run against the emulator via `@firebase/rules-unit-testing` — **81 rule tests total**, now also gated in CI (see §6.4 / §7).
- **Files.** `backend/firestore.rules`, `backend/storage.rules`, `backend/test/firestore.rules.test.js`, `backend/test/storage.rules.test.js`.

#### 22. Architecture verification script + CI pipeline
- **What.** A shell script that fails the build on cross-layer import violations, wired into GitHub Actions alongside analyze + test + rule tests.
- **Why.** Enforces Clean Architecture mechanically instead of by code review — the report's central thesis ("discipline > features").
- **How.** `scripts/check_architecture.sh` greps each feature's `domain/` for `data/`/`presentation/`/Flutter/Firebase imports and `presentation/` for `data/` imports (and `print()`), exiting non-zero on any match. `.github/workflows/ci.yml` runs it as the `architecture-check` job, `flutter analyze --fatal-warnings` + `flutter test --coverage` as `analyze-and-test`, and the 81 backend rule tests as the `rules-test` job.
- **Files.** `scripts/check_architecture.sh`, `.github/workflows/ci.yml`.

#### 23. Documented Firestore schema (`DB_SCHEMA.md`)
- **What.** A complete schema doc covering `articles/{id}`, the `comments` subcollection, the `savedArticles` subcollection, field types, required/immutable flags, constraints, composite indexes, and storage paths.
- **Why.** Required by the assignment (§1.1) and serving as the contract the rules enforce.
- **How.** Markdown tables per collection/field with the exact constraints the rules check (e.g. `publishedAt` must equal `request.time` on the draft→published transition; `id`/`authorId`/`createdAt` immutable). Indexes mirror `firestore.indexes.json`.
- **Files.** `backend/docs/DB_SCHEMA.md`, `backend/firestore.indexes.json`.

#### 24. Boy-Scout fixes to inherited code
- **What.** Repaired pre-existing boundary violations in the starter: `ArticleModel` gained `toEntity()` and `fromRawData` (replacing `fromJson`); `ArticleRepositoryImpl` returns entities, not models; `Equatable` props made nullable-safe.
- **Why.** The starter violated the data/domain boundary; fixing it was a prerequisite to passing the architecture check.
- **How.** Models extend entities and expose `toEntity()`; the repository maps models→entities at the boundary; verified by `check_architecture.sh`.
- **Files.** `.../data/models/article.dart`, `.../data/repository/article_repository_impl.dart`.

### 6.3 Prototypes Created

#### High-Fidelity HTML/CSS UI Prototype ("Claude design")

**What it is.** A self-contained, interactive high-fidelity prototype of a proposed UI direction for the app, authored as a single HTML file (inline HTML + CSS, no build step and no dependencies). It was generated with Claude as a fast way to materialize and communicate a visual/UX redesign before committing it to Flutter code.

**Purpose.** To explore an improved look-and-feel beyond the provided Figma and make the proposed direction tangible for reviewers — clickable layouts for the feed, article detail, and the create/publish flow — so the design intent can be evaluated on its own, independent of the running app. This directly answers the challenge's "Maximally Overdeliver" value and its explicit invitation to improve the design.

**Where to find it.** In the same shared folder as the demo video: [Design prototype + demo video (Google Drive)](https://drive.google.com/drive/folders/1B1CdR2p_gDyuVVA2ylihCo4wjyR5uOW0?usp=sharing).

**How to view it (please read — Google Drive does not render HTML).** Google removed direct HTML hosting from Drive, so clicking the `.html` file shows its raw source or prompts a download instead of rendering the page. To see the prototype as intended:

1. Open the Drive folder linked above.
2. Select the `.html` file and **download** it (right-click → *Download*, or the download icon).
3. Open the downloaded file in any browser — double-click it, or drag it onto a browser tab.

The file is fully self-contained, so it renders offline with no server, internet connection, or install required.

### 6.4 How Can You Improve This
- Add widget tests for remaining screens (currently covering feed and article tile).
- Implement Cloud Functions for server-side search and push notifications.
- Add Firestore pagination for large article collections.
- Create E2E integration tests running against Firebase emulators.
- **Reconcile saved-articles persistence.** "Saved" is currently local-only (Floor/SQLite). The Firestore `users/{uid}/savedArticles` subcollection is already designed and rule-protected (see `DB_SCHEMA.md`); wiring a `FirestoreSavedArticleDataSource` to it would add cross-device bookmark sync with no rules work.

## 7. Technical Summary

### Architecture Compliance

All architecture rules from `ARCHITECTURE_VIOLATIONS.md` are enforced:

| Rule | Status |
|------|--------|
| Data layer: no presentation imports | Verified |
| Data layer: no use_case imports | Verified |
| Data sources: only place importing external providers | Verified |
| Models extend entities with `toEntity()` and `fromRawData` | Verified |
| Repository returns `DataState<T>` | Verified |
| Domain: no imports from data/presentation, Flutter, Firebase, Dio, or Floor | Verified |
| Presentation: no direct data layer access | Verified |
| BLoCs interact only with use cases | Verified |

Verification method: `scripts/check_architecture.sh` runs in CI on every push and PR. It enforces the import-direction rules (domain imports nothing from data/presentation or Flutter/Firebase; presentation never imports data; no `print()`). Note on the "only place importing external providers" row: provider **SDK usage** (Firestore, Storage, Floor, Dio, FirebaseAuth) is confined to `data_sources/`; the `RepositoryImpl` files import `firebase_core`/`firebase_auth` only to catch provider **exception types** (`FirebaseException`, `FirebaseAuthException`) as required by the documented error-handling strategy (DataSource throws → Repository wraps in `DataFailed`).

### Project Statistics

| Metric | Count |
|--------|-------|
| Use cases | 20 |
| BLoCs/Cubits | 11 |
| Page files | 12 (~10 user-facing screens) † |
| Entity fields (Article) | 15 |
| Frontend tests | 247 (220 `test` + 27 `testWidgets`) |
| Backend rule tests | 81 (62 Firestore + 19 Storage) |
| Supported locales | 2 (EN, ES) |

† The 12 page files break down as ~10 user-facing screens — Login, Register, Feed tab, Search, Saved, Profile tab, Article Detail, Article Preview, Create/Edit Article, Drafts, My Articles — plus `AuthGate` (a route guard) and `RouteNotFoundPage` (a fallback), which are not screens in the usual sense.
