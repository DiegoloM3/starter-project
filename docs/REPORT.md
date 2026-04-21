# Applicant Showcase App — Delivery Report

## 1. Introduction
I'm a frontend engineer with 5+ years of experience shipping production apps in React, Next.js, Angular, and Tailwind. In my previous role I picked up Angular on the job and ended up as the only frontend engineer — and the only designer — on the team. That meant owning the full loop: joining product and client calls to gather requirements, translating them into designs, making the architectural calls, and shipping the code. I'm comfortable learning a new framework under pressure and taking full ownership of the outcome.

Flutter was new to me. I told Diego up front that I didn't know it, and the plan was to use the challenge itself as the learning sprint. I came back from a trip on Monday, so the real runway was effectively one day of hands-on build time. I did learn the framework — the widget model, BLoC, Clean Architecture layering, Firestore rules, Floor — but one day wasn't enough to hand-write every line at a quality bar I'd sign off on. In the spirit of Symmetry's "Truth is King" value, I'm disclosing upfront that I used an AI pair programmer to close the gap between what I'd learned and what the timebox demanded.

What I optimized for: a working vertical slice with rigorous layer separation, not a pixel‑perfect clone of the Figma prototype. Every architectural decision, rule conflict, scope cut, and line that shipped passed through my judgment — the AI handled typing velocity and syntactic translation, I owned the design. That mirrors how I'd work in any modern fast‑paced environment: leverage the tools available, stay accountable for the result.

## 2. Learning Journey
Most of the concepts in this stack weren't new — only the Flutter-specific syntax was. Mapping what I already knew to Dart/Flutter was the fastest way through:

- **Flutter / Dart** — the widget tree maps cleanly onto React's component tree. `StatelessWidget` / `StatefulWidget` / `HookWidget` are just the class-based / stateful / hooks flavors I've used in React. `Navigator` is a routing stack, `Scaffold` / `Form` are layout primitives, `FutureBuilder` is a declarative async render. Dart itself reads like TypeScript with a stricter null-safety story. The pubspec/analyzer workflow is effectively `package.json` + ESLint.
- **flutter_bloc** — I've built Redux, NgRx, and Zustand stores; BLoC is the same shape. `Bloc` (event → state) is a reducer with effects; `Cubit` (methods → state) is the lighter "store-with-methods" pattern. `BlocProvider` scoping is React Context with a lifecycle. `BlocBuilder` / `BlocConsumer` / `context.read` / `context.select` are the same selector/subscription primitives. Sealed state hierarchies are the discriminated unions I'd reach for in TypeScript.
- **Firebase** — I've shipped against Firestore + Storage before, so the document/collection/subcollection model and the server-timestamp patterns were familiar. Firestore Security Rules were the one genuinely new DSL; I learned it by writing the schema validators and testing denials against the live project.
- **The project's own Clean Architecture** — Clean Architecture itself is how I already think about any non-trivial app (one-way dependency, pure domain, presentation is a consumer). The local adaptation I had to internalize was the docs' specific wording: data → domain → presentation one-way, domain is pure Dart (Flutter/pub packages disallowed), `core/` + `shared/` imports permitted by `APP_ARCHITECTURE.md`'s "Exceptions" clause, and only blocs/cubits consume use cases. The three architecture docs (`APP_ARCHITECTURE.md`, `ARCHITECTURE_VIOLATIONS.md`, `CODING_GUIDELINES.md`) were my source of truth — and occasionally conflicted, which is a challenge I cover in §3.

Resources I leaned on, in rough order of time spent:

- The repo's own architecture docs. These had the most signal per minute — they're how a Symmetry PR gets judged.
- The official Flutter docs + the "Flutter Clean Architecture" tutorial referenced in the repo README (for the Dart/widget specifics).
- `bloclibrary.dev` for flutter_bloc idioms.
- Firebase's rules playground for iterating on the Firestore/Storage rules.

My workflow was: read the layer rules → sketch the vertical slice on paper → implement domain with pure Dart types and mock data → add presentation and cubits against that → wire the real Firebase data layer last. That mapped directly onto the build order the docs prescribe, and it paid off — by the time I touched Firestore/Storage, the rest of the app was already functional against mocks, so rules denials and schema bugs were the only class of error left to chase.

## 3. Challenges Faced

- **Doc vs. doc conflict on the business layer.** `APP_ARCHITECTURE.md:107-108` has an "Exceptions" clause allowing `core/` and `shared/` imports from any layer, but `ARCHITECTURE_VIOLATIONS.md:24` says the business layer must never import any project module except dart libraries. Read literally against each other, these contradict. Another rule, `1.4.3` ("ALWAYS RETURN `DataState<T>` when requesting data from an API"), is only satisfiable if the domain repository interface can reference `DataState<T>` — which lives in `core/resources/`. So the only reading that satisfies the maximum number of rules is: APP_ARCHITECTURE's exceptions clause is load‑bearing, and 2.1.1 means "no imports from layers below/above the domain, and no Flutter/pub packages" rather than its literal "no project imports at all." I committed to that reading, made `DataState<T>` pure Dart (its `error` is a plain `Exception`, not `DioError`), and kept the `UseCase<R, P>` abstraction in `core/usecase/`. Domain is clean of Flutter/pub packages; `core/` stays pure Dart.
- **Presentation touching the composition root.** Several screens were constructing blocs directly via `sl<T>()` from inside `build`. That violates the "presentation only talks to the business layer" rule and couples screens to GetIt. I moved every `BlocProvider`/`MultiBlocProvider` wiring into `config/routes/routes.dart` (and `main.dart` for app‑level cubits), leaving presentation widgets as pure consumers that only use `context.read` / `context.select` / `BlocBuilder`. The composition root became the single place that knows about DI.
- **Clean‑arch pressure vs. 24‑hour clock.** The spec's natural build order is domain → presentation → data, which is the slowest path to a demo. I stuck with it because the evaluation is architecture‑first, and cutting that corner would have been the wrong optimization. I compensated by cutting breadth: a vertical slice (upload article, list my articles, detail view with comments, feed merging, auth gate) instead of a pixel‑perfect port of the full Figma prototype.
- **Mirror‑structure test requirement.** The architecture doc requires `test/` to mirror `lib/` with a `{fileName}_test.dart` per file. With the time box, I generated stubs for the whole tree and wrote real tests for the pieces where they earn their keep first (`remote_article_bloc`, `comment_model`). The skeleton makes it obvious where coverage is still missing and keeps me honest about owing those tests.
- **Analyzer noise from generated code.** `retrofit_generator` emits an unused optional `baseUrl` parameter in `news_api_service.g.dart`. Instead of suppressing with an inline ignore (which rots silently), I excluded generated files (`**/*.g.dart`, `**/*.freezed.dart`, `**/*.mocks.dart`) from the analyzer at the project level. `flutter analyze` is clean.

## 4. Reflection and Future Directions

**What I learned.** I now have a working mental model for Flutter + BLoC + Clean Architecture. More importantly, I internalized what the pattern is actually protecting you from: once the domain is genuinely pure Dart, swapping the data source (REST → Firestore → fake for tests) becomes a one‑file change instead of a cross‑cutting refactor. The discipline pays back within hours, not weeks.

**On reading the docs.** Several of the architecture rules conflict if read in isolation (most notably 2.1.1 vs. 1.4.3 vs. the exceptions clause). Picking the interpretation that satisfies the most rules simultaneously — instead of picking one rule and declaring the others "wrong" — is itself part of the job. I'd codify this reading in the docs so the next contributor doesn't rediscover the conflict.

**On AI leverage.** Delegating typing to an AI does not remove the need for engineering judgment — it amplifies it. Every layer boundary, every nullable, every error contract still had to be decided by me. The quality bar moved from "can you write this" to "can you specify and review this correctly and quickly." That matches how I'd want to work at Symmetry.

**Future directions for the project.**

- **Offline‑first for user articles.** The existing Floor/SQLite local cache is only wired for saved API articles. Extending it to user articles would make the app usable on flaky connections, with a sync reconciliation pass on reconnect.
- **Optimistic UI on comments and article delete.** Right now the cubits wait for Firestore to confirm before updating state. Optimistic application with rollback on failure would make the UX feel native.
- **Author denormalization strategy.** Articles currently embed author name/photo as a denormalized snapshot, refreshed via `RefreshAuthorSnapshotsUseCase` after profile edits. A Cloud Function that fan‑outs profile changes to every authored article would move this off the client and eliminate the "stale snapshot" window.
- **End‑to‑end tests on the critical flow.** The unit tests cover the bloc in isolation; a widget + integration test that drives the upload → feed → detail path against the Firebase emulator would catch regressions the unit layer can't see.
- **Design system extraction.** Typography, spacing, and color values are inlined in widgets. Extracting a `ThemeExtension`-backed design system would make future UI work much cheaper and keep the "senior‑engineer smell test" passing.

## 5. Proof of the Project

Demo artifacts (screenshots and a short screen recording) live under `docs/screenshots/`. The vertical slice the video walks through:

1. Email/password sign‑up and sign‑in through the auth gate.
2. Creating an article with a thumbnail upload to Firebase Storage and metadata in Firestore.
3. The new article appearing in the merged feed alongside the News API articles, sorted by publish time.
4. Opening a user article, reading the rich‑text content, and leaving threaded comments.
5. Editing and deleting a user's own article, with Firestore rules blocking edits from other users.


## 6. Overdelivery

### 6.1 New features beyond the brief

- **Threaded comments on user articles** (`features/comments/`) — full Firestore‑backed comment feature with replies, author identity snapshots, soft‑delete ("Comment deleted." placeholder so thread shape is preserved), and rules that prevent comment edits after publish while still allowing authors to delete. The author of an article can reply to comments on their own article but not leave top‑level comments, which nudges conversations in a clearer direction than a free‑for‑all thread.
- **Auth gate with profile editing** (`shared/auth/`) — email/password sign‑in/sign‑up, display‑name and password updates, and profile‑photo uploads to Firebase Storage. Profile changes fan out to the author's existing articles through `RefreshAuthorSnapshotsUseCase` so bylines don't go stale.
- **Rich‑text article composer** — `flutter_quill` integration for authoring, with delta JSON persisted in Firestore and a graceful fallback to plain text when old content can't be parsed as deltas.
- **Merged feed** — `DailyNews` merges the News API feed and user‑published articles into a single timeline sorted by `publishedAt`, so the journalist's own work sits alongside the external news rather than being hidden behind a separate tab.
- **Web + desktop support** — the local SQLite cache is gracefully disabled on web (no sqlite there), and the "Saved Articles" entry is hidden on that platform rather than crashing at runtime.

### 6.2 Prototypes and architectural decisions

- **Pure‑Dart domain and `core/`.** The domain layer imports nothing from outside `domain/` and `core/`, and `core/` itself is pure Dart (no Flutter/pub packages). Transport errors from the data layer (e.g. `DioError`, `FirebaseException`) are translated at the repository boundary into domain exception hierarchies (`ArticleException`, `AuthException`, `CommentException`, `UploadArticleException`) and wrapped inside `DataFailed<T>` for API calls. The rule of thumb worth codifying: "no `package:` imports under `domain/` except pure‑Dart stdlib and `package:equatable`" — enforceable via a custom lint.
- **Presentation decoupled from DI.** All `sl<T>()` calls now live in exactly three files: `injection_container.dart` (the container), `main.dart` (app‑level cubits), and `config/routes/routes.dart` (per‑route bloc scoping). Presentation widgets are pure consumers. This makes screen‑level widget tests trivial: you wrap the widget in a test `BlocProvider.value` with a fake cubit and you're done.
- **Schema design** — `backend/docs/DB_SCHEMA.md` describes the Firestore model: `articles/{id}` with denormalized author snapshots for cheap read paths, `articles/{id}/comments/{id}` as a subcollection so comment rules inherit naturally, and Cloud Storage paths (`media/articles/{authorUid}/{articleId}/…`) aligned to the rules so a single ownership check gates both systems.

### 6.3 How this could be pushed further

- Port the domain‑purity rule into a custom analyzer plugin (dart `analyzer` + custom_lint) so the build fails the moment someone adds a `package:` import under `domain/`.
- Add a Firebase emulator‑backed integration test suite running in CI, driven by Flutter's integration test harness. The unit tests cover bloc logic in isolation; emulator tests would cover the rules + schema contract.
- Introduce a lightweight "feature router" abstraction so new features register their routes and DI bindings from a single file, instead of editing both `injection_container.dart` and `routes.dart` on every feature.
- Adopt `freezed` for entities and states. The current hand‑rolled `Equatable` props get verbose as the app grows.

## 7. Extra Sections

### 7.1 Compliance snapshot

- **Layer violations:** none detected. Domain imports only `domain/` + `core/` (both pure Dart, no Flutter/pub packages). Equatable was removed from every domain entity and params class; `==` / `hashCode` are hand‑written with `dart:core`'s `Object.hash`. Data → domain only. Presentation → domain only. Composition root (`injection_container.dart`, `main.dart`, `config/routes/routes.dart`) is the only place that touches GetIt.
- **Provider imports (1.2.4 / 1.4.4):** `package:firebase_*`, `package:cloud_firestore`, and `package:dio` are only imported from `data/data_sources/` and the composition root. Repositories, models, use cases, blocs, and domain are all provider‑free. `DioError` translation was pushed into a new `NewsApiDataSource`; `FirebaseException`/`FirebaseAuthException` translation was pushed into the firestore/auth/storage data sources, each of which rethrows a domain exception.
- **Architecture rules applied:** 1.3.1 (models extend entities), 1.3.2 (`toEntity()` on every model), 1.3.3 (`fromRawData` factory on every model, with `fromJson` kept only as a thin alias for retrofit‑generated code), 1.4.1 (repo impls named `{Interface}Impl`: `ArticleRepositoryImpl`, `AuthRepositoryImpl`, `CommentRepositoryImpl`, `UserArticleRepositoryImpl`), 1.4.3 (API repos return `DataState<T>`), 2.1.1 (domain free of Flutter/pub imports), 2.3.x / 2.4.x / 3.x satisfied.
- **Coding guidelines applied:** CG 3.5 is enforced on both constructors and methods. Every constructor with ≥3 collaborators is packed into a single deps struct (`SessionDeps`, `ProfileDeps`, `MyArticlesDeps`, `CommentsDeps`, `LocalArticleDeps`, `UserArticleRepositoryDeps`). Every method with ≥3 args is packed into a Params/Request DTO — `UploadArticleParams`, `UpdateArticleParams`, `AddCommentParams`, `DeleteCommentParams`, `ListArticlesParams`, `AuthCredentials`, `PasswordChange`, `ProfilePhoto`, `ArticleCreateRequest`, `ArticleUpdateRequest`, `ThumbnailUploadRequest`, `AvatarUploadRequest`. CG 5 (single responsibility): the original 8‑dep `AuthCubit` was split into a `SessionCubit` (4 session‑lifecycle deps) and a `ProfileCubit` (4 profile‑update deps). The remaining 4‑dep structs are a deliberate tradeoff against 2.3.1 (single‑operation use cases) — further splitting would fragment UI state.
- **Test mirror:** `test/` now mirrors `lib/` per `APP_ARCHITECTURE.md:47`. Real tests live where they earn their keep (`comment_model_test.dart`, `remote_article_bloc_test.dart`); the remaining files are stubs that make missing coverage visible.
- **Analyzer:** `flutter analyze` → `No issues found!` after excluding generated files (`**/*.g.dart`, etc.) from analysis at the project level.
- **Tests:** `flutter test` → all passing.

### 7.2 Heads-up: leaked NewsAPI key

Flagging this as a neighborly courtesy, not a fix I made: `frontend/lib/core/constants/constants.dart:2` hardcodes a personal NewsAPI key that's committed to the repo — anyone who clones it can burn your newsapi.org quota. It's your key, so I left it alone; I'd rotate it and read it from `--dart-define` at build time.

### 7.3 What I'd do differently on day one of a real Symmetry engagement

- Start with the analyzer/lint setup and the domain‑purity check. Those guardrails are what make clean architecture self‑enforcing instead of aspirational.
- Invest in the Firebase emulator + integration tests earlier. Unit‑testing blocs in isolation is cheap; catching rule/schema drift is what actually protects production.
- Keep a running `docs/DECISIONS.md` log. Several of the decisions in this report (strict vs. lenient business‑layer rule, pure‑Dart domain errors, composition‑root‑only DI) are exactly the things a future contributor will want to see reasoned through, not reverse‑engineered from git blame.

Thank you for the opportunity. I enjoyed this challenge a lot more than I expected to, and I'd love to keep building at this pace with this team.
