# Engineering Decision Log

Decisions taken while building the "journalist uploads their own articles"
feature that are not directly prescribed by `README.md`,
`docs/APP_ARCHITECTURE.md` or `docs/ARCHITECTURE_VIOLATIONS.md`.
This log is the raw material for section 6 of `docs/REPORT.md`.

## Stage 2.1 — Business (domain) layer

### 1. A new clean folder instead of extending `daily_news`
The articles a journalist writes are a different business object from the news
items the app reads from the News API: they are owned by a user, they have a
draft/published lifecycle and they are edited and deleted from inside the app.
Mixing both in `daily_news` would have forced the existing `ArticleEntity` to
grow fields that make no sense for an API article.
The feature therefore lives in `lib/features/journalist_articles/`, with its own
`JournalistArticleEntity`. The two entities are deliberately not shared.

### 2. Folder naming follows the architecture document, not the legacy code
`APP_ARCHITECTURE.md` specifies `domain/use_cases`, while the pre-existing
`daily_news` feature uses `domain/usecases`. The new feature follows the
document (`use_cases`), since the document is the source of truth. The legacy
folder was left untouched to keep the diff of this stage focused.

### 3. `domain/params/` folder
`APP_ARCHITECTURE.md` lists **Params** as a component of the business layer but
its folder tree only shows `entities`, `repository` and `use_cases`. Params
classes were given their own folder (`domain/params/`) rather than being buried
in the use case files, so that each use case input can be tested and reused by
the presentation layer on its own.

### 4. `DataState` no longer depends on Dio
`core/resources/data_state.dart` typed its error as `DioError`, which is a
detail of the News API's HTTP client. The business layer returns `DataState` in
its repository contracts (required by `ARCHITECTURE_VIOLATIONS.md` 1.4.3), so
that type was leaking a data layer provider into the domain, and it cannot
represent a Firestore or Cloud Storage failure at all.
The error is now a plain `Object`. `DioError` instances still flow through it
unchanged, so the `daily_news` feature keeps working.

### 5. `UseCase` takes its params positionally
The core contract was `Future<Type> call({Params params})`. Because Dart does
not allow an override to turn an optional named parameter into a required one,
every use case had to accept `Params?` and force unwrap it (`params!`), pushing
a null check into business logic that can never legitimately receive null.
The contract is now `Future<ReturnType> call(Params params)`, plus a `NoParams`
value for use cases with no input. The four `daily_news` use cases and their two
blocs were migrated (Boy Scout Rule, CG1).

### 6. Mock data lives in an in-memory repository, not inside the use cases
`README.md` 2.1 asks for the use cases to run on mock data. Hardcoding that data
inside the use cases would mean rewriting every use case in stage 2.3, and would
put data fetching inside the business layer.
Instead the mock data lives in
`data/repository/journalist_article_repository_in_memory_impl.dart` and
`data/repository/article_thumbnail_repository_in_memory_impl.dart`, which are
real implementations of the domain contracts. The use cases are already written
in their final form, and switching to Firestore is a two line change in
`injection_container.dart`.
The in-memory implementations simulate latency so the presentation layer can
exercise its loading states. They import no provider and no data source, so they
break no rule of `ARCHITECTURE_VIOLATIONS.md` 1.4.

### 7. Two repository interfaces instead of one
`JournalistArticleRepository` stores article documents, `ArticleThumbnailRepository`
stores binary images. They are backed by two different providers (Firestore and
Cloud Storage) and change for different reasons, so they are two contracts
(CG5: one responsibility per class).

### 8. Business rules mirror the backend rules
`JournalistArticleEntity` enforces the 200/500 character limits documented in
`backend/docs/DB_SCHEMA.md`, and `ArticleThumbnailEntity` enforces the 5 MB
limit and the image formats accepted by `backend/storage.rules`. An invalid
article or image is rejected before it ever leaves the device.
A draft is allowed to be incomplete (only title, author and owner are required);
the full set of rules applies when the article is published, which is why
publishing is its own use case and not a plain update.

### 9. Known inconsistency to fix in the backend
`backend/docs/DB_SCHEMA.md` documents `title` max 200 and `description` max 500
characters, but `backend/firestore.rules` only checks that those fields are
strings. The domain layer enforces the limits today; the rules should enforce
them too, otherwise the documented schema is not actually guaranteed.

### 10. Test helpers
`test/` mirrors `lib/` as required. The hand written test doubles and fixtures
shared by several tests live in `test/helpers/`, which mirrors no production
file by design. Test doubles are hand written so that the project does not gain
a mocking dependency for this stage.

## Stage 2.2 — Presentation layer (skeleton)

### 11. Cubits, not blocs, for the new feature
`README.md` 2.2 recommends cubits and the feature has no event stream worth
modelling: the screens call methods (`loadArticles`, `saveDraft`, `publish`).
The `daily_news` feature keeps its existing blocs. Two cubits cover the
feature: `MyArticlesCubit` (list, filters, publish, delete) and
`ArticleEditorCubit` (write, attach cover, save draft, publish).
Neither holds a business rule: both only translate use case results into UI
state, as required by `ARCHITECTURE_VIOLATIONS.md` 3.2.

### 12. The cubits are injected at the composition root
`BlocProvider` for the new screens lives in `config/routes/routes.dart`, not in
the screens. If a screen called `sl<MyArticlesCubit>()` itself, the
presentation layer would import `injection_container.dart` and, through it, the
data layer. Routing is part of `config`, so it is the natural place to compose
them (`main.dart` already does the same for `RemoteArticlesBloc`).

### 13. Failure wording lives in the presentation layer
The domain reports failures as enums and exceptions with no copy attached.
`ArticleFailureText` turns them into sentences. This keeps the business layer
free of user facing strings and leaves translation as a presentation concern.

### 14. Skeleton UI on purpose
The screens are plain Material widgets wired to the cubits, built to exercise
the whole flow before the Figma prototype is implemented. Two placeholders are
marked in the code and still pending:
- the cover image is a fixed in memory image ("Attach cover"), until an image
  picker is added;
- the journalist identity comes from `kMockJournalistId` / `kMockJournalistName`
  in `core/constants`, until Firebase Authentication is wired.

## Stage 2.2b — Making the project run on a current toolchain

### 15. The starter project cannot build as delivered
Two parts of the repository require Flutter versions that do not overlap:

| File | What it requires |
|------|------------------|
| `frontend/pubspec.yaml` (`sdk: ">=2.16.1 <3.0.0"`) | Dart 2, so Flutter 3.7 or older |
| `frontend/android/settings.gradle` (`dev.flutter.flutter-gradle-plugin`, AGP 8.3.0) | Flutter 3.16 or newer, which ships Dart 3 |

Verified on both sides. With Flutter 3.44 the Dart compilation fails, because pub
resolves `win32 5.3.0`, which calls `UnmodifiableUint8ListView`, removed in
Dart 3. With Flutter 3.7.12 the Gradle build is rejected before it starts:
`AndroidProject._computeSupportedVersion` (`project.dart:465`) only accepts an
`app/build.gradle` that contains `apply from: .../flutter.gradle`, the pre-3.16
layout, and `packages/flutter_tools/gradle/` in that SDK does not even contain
the `dev.flutter.flutter-gradle-plugin` the project asks for.

The Dart side was chosen as the one to move, because the project's own Android
configuration already targets a modern Flutter. Pinning an old SDK with FVM was
evaluated first and discarded: keeping Flutter 3.7.12 would have meant rewriting
`android/` back to the 2022 Gradle layout, a larger change to the delivered
project than upgrading the dependencies.

### 16. Dart 3 migration
- `environment.sdk`: `">=2.16.1 <3.0.0"` → `">=3.0.0 <4.0.0"`.
- `retrofit` `^3.0.1` → `^4.1.0`, and `dio: ^5.4.0` added as a direct dependency:
  the data layer imports `dio` directly, so it must declare it instead of
  relying on it arriving through `retrofit`.
- `floor: any` → `floor: ^1.4.2`. An unbounded `any` constraint lets an
  unrelated upgrade silently change the database layer.
- `flutter_lints`, `build_runner` and the generators moved to current versions.
- `DioError` → `DioException` and `DioErrorType.response` →
  `DioExceptionType.badResponse` in `ArticleRepositoryImpl` (renamed in dio 5).

### 17. `ionicons` removed
`ionicons` extends `IconData`, which is a `final class` in current Flutter, so
the package no longer compiles; its last release does not fix it. Its four icons
were replaced with their Material equivalents in `article_detail` and
`saved_article`, and the dependency was dropped. One unmaintained dependency
less for four icons that Flutter already ships.

### 18. Android build chain
`gradle-wrapper.properties` 8.4 → 8.12 (Flutter 3.44 requires 8.7+),
AGP 8.3.0 → 8.7.3 and Kotlin 1.6.10 → 2.1.0 in `settings.gradle`, since Kotlin
1.6 cannot run on a modern JDK.

Local environment note: Android Studio bundles JBR 25, and Gradle rejects it
(`Unsupported class file major version 69`). The Gradle JDK must be set to 21
in the IDE settings, and `flutter config --jdk-dir` points the CLI at the same
JDK.

### 19. Code generation is currently unavailable
`build_runner` cannot regenerate the `.g.dart` files: `floor_generator 1.5.0`
pins `analyzer: ^6.4.1`, while `retrofit_generator 9+` needs analyzer 7 or
newer, and `retrofit_generator 8.2.1` does not compile under Dart 3.12. The two
generators cannot coexist today.
This does not block the app: both generated files are committed and compile.
It resolves on its own once Floor leaves the project, which is likely, since the
new feature persists through Firestore.

### 20. Verification of this stage
`flutter analyze`: no errors. `flutter test`: 74 passing. `flutter build apk
--debug`: succeeds. The app was installed on an emulator and exercised by hand:
the article list renders the mock articles ordered by date with their status
badges, and publishing an empty article reports the four business rules it
breaks, which shows the domain rules reaching the UI through the cubits.

## Stage 3 — Reader-facing features added on top of the assignment

`README.md` only asks for a journalist to be able to upload an article. Three
features are added here that were not requested but close a gap in, or
directly extend, that reading/writing loop. They are scoped to keep improving
the two people who actually use this app (the reader and the author), not to
add anything that competes with the news-reading purpose of the project.

### 21. A public read path was a missing piece, not an optional extra
Every use case built in Stage 2.1 answers "what can the author see and do with
their own articles". None of them answer "what can anyone else read once an
article is published", so a published article had nowhere to be read from
outside of `MyArticlesScreen` (which is scoped to its owner). This is not
speculative: `backend/docs/DB_SCHEMA.md` already documents
"Public read access to published articles (`status: "published"`)" as a
security rule, so the schema always assumed this path would exist. It is
treated as closing a gap in the base feature, not as overdelivery item #1 from
`README.md` section 7.
The real, Figma-driven UI for it is still left for the UI stage, per the
project's own ordering. A throwaway skeleton UI was added afterwards, once the
domain and cubit existed, purely to exercise this feature by hand before
moving on — see decision #28.

### 22. One use case, two callers: the public feed and "more from this author"
`GetPublishedArticlesUseCase` takes an optional `authorId`. Called without it,
it is the general feed of published articles; called with it, it is "more
articles from this journalist" (an approved overdelivery item, aligned with
`README.md` section 7's "author profile" style ideas). These are the same
business operation — list published articles matching a filter — so they get
one use case and one repository method, not two near-duplicates (CG5).
`excludeArticleId` exists so a reader looking at an article's detail does not
see that same article again in the "more from this author" list below it.

### 23. Pagination is part of the contract from day one
`GetPublishedArticlesParams` takes `limit` and `startAfterArticleId` (a cursor,
not a page offset) even though the in-memory repository holds a handful of
mock articles and does not need it yet. Firestore pages with
`startAfter(lastDocument)`, not with an offset, so designing the contract
around an offset now would mean reshaping it again in the data layer stage.
`ArticleFeedCubit.loadMore()` already exercises this cursor against the mock
data, so the behaviour is verified before Firestore is involved. `pageSize` is
a constructor parameter (default 20) rather than a hardcoded constant, for the
same reason as decision #26's `autosaveDelay`: tests can use a page of 1 or 2
articles instead of needing dozens of fixtures to exercise a full page.

### 24. Recording a view does not touch `updatedAt`
A new `viewCount` field is added to `JournalistArticleEntity` and a
`incrementViewCount` method to the repository. It intentionally does not
refresh `updatedAt`: that field means "the author last edited this", and
`getUserArticles`/the feed order by it (or by `publishedAt`); letting reader
traffic bump it would corrupt that ordering with activity the author did not
cause.
No cubit calls `IncrementArticleViewCountUseCase` yet. It has no legitimate
caller before there is a screen where a reader opens a published article, and
that screen is UI work, explicitly the last step of the project's own ordering.
Wiring it into an existing cubit just to satisfy "every use case has a caller"
would be the kind of speculative code the project's own guidelines argue
against; the gap is recorded here instead (Truth is King) and closed in the
UI stage.

### 25. `viewCount` is documented in the schema now, enforced in the rules later
`backend/docs/DB_SCHEMA.md` gains a `viewCount` field (integer, default `0`,
not required). `backend/firestore.rules` is not touched in this stage — that
belongs to the "leave the backend properly finished" work that follows this
one — but it needs a rule limiting `viewCount` to only increase by exactly one
per write, or any client could inflate it. This is the same kind of
documented-but-not-yet-enforced gap already on record in decision #9.

### 26. Autosave only fires for drafts, and is a cubit concern, not a use case
`ArticleEditorCubit` now debounces edits (`titleChanged`/`descriptionChanged`/
`contentChanged`) and calls the existing `saveDraft()` after the journalist
stops typing, instead of requiring an explicit tap. No new use case was added
for this: autosave is "call `saveDraft` automatically", not a new business
operation, and `saveDraft()` already contains the create-vs-update decision it
needs.
Two guards keep it from being surprising:
- it only schedules while `article.isDraft` — editing an already published
  article never autosaves over the live version; publishing changes still
  requires the explicit `publish()` action.
- it only schedules once `article.validateAsDraft()` is empty (title, author
  and owner set), so it does not repeatedly emit a failure state while the
  journalist is still typing the title of a brand new article.
The debounce delay is an injectable `autosaveDelay` (default 2 seconds)
instead of a hardcoded `Timer`, so tests can set it to a few milliseconds
instead of waiting on real time or pulling in a fake-async dependency the
project does not otherwise need.

### 27. Scope kept out on purpose
Comments, notifications, a recommendation feed, social sharing and analytics
dashboards were considered and dropped: none of them serve "a reader reads
better" or "an author writes better" more directly than the three features
above, and each would pull in a new area of the app (auth-gated interactions,
push infrastructure, a ranking algorithm) disproportionate to a recruitment
exercise. If time remains after the backend/data layer and the report, they
are the next candidates, in that order: search across the public feed,
comments, then sharing.

### 28. A throwaway skeleton UI for the public feed and author profile
`ArticleFeedCubit` had no `screens/`/`widgets/` yet (decision #21): the plan
was to build those only once the Figma prototype is implemented, at the end
of the project. To manually exercise the public feed and "more from this
author" before that point, a skeleton UI was added now, following the exact
precedent of decision #14 (plain Material widgets wired to the cubit, no
visual design intent):
- `PublishedArticleTile`: a reader-facing row with no author action, kept
  separate from `JournalistArticleTile` (which owns edit/publish/delete) so
  neither widget has to branch on who is looking at it.
- `ArticleFeedScreen`: renders whatever `ArticleFeedCubit` is provided above
  it, with a `title` argument that is purely cosmetic — the cubit's
  `authorId`/`excludeArticleId` are what actually scope the query. The same
  screen serves the general feed and an author's profile.
- `ArticleReaderScreen`: a plain detail view for one already-loaded article,
  with a "More from this author" button. It does not open its own
  `ArticleFeedCubit`: composing that cubit with an `authorId` known only at
  navigation time is `AppRoutes`' job (decision #12), so the button instead
  navigates to `/ArticleFeed` with that id.
- `/ArticleFeed` takes a `Map<String, dynamic>?` as its route argument
  (`authorId`, `excludeArticleId`, `title`) instead of a dedicated argument
  class, mirroring `/ArticleEditor`'s raw `String? articleId`: this project's
  routing arguments are already untyped primitives, not a place to introduce
  the project's first typed argument object for a screen that is itself
  temporary.
- Reachable from `DailyNews`' app bar (a new `Icons.public` action), the same
  way `/MyArticles` already is.
This UI is expected to be replaced, not extended, once the Figma prototype is
implemented; its only job is proving the domain and cubit work end to end.

## Stage 4 — Authentication and the real Firebase backend

### 29. Authentication is forced by the rules, not by the README
`README.md` never asks for a login. `backend/firestore.rules`, written in
stage 1, does: `create`, `update` and `delete` on `/articles/{articleId}` all
require `request.auth != null` and `request.auth.uid == userId`. With the app
still writing `kMockJournalistId` (decision #14), the first real write to
Firestore would be rejected by the backend.
So authentication stopped being optional polish the moment the data layer
became real: either the rules get weakened, or a real user exists. Weakening
the rules was rejected — the security model is one of the few parts of this
project that is already finished and correct, and "userId is whatever the
client says it is" is not a defensible thing to ship.

### 30. Email and password, not anonymous sign-in
`signInAnonymously()` was the cheaper option and was considered first: it
satisfies the rules with no login screen, and a linked anonymous account keeps
its uid when it is later upgraded, so nothing written would be lost.
It was rejected because of what it does to the feature this project is being
judged on. An anonymous uid lives in one app installation: the same person on
a second device, or after reinstalling, gets a different uid, and their own
articles stop being theirs — they disappear from "My articles" and can no
longer be edited or deleted. Every screen we built is about "the articles *of
this journalist*", and that premise needs an identity the person can carry
between devices. The alternative was shipping the feature with a footnote in
the report explaining when it does not really work.

### 31. Signing in is optional: reading never requires an account
The app is a news reader first. Anyone can open it and read Daily News and the
community feed with no account at all; an account is only required to *write*.
This matches what the rules already say (`allow read` for published articles
needs no auth) and keeps the app's front door open.
Consequences for the UI: the home screen stays `DailyNews` and is never
gated, and the account entry point is a user icon in its app bar. The actions
that need an account (write an article, "My articles") ask for sign-in at the
moment they are used, instead of a login wall at startup.

### 32. Password reset: a hand-rolled 6-digit code was designed, then dropped
The flow first specified was a **6-digit PIN expiring in 5 minutes**, typed
back into the app. It was designed in full before being rejected, so the
reasoning is worth keeping rather than quietly disappearing.

Why it was dropped:
- A client SDK cannot change the password of a user who is *not* signed in,
  which is the whole point of a reset. The PIN flow therefore needs the Admin
  SDK, so Cloud Functions, so the **Blaze billing plan** — an external
  dependency on the project's billing, for one screen.
- More importantly, a hand-written credential recovery flow is exactly where a
  senior reviewer looks for holes: brute forcing a 6-digit code inside its
  window, rate limiting, and whether the endpoint leaks which addresses have
  an account. All of it is solvable, and all of it would have become ours to
  get right and to defend.

What is used instead: `FirebaseAuth.sendPasswordResetEmail()`, which emails a
single-use link to a Firebase-hosted page. One use case
(`RequestPasswordResetUseCase`), one screen, no Cloud Functions, no email
provider, no collection of codes, no Blaze requirement.

What this costs, stated plainly rather than glossed over:
- the person leaves the app for a browser to finish, which is a worse
  experience than typing a code in place;
- the expiry window is Firebase's, not the 5 minutes originally specified;
- the email and the reset page carry Firebase's default branding; the email
  template is editable from the console, but a custom domain needs extra DNS
  setup that is out of scope here.

The door is left open: `AuthRepository` exposes the intent ("start a password
reset for this address"), not the mechanism. Moving to an in-app code later
changes that one implementation, and none of its callers.

### 33. The session is a plain cubit over a Future, not an auth state stream
`SessionCubit` asks `GetCurrentUserUseCase` once at startup and updates itself
from the result of sign-in/sign-up/sign-out. It does not subscribe to
`FirebaseAuth.authStateChanges()`.
The reason is the `UseCase<ReturnType, Params>` contract, which returns a
`Future`: exposing a stream would have meant either a `Future<Stream<...>>`
signature, which is contract-compliant but dishonest, or letting the cubit
talk to a repository directly, which `ARCHITECTURE_VIOLATIONS.md` 3.2
forbids. Nothing in this app changes the signed-in user behind the app's back,
so a stream would buy nothing for the complexity.

### 34. Bugs found in the stage 1 rules while wiring the data layer
Auditing `firestore.rules` against the entities before writing the data layer
turned up one outright bug and two gaps:
- **A draft could never be created.** `allow create` required
  `request.resource.data.publishedAt is timestamp`, but a draft has no
  publication date (`publishedAt` is null until it is published, decision #8).
  Every "save as draft" would have been rejected by the backend. The rule now
  accepts a null `publishedAt` and requires a timestamp only when
  `status == "published"`.
- The 200/500 character limits documented in `DB_SCHEMA.md` were only checked
  to be strings (already on record as decision #9); they are now enforced.
- `viewCount` (decision #25) is now enforced to be an integer that a client may
  only increment by exactly one, so a reader cannot inflate someone's numbers.

### 34b. The in memory repositories stay, unregistered
Decision #6 promised that swapping the mock data layer for Firestore would be
"a two line change in `injection_container.dart`", and it was. The in memory
implementations are no longer registered, but they are kept: they are the only
way to run the app end to end with no network and no account, and they are
covered by their own tests. They are a fixture, not dead production code, and
the comment in the injection container says so at the point where the swap
happens.

### 35. The documented index did not exist
`DB_SCHEMA.md` documents a composite index on `userId, status, createdAt`, but
`firestore.indexes.json` only ever contained commented-out examples, so no
index was deployed. The queries the app actually issues are now declared
there: the author's own list, the public feed ordered by `publishedAt`, and
the same feed filtered by author ("more from this author", decision #22).

### 36. Verification of this stage
`flutter analyze`: no new issues (the ones left are pre-existing, in
`daily_news` and in generated files). `flutter test`: 119 passing, 21 of them
new for the authentication domain and the session cubit.
`firestore.rules` was first compiled locally by starting the Firestore
emulator (`firebase emulators:exec --only firestore`), which refuses to start
on a rules file it cannot parse.

Deployed to `newsapp-671e4` with
`firebase deploy --only firestore:rules,firestore:indexes,storage`: both rules
files compiled and were released, and `firebase firestore:indexes` confirms
the four composite indexes of decision #35 are live. Email/password sign-in
was enabled in the console, which is a toggle with no CLI equivalent.

Not verified yet, and honestly on record as such:
- the rules have not been exercised against actual requests. What is proven is
  that they compile and are deployed, not that they allow and deny exactly
  what decision #34 claims. Rules unit tests
  (`@firebase/rules-unit-testing`) are the way to prove that, and are the
  first thing to add if this stage is revisited.
- nothing has been run against the real project from the app: no account has
  been created, no article has reached Firestore, no image has reached Cloud
  Storage. There is no emulator or device attached to the machine this was
  written on, so the end to end path is still unproven by hand.

### 38. A repository that lets an error escape hangs the screen
The first real sign-up against the live project created the account in
Firebase and then left the button spinning forever. Two mistakes met:
- `FirebaseAuthService.signUp` called `User.reload()` after
  `updateDisplayName`, and reloading has been seen not to complete on Android.
  It was pointless anyway: the caller already knows the name it just wrote, so
  the reload was re-reading data it had. Removed.
- `AuthRepositoryImpl` caught only `FirebaseAuthException`. Anything else — a
  cast error, a `PlatformException`, a null that should not be null — escaped
  the `try`, so the cubit's `await` never completed. **A failure that escapes a
  repository does not show up as an error; it shows up as a screen that never
  stops loading**, which is strictly worse than an error message.

Both repositories now run their work through a `_guard` helper whose last
clause is a bare `catch`. The rule this encodes: a repository owes its caller
a `DataState`, including "something unexpected happened". Swallowing the type
of an error is bad; swallowing the *answer* is worse.

Not covered by a test yet, and that is worth being straight about: proving the
guard converts an unexpected throw into `DataFailed` means faking the data
source, and the data sources are concrete classes wrapping Firebase with no
interface to fake. Introducing one is the right fix if this is revisited;
right now the property is enforced by reading the code, not by a test.

### 39. The PigeonUserDetails bug, and the version upgrade it forced
With the hang of decision #38 gone, the real failure surfaced:

```
type 'List<Object?>' is not a subtype of type 'PigeonUserDetails?' in type cast
PigeonUserCredential.decode (firebase_auth_platform_interface/.../messages.pigeon.dart)
```

It throws *inside* `createUserWithEmailAndPassword`, before returning to our
code: the native Android SDK answered with a shape the Dart pigeon codec of
`firebase_auth 4.16` could not decode. The account is created, then the reply
fails to parse. Nothing in this project could have prevented it, and no
workaround in our code would have been more than a patch over a version
mismatch.

The fix is the same lesson as decisions #15–#18: the starter project's pins
were years stale. `firebase_core` 2 → 4, `firebase_auth` 4 → 6,
`cloud_firestore` 4 → 6, `firebase_storage` 11 → 13. None of our data layer
code changed: every API it uses (`createUserWithEmailAndPassword`, `collection`
/`where`/`orderBy`/`startAfterDocument`, `FieldValue.increment`, `putData`)
is stable across those majors, which is a decent sign the data sources are
sitting at the right level of abstraction.

The Android side needed three changes to accept the current SDKs, each a real
failure that had to be diagnosed rather than guessed:
- **Java 11** (`compileOptions`/`jvmTarget`, was 8): the Firebase Android
  libraries are compiled for 11 and will not link against an 8 target.
- **Kotlin 2.3.0** (was 2.1.0): `firebase-auth-24.2.0` ships Kotlin metadata
  version 2.3.0, which a 2.1.0 compiler refuses to read.
- **Jetifier off** (`android.enableJetifier=false`) and the Gradle heap raised
  to 4 GB: jetifier rewrites legacy support-library artifacts to AndroidX,
  nothing here needs it any more, and running it across the current Firebase
  artifacts ran the build out of heap.
- `com.google.gms.google-services` 4.3.10 → 4.4.2 along the way.

Verified: `flutter build apk --debug` succeeds, `flutter analyze` is clean and
the 125 tests still pass.

### 40. Autosave must not look like a save
Testing the editor by hand found autosave throwing the journalist out of the
article: writing, pausing to think, and finding yourself back on the previous
screen. `ArticleEditorScreen` closes the editor when the cubit reports
`ArticleEditorStatus.saved`, which is right for the "Save draft" button and
wrong for a timer. Autosave was reusing the same state, so it inherited the
navigation meant for a deliberate action.
Autosave now reports `ArticleEditorStatus.autosaved`, a state the screen
deliberately does nothing about beyond showing a quiet "Draft saved". The
lesson is small and general: *saved by request* and *saved on its own* are two
events, and collapsing them into one state hands the wrong behaviour to
whoever listens.

Fixing it surfaced a second, quieter bug. On success the cubit replaced its
article with the one the backend returned. During an autosave the journalist
is *still typing*, so the returned article carries the text as it was when the
write left, and adopting it discards every keystroke made since. An autosave
now keeps the text on screen and takes only what the backend owns — the id and
the timestamps. The id still matters: without it the next autosave would
create a second article instead of updating the first.

Also on record: the test plan used for this round claimed a three letter title
should not autosave. That expectation was wrong, not the code.
`validateAsDraft()` asks for a title that is not blank, nothing more, and a
draft called "abc" is a perfectly good draft. The test case was corrected
rather than the behaviour.

### 41. Anti-enumeration makes a failed password reset undiagnosable
`requestPasswordReset` reports success for an address that has no account, on
purpose, so the app cannot be used to find out who is registered (decision
#32). The cost showed up the first time a reset email did not arrive: "no
email came" and "that address was mistyped" produce exactly the same screen,
and no log distinguishes them.
This is the right trade, and it is kept, but it means diagnosing a reset has
to happen outside the app: `firebase auth:export` to confirm the account
exists, and the console's own "Reset password" action on that user to test
delivery without involving our code. Worth knowing before someone spends an
afternoon debugging a repository that is behaving exactly as designed.

### 42. A publication date is set once, not on every publish
Found while testing by hand: after editing a published article and publishing
the changes, `publishedAt` and `updatedAt` held the same moment, because
`markAsPublished` overwrote the date every time it ran.
This is not cosmetic. The public feed orders by `publishedAt` descending
(decision #35), so every edit was jumping the article back to the top of the
feed — an ordering anybody could game by re-saving. `publishedAt` now means
"when readers first got this" and is only set the first time an article goes
public; `updatedAt` carries the edits.

The same look uncovered a latent bug on the way back down. The deployed rules
demand `publishedAt == null` whenever `status == "draft"`, but `markAsDraft()`
kept the old date, so unpublishing an article would have been rejected with
`permission-denied`. Nothing calls it yet — the UI offers no unpublish — which
is exactly why it was worth catching now rather than the day somebody adds the
button. `copyWith` grew a `clearPublishedAt` flag, since passing null to an
optional parameter means "leave it alone" and cannot express "remove it".

### 43. The community feed is a week wide, ten at a time
Two limits on the community feed, asked for while designing it.

**Ten per page** was already possible: the cursor paging of decision #23 only
needed its page size changed from twenty.

**A seven day window** is new. Without one the feed can only grow: a busy week
buries everything, and the oldest article stays one more page away forever. It
filters on `publishedAt`, never `updatedAt` — an edit does not make an article
new again, and filtering on the edit date would let anybody haul an old
article back into the feed by re-saving it, which is the same hole decision
#42 closed for ordering.

Firestore takes it for free: a range filter is allowed on the field the
results are ordered by first, which is already `publishedAt`, so the two
composite indexes of decision #35 serve the windowed query unchanged. No new
index, no migration.

The window applies to the community feed and **not** to an author's own page.
A feed answers "what is new"; an author's page is their catalogue, and their
work should not vanish from it after a week. `ArticleFeedCubit` takes an
`onlyRecent` flag rather than inferring it, so each composition root says
which of the two it is building.

One consequence worth designing for: an empty feed now has two different
meanings. "Nobody has ever written anything" and "nothing was written this
week" are not the same fact, and the screen says which one it is — the
difference between an app that looks dead and one that had a quiet week.

### 44. Two readers, one frame, and the view counter finally wired
World news and community articles are read on two separate screens, because
they are two different entities with two different affordances: a news article
can be **saved for later** and has no author page to go to; a community
article has **the rest of its author's work** underneath and cannot be saved.
What they share is only the frame — cover, floating back button, rounded sheet
— which lives in `core/shared/reader_scaffold.dart` so neither feature has to
import the other to look the same.

`IncrementArticleViewCountUseCase` finally has a caller. Decision #24 left it
deliberately unwired because, with no reading screen, there was no honest
moment at which somebody had read an article. `ArticleReaderCubit` provides
that moment, and counts it **once** per reading — a flag in its state, so
rebuilding the screen cannot inflate anybody's numbers.

The count is optimistic and never rolled back. A view is a statistic, not a
transaction: stopping somebody's reading with an error because a counter did
not tick costs more than the count is worth, and the backend's number is
authoritative on the next load anyway.

**Saving a community article is not possible, and the design asked for it.**
Saved articles are persisted by Floor as `ArticleModel` — a different entity,
with an `int` id where journalist articles use a `String`. Giving them local
storage means a new Floor entity, and Floor's generator cannot run
(decision #19). The Save button therefore appears only on the news reader,
where it works. Recorded as pending rather than faked.

Two smaller things the design assumed and the data does not have:
- **No author photograph** exists on either an article or an account, so the
  avatar renders the author's initials rather than an empty grey disc.
- **Saved state is not known on entry.** The local data source can add and
  remove, but cannot answer "is this one already saved", so the button
  promises only what it can keep: tapping it saves, and it then says "Saved".
  Un-saving still happens from the Saved tab.

### 45. Saved Articles, and a widget-test trap worth writing down
The saved list is compact rows only. It is a list to come back to rather than
a feed to browse, so nothing in it gets the lead treatment the news feed uses.

Removing is an **undo**, not a confirmation. Un-saving one article is small
and easy to do by accident; offering to put it back costs the reader nothing,
where a confirmation dialog would tax every deliberate removal to catch the
rare mistaken one. The control is the same filled bookmark that saved it, and
it is reachable by tap — never only by a swipe.

Writing the test for it cost more than writing the screen, for a reason worth
recording: **a bloc created in `setUp` does not work under `testWidgets`**.
`setUp` runs outside the fake clock that `testWidgets` installs, so the bloc
processes its events against the real one and `tester.pump()` never advances
it — the screen sits in its loading state for the whole test and every
expectation fails with "found 0 widgets", pointing at the screen rather than
at the setup. Building the bloc inside the test body fixes it.

Two smaller ones from the same session: `pumpAndSettle()` never settles on
these screens, because the cards hold image widgets that do not reach a
settled state in tests — `pump()` with a duration is the right tool. And a
snack bar has to be given its entrance animation before it can be tapped, or
the tap lands where it is about to be.

### 46. Saving was broken three ways, all from the same root
Reported from the device: a saved article did not appear in the Saved tab
until the app was killed and reopened, and an article already saved still
offered to be saved again, so it could be stored twice.

**One bloc per screen was the root.** `LocalArticleBloc` was registered as a
factory, so the reader saved into its own instance while the Saved tab watched
a different one, and `IndexedStack` keeps tabs alive so the tab never rebuilt
either. "What I have saved" is one fact about the app, not per-screen state,
so the bloc is now a singleton that every screen shares through
`BlocProvider.value` — `create` would have closed the singleton the first time
a reader was popped.

**The second bug fell out of the first.** With nothing shared, the reader had
no way to know an article was already saved, so its button always said "Save".
It now reads the shared list, which also let the button become a real toggle:
tapping "Saved" removes. That closes pending item 5c, and means somebody who
saved by mistake has a way back without hunting for the Saved tab.

**A third was waiting to be found.** `removeArticle` handed the entity
straight to Floor, which deletes by primary key — and an article from the news
API has no id, only its stored copy does. Removing from the reader would have
deleted nothing. The repository now finds the stored copy and deletes that.

Matching the two copies needed `ArticleEntity.isSameArticleAs`, because `==`
cannot do it: the API copy has no id and the saved copy has one, so the same
article is never equal to itself across that boundary. Identity is the url.

The repository also refuses to store an article twice. The UI no longer asks
it to, but the id is generated on insert, so nothing else would have stopped
a duplicate row — and the guard belongs where the rows are written.

### 47. The account summarises real work, and drops the row that could not
The design puts "12 articles · 3.4K views" under the person's name. Those
numbers did not exist, but they were *computable*: `GetMyArticlesUseCase`
already returns everything a journalist has written and every article carries
its `viewCount`. `JournalistStatsCubit` adds them up.

It counts from the articles rather than from a stored counter, so the summary
and the "My articles" list can never disagree. Drafts count: "My articles"
lists them, so the number beside that row has to include them.

Two choices worth stating:
- **Nothing is shown to somebody who has not written yet.** "0 articles · 0
  views" is a worse welcome than an empty space.
- **A failed summary is not an error.** If the count cannot be fetched, the
  account still shows who is signed in and still signs them out. Numbers
  nobody asked for are not worth an error message.

The cubit lives in `journalist_articles`, not in `authentication`, because it
is the articles feature that owns those facts; the account screen only places
it. This is the same shape as `AccountActionButton`, which `daily_news` places
without knowing anything about sessions.

**The "Settings" row in the design was dropped**, because there are no
settings. A row that opens nothing is worse than no row. The honest candidate
if one is wanted later is a light/dark preference: both themes already exist
and only the choice would need storing.

### 48. Errors became a component, not a red sentence
Validation failures were a line of red text under the form. They are now
`AlertBanner` in `core/shared`, used by sign in, sign up, password reset and
the article editor — everywhere the app judges what somebody typed.

Three things make it work where loose text did not:
- it is visibly **a message**, a tinted panel with a border, rather than copy
  that happens to be red;
- it carries an **icon**, so the meaning does not rest on colour alone. Red
  text on a warm background is exactly what somebody with a red/green
  deficiency cannot pick out;
- it is a **live region**, so a screen reader announces it instead of leaving
  it to be discovered by someone re-reading the form.

It also arrives with a short fade and rise. A message that blinks into place
is easy to miss — particularly the second time it says the same thing, when
nothing else on screen changes.

The password reset confirmation was rebuilt at the same time. Its wording is
load-bearing and stays deliberately vague about whether the address has an
account (decision #32), and it now says out loud what testing found: the email
usually lands in spam.

### 49. Two copies of the Firebase key, and which key actually matters
Rotating the Firebase API key froze the app on the splash screen with
`[core/duplicate-app] A Firebase App named "[DEFAULT]" already exists`.

The cause is that the key exists **twice**. On Android the `google-services`
Gradle plugin compiles `google-services.json` into resources, and
`FirebaseInitProvider` initialises the default app *before Dart runs*. `main`
then calls `Firebase.initializeApp` with the options from
`firebase_options.dart`. When the two agree, `firebase_core` quietly hands
back the existing app; when they disagree — one file updated, the other not —
it refuses. The crash was correct: it was reporting a half-applied
configuration, and it is the reason no defensive `if (Firebase.apps.isEmpty)`
guard was added. That guard would have made Android silently ignore
`firebase_options.dart` and hidden exactly this class of mistake.

The fix is to keep the two in step. `flutterfire configure` regenerates both
together and is the right tool — with one catch found here: it returns
whichever key **Firebase** has associated with the Android app, which is not
necessarily the newest one in the Google Cloud project. Creating a key in
Cloud Console does not re-point the Firebase app at it, so regenerating
brought the superseded key back. The current key is therefore written into
both files directly, and re-running `flutterfire configure` will undo that
until the old key is removed from the project.

Worth stating plainly for the report, because it looks like a finding and is
not one: **a Firebase client API key is not a secret**. It ships inside every
published APK and anybody can read it out of one. It identifies the project;
it does not authorise anything. What protects the data is the security rules
of decision #34 and Firebase Authentication. Restricting the key to the app's
package name and SHA-1 fingerprint — which is a real measure — is what stops
it being used from anywhere else.

**Both files are nevertheless kept out of the repository.** Not because the
key is a secret, but because a reviewer reading a repo should not have to
work out that it is not one, and because the project it points at is a
personal one whose quota and data would otherwise be open to anyone who
cloned this. `firebase_options.dart` and `google-services.json` are ignored
together: they carry the same key, and ignoring one while committing the
other would have achieved nothing.

The cost is real and worth saying out loud: **a fresh clone does not
compile**, because `main.dart` imports `firebase_options.dart`. Building this
project needs `flutterfire configure` against a Firebase project of your own
first. That is a step the report has to state, or a reviewer meets a missing
import and no explanation.

The credential in this repository that *is* worth worrying about is
`newsAPIKey` in `core/constants/constants.dart`. It came with the starter
project, it grants quota on a real NewsAPI account, and no rules protect it.
It cannot be fully protected in a client-only app either: anything the app can
send, an attacker can extract and replay. The honest fix is proxying the news
API through a backend, which is outside this exercise's scope, so it is
recorded here instead of quietly left for a reviewer to find.

### 50. The editor, the moment after it, and the workspace
The last three screens of the journalist flow.

**The editor** drops every box and border. It is a page to write on, and a
form that looks like a form competes with the only thing that matters on it.
The cover's empty state is a dashed outline rather than a grey rectangle —
dashes read as "something goes here", a grey rectangle reads as "something
failed to load" — and once there is an image it offers Replace and Remove.
Removing only clears the link the article holds; the uploaded file stays in
storage, because the journalist may put it back and a published article still
points at it until the change is saved.

The autosave note earned a timestamp: "Draft saved · 2 min ago". It stays
ambient, never taking focus or covering the keyboard, for the reason decision
#40 was written.

**Publishing now leads somewhere.** `ArticleEditorStatus` gained `published`,
separate from `saved`, because the two go different places: a published
article deserves an acknowledgement, a saved draft just closes the editor.
Deriving it from `article.isPublished` would have been wrong — editing an
already-public article and saving it would have looked like publishing.

The success screen shows *which* article went live rather than only that one
did, and its check draws itself in. It is the one full screen in the app given
to an action, and it is given to the only action that makes something public.

**My Articles** spells its actions out — Edit, Delete, and Publish on drafts —
instead of hiding them in a menu, and its empty state distinguishes "nothing
matches this filter" from "you have not written anything", which are different
facts and only one of them deserves an invitation. Deleting keeps its
confirmation dialog rather than the undo used for un-saving (decision #45):
this destroys work that cannot be recovered.

Dropped from the design, for the same reason as in Daily News: the **category
chip** on the success screen's preview. Journalist articles have no category,
and inventing one to fill a label would be inventing data.

### 51. A transparent Scaffold is only safe inside the shell
Reported from the device: the editor and My Articles turned black about half a
second after opening, keeping only their cards and app bar.

Six screens carried `backgroundColor: Colors.transparent`. Inside the shell
that is harmless — the shell's own Scaffold paints the background behind the
tab. But the editor, My Articles and an author's feed are **pushed as routes**,
where their Scaffold is the only surface there is. Transparent then shows what
is behind the route, which is nothing. The half-second was the page transition
finishing: until then the screen below was still being painted.

The property was pointless either way. `scaffoldBackgroundColor` in the theme
is already the colour those screens were trying to let through, so simply not
setting it gives the same result in a tab and the correct one in a pushed
route.

Guarded by a test on both pushed screens, because the mistake is invisible in
the widget tree and only shows up on a device: a screen that is opened by
pushing a route has to paint its own background.

### 52. The image picker, and why it is not just a call in the widget
The cover was a fixed 64 KB image in memory since decision #14. It is now
picked from the device — the last item of the UI work, and pending item 6
closed.

The obvious implementation is `ImagePicker().pickImage()` inside the editor.
`ARCHITECTURE_VIOLATIONS.md` 1.4 rules it out: data sources are the only
classes allowed to touch hardware, and the photo library is hardware. So the
slice is a full one — `ImagePickerService` (the only class that reaches the
gallery), `CoverImagePickerRepository` and its implementation, and
`PickArticleCoverUseCase`.

Kept apart from `ArticleThumbnailRepository`, which *stores* images: choosing
a file and uploading one are different jobs backed by different things, the
device on one side and Cloud Storage on the other. That is the same reasoning
that split the two repositories in decision #7.

Three details that matter more than the plumbing:
- **Cancelling is not a failure.** The contract returns `null` for "nobody
  picked anything", so backing out of the gallery leaves the editor exactly as
  it was instead of showing an error for a decision the person is entitled to
  make.
- **The picked image is judged on the device.** The use case validates before
  anything leaves the phone, so an oversized or unsupported file is refused
  here rather than after a pointless upload to Cloud Storage.
- **It is scaled on the way out** (`maxWidth: 1200`, `imageQuality: 85`),
  matching the size the editor recommends. Without that, a photo from any
  modern phone is comfortably over the 5 MB the storage rules allow, and the
  limit would reject nearly every real photograph instead of the genuinely
  oversized ones it is meant for.

One toolchain consequence: `image_picker_android` pulls AndroidX libraries
that require Android Gradle plugin 8.9.1, so AGP moved from 8.7.3. Gradle 8.12
was already new enough.

Gallery only, no camera. Camera needs a runtime permission and its own
failure paths, and a cover photograph is normally something the journalist
already has.

### 53. Moving covers, and a body written in Markdown

**GIF covers** turned out to hinge on something not obvious. Reading
`image_picker_android`'s `ImageResizer` shows it decodes with `BitmapFactory`
and re-encodes whenever `maxWidth` or `imageQuality` is set — one frame, no
special case for GIF. The scaling added in decision #52 would therefore have
flattened every animation into a still **without reporting anything**.

So the picker now asks for the file untouched and the shrinking is decided
per file: animated ones are passed through, everything else is compressed
with `flutter_image_compress`. Dropping the shrinking altogether was the
simpler option and was rejected — a photo straight off a phone is several
megabytes, which often breaches the 5 MB rule and, worse, makes every reader
download all of it to look at an image displayed 1200 pixels wide.

That comparison also exposed a claim that was not true: `ArticleThumbnailEntity`
said its rules mirrored `backend/storage.rules`, but those rules only ever
checked the size. They now check the content type too, which makes the
statement honest and means the folder cannot hold anything but images. **This
needs deploying** — the repository is ahead of the project until it is.

**Markdown bodies.** `content` was already a string, so nothing in the schema
or the data layer changed, and articles written before this renders unchanged
— plain text is valid Markdown.

The rendering uses `flutter_markdown_plus`. The Flutter team's own
`flutter_markdown` is discontinued, and shipping a discontinued package in
work being judged on code quality is not a good trade for a familiar name.
Its style sheet is built from the app's theme, so headings come out in the
same serif as every other headline; a body rendering in a package's default
typography would read as pasted in from elsewhere.

The part that matters for the person using it is the editor. **A journalist
should never have to know Markdown**: five buttons write the syntax for them
and toggle it back off, which is what anybody already expects from a word
processor. Five and no more — Markdown can do far more, but an article needs
headings, emphasis, lists and quotes, and a toolbar that offers everything is
a toolbar nobody reads. Anyone who does know the syntax can still type it.

A **Preview** toggle sits beside the body, and it is not decoration: a toolbar
that inserts `##` is useless to somebody who cannot see what `##` becomes.
Without preview, this feature would work for developers and nobody else.

The formatting logic is separated from the widget precisely because it is the
fiddly part — where the cursor lands after an edit, what happens when the
markers sit outside the selection because the writer double-tapped a bold
word, whether a heading that is already a bullet stacks or replaces. All of it
is plain string work, and all of it is tested.

### 54. A guide that points at the screen, and demonstrates rather than explains
Markdown is only obvious to people who already know it, so the editor now
carries a five-step walkthrough: everything dims, one control is lit, and a
card says what it is for.

Two choices carry the feature.

**It demonstrates.** The formatting step holds a small panel that cycles
between what the journalist types and what a reader sees — `**bold**` turning
into **bold**, `## A heading` into a heading. Telling somebody that two
asterisks mean bold is a sentence they have to decode; watching it happen
needs no explaining. This is the part that makes the guide worth having
rather than a paragraph nobody reads.

**It never starts itself.** It opens from a `?` in the app bar and nowhere
else. A tour that appears uninvited is read once and resented every time
after, and this one explains something a writer may well want to look up
again later. Showing it automatically on a first run would need somewhere to
remember that it had been shown, and that is a dependency and a piece of
state this does not need to earn its keep.

Details that only turn up once it is built: half the controls it points at
start below the fold, so each step scrolls its target into view before
measuring where to cut the spotlight; the card picks the roomier side of the
highlighted control, because an explanation sitting on top of the thing being
explained is worse than no explanation; and asking for the formatting step
while the preview is open closes the preview first, since the toolbar it
talks about is not on screen otherwise.

The mechanism is in `core/shared`, taking a list of steps and knowing nothing
about articles. The editor is the only screen using it today — the same walk
would serve My Articles or the reader without change.

### 55. Work stopped being losable, and the button stopped lying
Reviewing the editor for what else authors might need turned up something
better than a feature: it silently lost writing.

Autosave only runs for a draft that already satisfies its rules, which leaves
two gaps, and back was a plain `Navigator.pop`:
- **Writing before naming.** Somebody drafts three paragraphs and then thinks
  of a title — an ordinary way to work. With no title, autosave never fires,
  and back threw the lot away.
- **Editing something published.** Autosave is deliberately off there
  (decision #40), because saving silently would change what readers already
  have. So a correction typed into a live article was volatile, and nothing
  on screen said so.

Leaving is now blocked only while something would be lost, and the person is
asked: keep writing, discard, or save. `PopScope` covers the system back
gesture as well as the button, and the button uses `maybePop` so it asks the
same question rather than quietly bypassing it. Choosing "Save" lets the
existing save flow close the editor, which means a write that fails leaves
them on their article instead of throwing it away on the way out.

Knowing whether anything would be lost needed the editor to remember what is
actually stored, so the state now carries `savedArticle` alongside the one
being edited. Only the four things a journalist writes are compared —
timestamps and view counts move on their own and are not changes anybody
made.

**"Save draft" became "Save changes."** The old label was wrong in both
directions: a draft is already saved automatically once it has a title, and
on a published article "save draft" described nothing the button did. The
cubit's `saveDraft()` was renamed to `save()` for the same reason — on a
published article it updates the live version, which is not drafting
anything.

Unpublishing is still not offered; that remains pending item 6b.

### 37. Google sign-in was considered and deferred
Adding Google as a second provider turned out to be cheaper than expected:
`flutterfire configure` had already wired the `com.google.gms.google-services`
Gradle plugin, which is the part most likely to break given the toolchain
trouble in decisions #15–#18. What remains is registering the debug and
release SHA-1 fingerprints in the console (no CLI equivalent), the
`google_sign_in` dependency, and one more data source method, use case and
button.
It was deferred anyway, because it competes for time with work that is worth
more: `docs/REPORT.md`, the Figma UI, rules unit tests and an end to end run.
It is recorded here because the fact that it is cheap *is* the point:
`AuthRepository` describes the intent of signing in, so another provider is a
new implementation and one use case, and changes nothing that already calls
it.

### 56. The unsaved-changes dialog stopped offering three ways out
Leaving the editor with unsaved work offered `Discard`, `Save` and `Cancel`.
Three buttons on an interruption is one too many: `Save` duplicated the
button already on the screen behind the dialog, and `Cancel` did not say what
cancelling meant.

It is now two: `Discard`, in red, and `Keep writing`. The choice is stated as
the two things that can actually happen to the work, and the label says the
outcome rather than naming the dialog's own machinery. The result type is a
`_LeaveChoice` enum rather than a `bool?`, so neither branch can be read the
wrong way round.

A related fix: the dialog's title was rendering in the display serif, because
Material styles `AlertDialog` titles with `headlineSmall` and this project's
`headlineSmall` is Instrument Serif. Fixed once in `dialogTheme` rather than
per dialog, so no future dialog inherits the same mismatch.

### 57. The name readers see became something you can change
A display name was only ever set at sign-up, which left whatever somebody
typed in that one moment on the byline of every article they would ever
write. Account now has a row that edits it.

The slice is the full stack, as the architecture requires: an
`UpdateDisplayNameParams` carrying the `maxLength` rule, an
`UpdateDisplayNameUseCase`, a method on `AuthRepository` and its
implementation, and `SessionCubit.updateDisplayName`.

Changing the name does **not** rewrite the byline on already published
articles. `author` is stored on each article as it was at publication, which
is the honest record of who published it under what name; rewriting history
retroactively is a different feature and a worse default.

The dialog owns its own `TextEditingController`. Creating one around the
`showDialog` call disposed it while the dialog was still animating out with
its field on screen, which throws — letting the dialog manage its own
lifecycle is what avoids that.

### 58. Daily News can be filtered by category
The News API takes a `category` parameter and the app was hardcoding
`general`. A `NewsCategory` enum now travels from a chip row at the top of
Daily News through `GetArticles(category:)`, the bloc state and
`GetArticleUseCase` to the data source.

The category lives in the bloc state rather than in the widget, so the chips
show what was actually fetched rather than what was last tapped — they cannot
drift from the list beneath them while a request is in flight.

This also uncovered a pre-existing bug in `RemoteArticlesBloc`: when the API
returned an empty list neither branch emitted anything, leaving the screen
spinning forever. Some categories legitimately return nothing, so what had
been rare became reachable. Fixed, with a test.

Note on scope: categories filter the *API* feed only. Community articles have
no category, because nothing in the app ever asks a journalist for one and
inventing a guess from the text would be a fabrication, not a feature.

### 59. Spanish on a Spanish device, English everywhere else
The app's own words are translated; **article content is never touched**. A
journalist writes in whatever language they choose and every reader sees
exactly those words. Translating user content would be inventing text and
attributing it to a named author.

Implemented with Flutter's own `gen-l10n` (`l10n.yaml` plus
`lib/l10n/app_en.arb` and `app_es.arb`, about 130 keys). This matters for a
practical reason: `build_runner` cannot run in this project (decision #19),
and `flutter gen-l10n` is part of the Flutter tool rather than a codegen
package, so it works where a package-based approach would not. `intl` was
bumped from `^0.18.1` to `^0.20.2` to match what `flutter_localizations`
pins.

Three consequences worth recording:

- **Dates are localised too.** `RelativeTime` and every `DateFormat` now take
  the active locale, so a Spanish reader gets "hace 3 h" and "1 sept 2026"
  rather than an English date under Spanish labels.
- **Formatting moved out of the widget.** `ArticleTimestamp.format` became
  `RelativeTime.formatRaw(l10n, ...)`, since it now needs a locale. Its unit
  tests moved with it to `test/core/shared/relative_time_test.dart`, and
  `ArticleTimestamp` kept a widget test of its own for what it renders.
- **It found a layout bug.** Spanish runs roughly a fifth longer than
  English, and the article-published screen was built from fixed `Spacer`s.
  The Spanish test overflowed it. It now uses `CenteredForm` — centred while
  it fits, scrolling the moment it does not — which was already in
  `core/shared` for the sign-in flow. The same overflow would have hit an
  English reader on a small phone or with a large system font; the
  translation is just what made it show up.

The translations are held to their own tests
(`test/l10n/app_localizations_test.dart`): both files must define exactly the
same keys, no value may be blank, a screen must render Spanish under `es`,
English under `en`, and English under any third language. The key-parity test
is the one that earns its place — a key missing from one file is how half a
screen silently falls back to English, and the test names the key.

This was done last of the four tasks on purpose. Doing it first would have
meant translating the strings that the other three went on to add.

### 60. The category labels vanished on a theme change, and why
Flipping the device to dark mode with Daily News open left the category chips
readable as shapes but with no text in them. The labels were still there; they
were painted in the light theme's near black, on a chip that had just become
dark.

The cause is where the theme was read from, not what the theme says. The
`BuildContext` a `ListView.itemBuilder` is handed belongs to the sliver, not
to the item it is building, so the `Theme.of(context)` call that coloured
these labels registered the *list* as the thing that depends on the theme. The
chips were rebuilt with the new theme; the label colour, captured in the
builder, was not.

The fix is a `_CategoryChip` widget, so the lookup happens on the chip's own
element. This is also the pattern the rest of the app already followed — every
other `itemBuilder` in the codebase returns a widget and reads the theme
inside it, which is why no other screen had the bug. It is guarded by a test
that pumps the screen in light, switches to dark and asserts the label colour
followed (`daily_news_test.dart`).

Worth recording as a class of bug rather than an incident: any
`InheritedWidget` lookup made directly inside an `itemBuilder` has this
shape — `MediaQuery`, `AppLocalizations` and `Directionality` would all have
gone stale the same way. The localisation lookup on that same line had the
same latent bug and was fixed by the same move.

### 61. Faking a concrete data source without introducing an interface
Pending item #3 of this log said proving the `_guard` clauses work "needs to
fake the data source, and the data sources are concrete classes wrapping
Firebase with no interface. Introducing one is the fix."

An interface turned out not to be needed. Dart lets a class `implements`
another concrete class, taking its signatures without its body, and a
`noSuchMethod` declaration satisfies the analyser for whatever is left over.
`FakeFirestoreArticleService implements FirestoreArticleService` is therefore
possible with no change to production code at all — and the `noSuchMethod`
throws rather than returning null, so a method the fake forgot fails loudly
instead of making a test pass for the wrong reason.

This was preferred to adding an abstract class per data source. The interface
would have existed only for the tests: nothing in the app has a second
implementation of these, and `ARCHITECTURE_VIOLATIONS.md` asks for the
abstraction at the *repository* boundary, which already exists. Adding a
second one below it would be architecture written for a test runner.

What this unlocked, all previously untested:

- `JournalistArticleRepositoryImpl` — Firestore's `not-found` becoming
  `ArticleNotFoundException`, refusing to update an article that was never
  stored, the `createdAt`/`updatedAt` stamping, and the broad catch.
- `AuthRepositoryImpl` — all eight Firebase error codes it maps, and the
  anti-enumeration promise of decision #41: an unknown address must come back
  from a password reset as a *success*.
- `ArticleThumbnailRepositoryImpl` and `CoverImagePickerRepositoryImpl` —
  including that a cancelled image pick is a success with nothing in it,
  rather than an error shown to somebody who simply changed their mind.
- `ArticleRepositoryImpl` (`daily_news`, legacy) — the save/remove fixes of
  decision #46 had no test of their own until now.

The data sources themselves stay untested on purpose. They are a thin wrapper
over the Firebase SDKs, and a unit test of one could only assert that it calls
the SDK the way the test was written to expect. What they actually promise is
verified against the emulator, which is pending item #2.

### 62. Two dead widgets, removed rather than covered
Auditing coverage found `daily_news/presentation/widgets/article_tile.dart`
and `authentication/presentation/widgets/account_action_button.dart`
referenced by nothing — leftovers from screens that were since rewritten.
Under the Boy Scout rule the choice is to test them or to delete them; nothing
calls them, so they were deleted. Writing tests for them would have been
coverage bought for code that cannot run.

## Stage 3 — Architecture and coding-guidelines audit

A full pass over every file in `lib/` against `docs/APP_ARCHITECTURE.md`,
`docs/ARCHITECTURE_VIOLATIONS.md` and `docs/CODING_GUIDELINES.md`. What
follows is what the audit found and what was done about it.

### 63. The provider SDKs were leaking out of `data_sources`
Rule 1.2.4 says `data/data_sources` is the **only** place that may import a
provider. Eight files broke it, and all of them for the same reason: the
repositories were catching the provider's own exception type in order to
translate it, and two models were being built from a provider's own object
(`DocumentSnapshot`, Firebase's `User`).

That reading makes the rule impossible to satisfy — a repository cannot
translate `FirebaseAuthException` without naming it. The rule is satisfiable
only if the *data source* stops throwing provider types. So `RemoteException`
(`core/resources/`) was introduced: a data-layer error carrying the provider's
code verbatim as a `String`. Data sources now catch the SDK's exception and
rethrow this; repositories switch on `error.code` and never name Firebase,
Dio or the platform channels.

The same reasoning applies to data crossing the boundary:

- `FirestoreArticleService` converts `Timestamp` to `DateTime` on the way up
  and back on the way down, so `JournalistArticleModel` is plain Dart.
  `fromSnapshot` moved into the service; `toFirestore`/`toFirestoreUpdate`
  became `toRawData`/`toRawDataForUpdate`, since a model naming its provider
  is the same leak by another route.
- `FirebaseAuthService` now returns `AppUserModel` rather than a Firebase
  `User`, and `AppUserModel.fromFirebaseUser` became `fromRawData(Map)` —
  which rule 1.3.3 wanted anyway.
- `NewsRemoteDataSource` is new. The News API's "data source" was a Retrofit
  *generated* client returning `HttpResponse`, so the repository was reading
  status codes and building `DioException`s. The new hand-written class wraps
  it and answers in models or `RemoteException`.

A pleasant side effect: the tests got simpler. Faking a data source no longer
needs any of the Firebase SDK — `FakeFirebaseAuthService` lost its
hand-written fake `User` entirely.

**Four imports remain, on purpose**, and `test/architecture_test.dart` lists
them by exact path so a ninth cannot appear unnoticed:
`injection_container.dart` (the composition root has to construct what it
injects), `main.dart` and `firebase_options.dart` (bootstrap, before any layer
exists), and `daily_news/data/models/article.dart`, where Floor's `@Entity`
must sit on the class its generated DAO names — splitting the table row into
its own class needs `build_runner`, which cannot run here (decision #19).

### 64. The saved articles had no way to report a failure
`ArticleRepository.getSavedArticles` returned a bare `Future<List<...>>`, as
did `saveArticle` and `removeArticle`. A Floor exception therefore escaped the
repository, which is precisely the bug class decision #38 is about: it does
not surface as an error, it leaves the caller's `await` hanging and the screen
spinning forever.

All four methods now answer with `DataState`, `LocalArticleBloc` handles the
failure, and `LocalArticlesError` was added. Rule 1.4.3 says "when requesting
data from an API"; a local database is not an API, but 1.2.3 groups the two,
and a disk error is no less real for being rarer.

The same method also returned `List<ArticleModel>` — models above the data
layer, against rule 2.4.2. It returns entities now, and that turned out to be
load-bearing: `RemoteArticlesBloc` contained
`dataState is DataSuccess<List<dynamic>> || dataState is DataSuccess`, a
workaround for the fact that a `DataSuccess<List<ArticleModel>>` fails an
`is DataSuccess<List<ArticleEntity>>` check. With the leak fixed the plain
check works and the workaround is gone.

### 65. Business logic had settled in a cubit
`JournalistStatsCubit` computed `totalViews` with a `fold` over the articles —
a business rule ("readers reached across everything they published") living in
the presentation layer, against rule 3.2.1.

It became `JournalistStatsEntity.of(articles)` plus a
`GetJournalistStatsUseCase`. The cubit now asks and reports, which is all a
cubit should do, and the rule is testable without a widget in sight.

A smaller one of the same kind: `FirestoreArticleService` decided what counted
as a search match. That is a statement about an article, so it became
`JournalistArticleEntity.matches(query)`; the data source only applies it,
because Firestore has no substring search to delegate to.

### 66. Folders and names the documents already specified
- `daily_news/domain/usecases` → `use_cases`, and
  `daily_news/presentation/pages` → `screens`. `APP_ARCHITECTURE.md` names
  both, and the other two features already followed it. Decision #2 left them
  alone "to keep the diff of this stage focused"; this is that stage.
- `GetArticleUseCase` → `GetArticlesUseCase`, `GetSavedArticleUseCase` →
  `GetSavedArticlesUseCase`. Both return lists, and a singular name for a
  plural result is CG2.2 disinformation.
- `lib/core/shared/` → `lib/shared/ui/presentation/`. The document puts
  `shared` beside `core` and `features`, not inside `core`. The distinction
  earns its keep: `core` is layer-neutral and the domain imports from it,
  while everything in `shared/` is Flutter. Keeping seven widgets in `core`
  meant the domain's allowed import path led to `flutter/material.dart`.
  The remaining deviation — the document shows `shared/{feature}/` as full
  clean folders, and this is a UI toolkit with only a presentation layer — is
  recorded here rather than faked with empty `data/` and `domain/` folders.

### 67. `ARCHITECTURE_VIOLATIONS.md` became executable
`test/architecture_test.dart` encodes every rule in that document that can be
decided from imports and file names: the three layer-dependency rules, the
provider-import rule with its exact exception list, the three model rules
(1.3.1–1.3.3), repository naming and `DataState` returns, the domain's purity,
"only blocs touch use cases", and the folder names.

The point is that the document says these are checked by a reviewer — in this
project, by the author reviewing their own pull request, which is the weakest
form of review there is. Eighteen tests do it instead, and they name the file
and the import when they fail.

Two rules are deliberately **not** tested: "no business logic in blocs" and
"widgets should be reusable". Any test claiming to check those would be
checking a proxy for them, and would be worse than the honest prose above.

The suite also asserts that `test/` mirrors `lib/`, with a ceiling on how many
files may still lack a mirrored test. It is a number to lower, never raise;
writing decision #65's new entity and use case without tests is what made it
fail first time.

### 68. Smaller things the audit turned up
- **`kDefaultImage` was not an image.** It was a Google Images *search page*
  URL. Every headline that arrived without a picture asked the network for an
  HTML page and failed to decode it. CG2.2, and a real bug.
- **`LocalArticlesState.props` was `[articles!]`**, and `articles` is null
  while loading — so comparing two loading states threw, and bloc compares
  states on every emit.
- **Two dead constants and one dead parameter**: `categoryQuery` had no
  readers left after decision #58 made the category dynamic.
- **`ArticleModel` had neither `toEntity()` nor `fromRawData`** (rules 1.3.2
  and 1.3.3). It has both; `fromJson` stays as the alias Retrofit's generated
  code calls.
- **Formatting.** The legacy files were written with spaced generics
  (`List < Object ? >`). `dart format` now passes over `lib/` and `test/` with
  no diff.
- **CG3.1 on the two worst offenders.** `_buildForm` (92 lines) and
  `JournalistArticleTile.build` (83) became named parts. The remaining 50–80
  line `build` methods are declarative widget trees, not logic, and splitting
  every one of them would trade readability for a metric.

### 69. What the audit did not change, and why
- **`ArticleEntity` is nullable in every field.** It is the starter project's
  shape and the News API genuinely omits fields, but it pushes null handling
  into every screen. Changing it touches the Floor schema, so it waits on the
  same generator that decision #19 is blocked by.
- **The News API key is committed** in `core/constants/constants.dart`. It
  came with the starter project and is a free developer key. It is now
  commented as a known issue rather than left looking deliberate.
- **`daily_news`'s use cases take an entity or an enum directly**, where the
  other two features use a `params/` class. For a single argument the params
  class is ceremony; the inconsistency is real but it is the smaller cost.

## Stage 4 — What a manual pass through the whole app found

### 70. The bugs below were found by testing, not by reading
Every decision from here on answers something that happened on a real device.
The app was walked end to end against a written plan of 172 checks, organised
by flow (cold start, feed, saving, accounts, sign-in, the editor, my articles,
editing something published, the community feed, permissions, theme and text
size, language, and bad network conditions), each check naming what to do and
what should happen. The result was 154 passed, 10 failed, 8 blocked.

Writing the expectations down before running them is what made the failures
worth anything: "the app feels slow" is not a bug report, and "N-01: publish in
airplane mode — expect a failure message; observed: stayed on *Saving…*
forever" is. The ids below (`C-08`, `N-02`, `M-06`) are that plan's, so every
fix can be traced back to the check that caught it.

Several failures turned out to share one cause, which is the main argument for
running the whole plan rather than fixing each report as it arrives — see
decision #71.

### 71. Firestore does not fail a write when the device is offline
Five separate reports — publishing stuck on "Saving…" (`N-01`), a cover image
spinning forever with no message (`N-02`), an image appearing on its own
minutes later when airplane mode was switched off (`N-03`), "Something went
wrong" when saving a new article, and the editor's Save and Publish buttons
going permanently dead — were one bug.

Firestore's SDK does not reject a write made with no connection. It queues it
locally and leaves the returned future **pending** until a server acknowledges
it, which may be never. Cloud Storage behaves the same way: `putData` keeps
retrying across an outage rather than failing. So the repository's `await`
never returned, the cubit never left its `saving` state, and the screen had
nothing to show but a spinner. Nothing was broken — nothing had *answered*.

Every call in the three data sources now runs under a deadline
(`kFirestoreTimeout`, 15s; `kStorageTimeout`, 45s, because an upload carries a
file). A call that runs past it raises Firestore's own `unavailable` code, and
the repository turns that into a failure the domain has a name for.

The deadline lives in the data sources and not in the cubits on purpose: it is
a fact about the provider, and rule 1.2.4 keeps provider facts there. A cubit
that timed out its own use case would be making a statement about Firestore
from the presentation layer.

**An abandoned upload is also cancelled.** Without that, Cloud Storage finished
the upload on its own once signal returned and left a file nothing points at —
which is precisely what `N-03` saw. It is cancelled at the deadline, so giving
up actually gives up.

**A Firestore write, however, cannot be recalled.** The SDK owns the queue and
offers no way to withdraw a pending write, so an article the app has reported
as failed may still reach the server later. This is a real and known
limitation, recorded in Pending work rather than papered over. What the
journalist is told — "No internet connection. Check your connection and try
again." — is true and is the thing they can act on; it is not the same as the
app knowing the write did not happen.

### 72. "No connection" is a failure in its own right
`NetworkUnavailableException` lives in `core/resources/`, next to `DataState`,
because both features need to say it and neither may import the other —
`authentication` and `journalist_articles` are peers. Reaching for one
feature's failure type from the other would be the first crack in the rule that
keeps them apart.

It exists because of what the app used to say instead. Signing in with airplane
mode on reported **"Something went wrong."** — which names nothing, suggests
nothing, and is indistinguishable from a bug in the app, while the one thing
that would have helped was turning the connection back on. Both features now
map the provider's connectivity codes (`unavailable`, `deadline-exceeded`,
`network-request-failed`, `retry-limit-exceeded`) onto it, and both say the
same sentence.

### 73. Firestore's offline cache is kept, for reading only
The Community tab shows articles in airplane mode. That was raised as possibly
a bug; it is Firestore's local cache, and it is kept deliberately.

Reading never needs an account (decision #31) and, now, never needs a
connection either: it is the same promise the Saved tab already makes with its
local database. The alternative — `persistenceEnabled: false` — would make
Community fail in airplane mode for consistency with the News tab, and
consistency is not worth taking a working feature away.

Writes are a different matter, and decision #71 is what makes the split safe:
reads may come from the cache, writes must be confirmed by a server or
reported. The cache is why a reader sees last week's articles on a plane, and
the deadline is why they are told when their own article did not get out.

### 74. The editor's busyness is not its status
The editor's buttons were disabled while `status == saving`. Typing sets the
status back to `editing`. So a keystroke during a save announced the editor
idle while a write was still in the air, and pressing Save then started a
second one: a new article was created **twice**.

`ArticleEditorState` now carries `isSaving` alongside `status`, and `isBusy`
reads that. `save()` and `publish()` return early when a write is already
running, so the two can no longer race, and `_emitFailure` clears the flag —
leaving it set is what left both buttons dead with no way out of the editor
but discarding the work.

The related report — "Save on a brand new article freezes the editor" — had two
halves. The freeze was decision #71's missing deadline. The *looking* frozen
was this: `_AutosaveNote` only rendered for an article that had already been
stored, so a first save disabled both buttons and put nothing on screen. It now
says "Saving…" whenever a save is in flight, stored or not.

### 75. Publishing is not offered on something already published
The editor showed Save changes *and* Publish on an article that was already
out. Publish on it re-ran the publish use case and pushed the journalist
through the "published!" confirmation screen again, for an article that had
been published for days.

It is now hidden once `article.isPublished`, and Save changes takes the filled
button it leaves behind — on a live article, saving *is* the main action.
`markAsPublished` already refused to move `publishedAt` on a second call
(decision #42), so nothing was corrupted; the button was simply a lie about
what it did. This closes Pending work item 6b, from the other direction: not
"disable Save draft", but "stop offering Publish".

### 76. One failure, one message, and it stays until it is dealt with
Getting a field wrong produced **two** messages at once: a red banner under the
form and a snack bar at the bottom of the screen, saying the same thing in two
places, one of which took itself back after four seconds.

The snack bar is gone from every error path — the editor, My articles and the
account screen. `AlertBanner` is the single way the app reports a failure: it
stays until the next attempt clears it, it carries an icon so the meaning does
not rest on colour, and it is a live region so a screen reader announces it.

Two things changed with it:
- **The editor's banner moved above the article.** It was at the bottom of a
  long scrolling form, below the fold, where the journalist never saw it — so
  in practice the snack bar *was* the only message, and it was the one that
  disappeared.
- **It now shows for every failure, not only validation errors.** A refused
  publish and a lost connection are equally worth saying.

Snack bars are kept for the two things they are good at: a confirmation with an
Undo, and an acknowledgement that something worked. Neither is an error.

### 77. A session failure belongs to the screen that caused it
`SessionCubit` is one instance for the whole app (decision #31's route guards
depend on that), so the failure it holds outlived the screen that produced it.
Mistyping a password on sign-up and then tapping "Already have an account?"
showed the same red message, word for word, on the sign-in screen — about
something that had not happened there.

`clearFailure()` drops it, and every screen that displays a session failure
calls it on arrival. Clearing does not sign anybody out: it returns the status
to signed-in or signed-out, whichever is true.

The alternative — a failure per screen — would mean a cubit per screen, and the
session is genuinely one fact about the app. The failure is the part that is
local, so the screens own clearing it.

### 78. The Undo snack bar was permanent, not slow
"Removed from saved · Undo" never went away. It was still there a minute later,
and it followed the reader into the other tabs, offering to put back an article
they could no longer see.

The obvious reading was a duration problem, and the obvious fix — an explicit
four seconds — changed nothing. A test reproduced it, which is what made it
findable: `SnackBar.persist` defaults to `action != null`. **Offering Undo at
all is what made the message permanent.** Flutter starts the dismissal timer
and then returns from it without doing anything.

`persist: false` is now passed explicitly. Undo is a courtesy with a deadline,
not a decision the app is waiting on, and the article is still in the list to
be saved again.

Two further things, both true regardless:
- The duration is stated (`kUndoDuration`) instead of inherited, so the next
  reader of this code does not have to know Flutter's default.
- `AppShell` clears snack bars when the tab changes. The messenger belongs to
  the shell and the tabs are kept alive in an `IndexedStack`, so a message
  raised in Saved could still be on screen in News. A message belongs to the
  screen that raised it.

This one is worth keeping as a story: the first fix was plausible, addressed
the symptom, and was wrong. Writing the failing test first is what found the
real cause.

### 79. Renaming the byline rewrites the back catalogue
The byline is copied onto each article as it is saved, so changing the name on
the account applied only to the *next* one. Everything already published kept
the name it was written under, and nothing on the screen admitted it.

That is defensible for a pen name deliberately retired. It is wrong for the far
commoner case: a name typed in a hurry at sign-up, or simply corrected. Somebody
who changes the name readers see means the name readers see.

`UpdateArticlesBylineUseCase` rewrites `author` on every article the journalist
owns, in one Firestore batch — the rename lands on the whole catalogue or on
none of it, so readers never meet two names for the same person. Articles
already carrying the name are skipped, which makes a repeat rename free.

**Only the byline moves.** `updatedAt`, `publishedAt` and `viewCount` are
untouched, for exactly the reason decision #42 gives about editing: being
renamed is not an edit, so it must not reorder the public feed or claim the
article was revised. Sending only the `author` key is also what keeps
`firestore.rules` happy, since an update writes only the keys it names.

**It is a use case, not a side effect of signing in.** `authentication` knows
nothing about articles and must not start to, so the account screen performs
the second step through `ArticleBylineCubit` after the first one succeeds. A
name the account itself refused never reaches the articles — that would sign
somebody's work with something they are not called — and if the second write
fails, the screen says so. Two writes to two backends can come apart, and a
silent half-rename is the kind of thing an author only finds out from a reader.

### 80. A blank name publishes as Anonymous, not as your email
`AppUserEntity.authorName` fell back to the part of the email before the `@`.
Leaving the optional name blank therefore published a piece of somebody's
address to every reader — from a field the sign-up screen told them they could
skip.

It falls back to `Anonymous`. The constant is not translated: it is stored on
the article as the byline, and a name that changed with the reader's language
would not be a name.

### 81. `[+2431 chars]` is the API talking, not the journalist
Articles ended mid-sentence followed by `[+2431 chars]`. That is the News API's
free tier: it sends roughly the first 200 characters and marks the cut. The
marker was being rendered as though a journalist had typed it.

It is stripped in `ArticleModel.fromRawData`, where the API's other quirks are
already handled. Two limits on how much is stripped:
- **Only at the very end.** Square brackets are ordinary punctuation in a news
  story — an editorial insertion, most often — and stripping them anywhere else
  would be rewriting the article.
- **The ellipsis stays.** It honestly says the text stops mid-sentence, and it
  cannot be told apart from one the journalist wrote.

The text still ends mid-sentence, because that is the tier and not something
the app can fix. So the reader screen says so, and shows the source address.
Opening it needs a browser (`url_launcher`) or an in-app view; the address is
selectable in the meantime, and the launcher is in Pending work rather than
pulled in at the end of a bug-fixing pass.

### 82. The language is the device's language, not the first one it still lists
A phone switched to French came up in **Spanish**, and switching the language
with the app open hung it on the launch screen.

The first half was ours. Android hands over an ordered *list* of every language
the person has configured, and Flutter's default resolution walks it looking
for one the app supports — so French first with Spanish left further down the
list resolved to Spanish. The person had changed their phone and the app
ignored them, because a language they no longer used happened to be one of the
two it speaks. `AppLocales.resolve` reads only the first entry, which makes
decision #59 ("Spanish on a Spanish device, English everywhere else") literally
what the code does.

The hang is **not explained**, and is recorded in Pending work as still open.
It could not be reproduced by reading: the manifest already declares
`locale|layoutDirection` in `configChanges`, so Android does not recreate the
activity, and the resolution above cannot throw. Decision #83 hardens the one
class of cause that could produce exactly that symptom, but calling it fixed
would be a guess dressed as a finding.

### 83. A bootstrap that can survive running twice
`main()` was not re-entrant. A second run on a warm engine — which Android can
produce when it recreates the activity — gets `[core/duplicate-app]` from
Firebase and a throw from `get_it`, and either one stops `main()` **before**
`runApp`. The result is the launch screen, forever, with no error.

Both are now guarded: Firebase initialises only when no app exists, and the
container only when it is empty. It costs two lines and removes a whole class
of silent, unrecoverable startup failure — including, possibly, the one in
decision #82. "Possibly" is doing real work in that sentence.

### 84. The app has a name and a mark: Byline
The sign-in screen opened on a bare "Sign in" app bar over two fields, which is
a form rather than a front door — nothing on it said what was being signed in
to. The launcher showed `news_app_clean_architecture`.

The app is called **Byline**: the line under a piece of writing that says who
wrote it, which is the whole of what this feature added. Chosen over "Symmetry
News" (borrows the reviewer's name for a product that is not theirs) and "Daily
News" (the name of one tab, and generic).

The mark is two bars — a headline and a shorter, lighter one below it — drawn
rather than shipped as an image, so it stays sharp at any size and follows the
accent colour. `assets/branding/app_icon.svg` is the same drawing, and the
launcher icons are generated from it by `flutter_launcher_icons`, so the icon
has one source instead of a folder of hand-exported PNGs that drift apart. The
adaptive foreground is supplied separately because Android crops the icon to
whatever shape the launcher uses and only guarantees the middle of it.

The header is compact on sign-up: four fields and a helper line cannot afford
the full mark on a short phone, and a form that needs scrolling to reach its
own button is worse than a smaller logo.

### 85. Two overflows, one cause
A 50-character display name — legal, and enforced — ran off the right of the
account row and squeezed the label out of the screen. The row gave the label
`Expanded` and the value nothing, so there was no room for the value to shrink
*into*: `Expanded` takes everything left.

The value is now `Flexible`, with `maxLines: 1` and an ellipsis. The label keeps
at least half the row, a long value gives way, and a short one still takes only
what it needs. The heading above got the same treatment at display size.

The test pins it by asserting no exception on a 360pt-wide screen: a
`RenderFlex` overflow is reported as an exception by the test binding, which is
the same thing as the yellow-and-black stripes in the app.

### 86. The account summary is read again when its tab is opened
The article and view counts never moved. They were read once, when the tab was
first built, and the tab is kept alive behind the others by the `IndexedStack`
— so publishing an article or being read by somebody moved the numbers on the
backend while the screen went on showing what it had read at startup.

`AppShell` refreshes them on the way into the Account tab. The shell is the
composition root and already reaches for the saved-articles bloc there, so this
is the established pattern rather than a new one; the screen still knows
nothing about tabs.

A listener on the articles collection would keep them live without a tab
change. It is more machinery and a standing Firestore read for a number nobody
is looking at, and "correct whenever you look at it" is what a summary needs.

### 87. What this pass did **not** fix
- **The password reset link does not work (`E-08`).** Following it reports
  "expired or already used". No Flutter code is involved: the link is minted
  and consumed by Firebase, and the app's part (`sendPasswordResetEmail`) is
  confirmed working by the email arriving. The likeliest causes are that only
  the most recent link for an address is valid — several were requested while
  testing `E-06` and `E-07` — or that an email scanner followed the link before
  the person did, which consumes a one-time code. Both are checked from the
  Firebase console, not from here. Left open rather than guessed at.
- **The 5 MB image rule is effectively unreachable (`G-09`).**
  `ImagePickerService` shrinks every non-animated image to 1200px at quality 85
  *before* the rule sees it, so an ordinary photograph can no longer breach it.
  Only a GIF, which skips shrinking so it is not flattened to a still frame,
  can still arrive over the limit. The rule is not wrong — it is the last line
  of defence and it matches `storage.rules` — but the check can only be
  exercised with an animated GIF over 5 MiB, which is what the QA fixture now
  is. Worth knowing before anyone reports the rule as dead code.
- **An empty news section could not be found (`B-07`).** Every category the
  News API answered had articles, so the empty state was never reached by hand.
  It is covered by a test, which is weaker than seeing it but not nothing.

### 88. The gap in the account rows was the F-05 fix
Stopping a 50-character name from overflowing (decision #85) introduced a
visible bug of its own: in both account rows the value and the chevron sat
noticeably short of the right edge — by roughly 300 of 768 logical pixels, as
the regression test now measures.

`Expanded` and `Flexible` in the same `Row` do not mean "one takes the rest and
the other gives way". They share the free space by flex factor: the tight
`Expanded` label took exactly half, the loose `Flexible` value took only the
width of "2", and `Row` left the remainder **after the last child** — so the
whole right-hand group was pushed inward.

The label is the only stretching child again, and the value is capped by a
`ConstrainedBox` at half the row instead of being flexible. It therefore takes
the width it needs, sits against the chevron, and a name at its length limit is
still cut short rather than overflowing.

What makes this worth a decision rather than a quiet amend is how it was
caught: not by the test written for decision #85, which asserted the absence of
an overflow and passed either way. It took someone looking at the screen. The
test added now measures the chevron against the row's right edge, and it was
checked against the broken layout before being kept — a layout test that cannot
fail is furniture.

### 89. Reviewing stage 4 against the three rule documents
The audit that decision #67 describes, run again over only the code decisions
#70–#88 added. Layer boundaries were checked mechanically — no data layer file
reaches for `presentation/` or `use_cases/` (1.1.1, 1.1.2), no domain file
imports another module or Flutter (2.1.1), no presentation file touches
`data/` or a provider SDK (3.1.1, 3.2.3), and the four provider imports outside
`data_sources` are still exactly the four that decision #63 pinned by path.

Three things changed as a result:
- **`ArticleBylineState.renamedCount` was state nobody read.** The cubit
  carried the number of articles a rename had reached and the screen ignored
  it, which is the kind of field that survives three refactors before somebody
  notices it means nothing (CG5.3). It now earns its place: renaming reaches
  back over work that is already public, which a dialog asking only for a name
  does not suggest, so when it moves something the screen says so — and stays
  quiet when it moved nothing, because somebody who has not published yet does
  not need to be told that nothing was republished.
- **`FirestoreArticleService.updateAuthorName` did three things** — query,
  filter, batch-write — in one body (CG3.3). It is now two named parts,
  `_articlesNotYetSignedBy` and `_writeAuthorName`, the same way
  `_publishedArticlesQuery` was already split out of `getPublishedArticles`.
- **The `_AccountRow` layout**, decision #88.

Two deviations are kept deliberately:
- **`lib/config/localization/` is a folder `APP_ARCHITECTURE.md` does not
  list**, which shows only `routes` and `theme` under `config`. Choosing the
  app's language is configuration in exactly the same sense those are: it is
  read once by `MaterialApp` and belongs to no feature. Putting it in `core/`
  would have been the alternative and is worse — `core` is what the layers
  share, and nothing below the widget tree has an opinion about locale.
- **The write use cases answer with a value** (`DataState<int>` here, the
  stored entity elsewhere), which is not command/query separation (CG3.6).
  It is not a choice: rule 1.4.3 requires a `DataState<Type>` back from a
  repository, so every write in this codebase answers something. The
  alternative — a write returning `DataState<void>` and a second read to find
  out what happened — is two round trips and a race.

## Pending work

Open items, kept here so the report can state them rather than have a reviewer
find them. Roughly in the order they are worth doing.

| # | Pending | Why it is still open |
|---|---------|----------------------|
| ~~1~~ | ~~Run the app end to end against the real project~~ | **Done.** A written plan of 172 checks was walked on a device: 154 passed, 10 failed, 8 blocked. Decisions #70–#87 are what came out of it |
| ~~1b~~ | ~~See the Spanish UI on a device~~ | **Done** in the same pass. Every screen was walked under `es`; no English was left behind and nothing was clipped. What it did turn up was the language *resolution* bug of decision #82 |
| 2 | Security rules unit tests (`@firebase/rules-unit-testing`) | The rules of decision #34 are known to compile and are deployed. Nothing proves they allow and deny exactly what they claim. This is the biggest verification gap in the project |
| ~~3~~ | ~~A test for the `_guard` clause in both repositories (decision #38)~~ | **Done.** No interface was needed: a fake can `implements` the concrete data source directly (decision #61) |
| 3b | `ArticleEntity`'s all-nullable fields, and the News API key in source | Both argued in decision #69; both wait on the generator of decision #19 or on a secrets story |
| 4 | The Figma UI | Every screen in `journalist_articles` and `authentication` is a deliberate skeleton (decisions #14 and #28), meant to be replaced rather than extended. The brief for it is `docs/FIGMA_PROMPT.md`, which also records the navigation change it proposes: the app bar's four unlabelled icons become a labelled bottom navigation bar, because unlabelled icons fail the review's "90 year old grandmother" criterion outright |
| 5 | `docs/REPORT.md` | Required by `README.md` and by `docs/REPORT_INSTRUCTIONS.md`. Does not exist yet; this file is its raw material |
| 5b | Saving a community article | The design offers it; the data layer cannot. Saved articles live in a Floor table shaped for `ArticleModel`, and a second entity needs a generator that will not run (decisions #19, #44). Options when it can run: a `JournalistArticleModel` Floor entity, or saved ids in Firestore — the latter would stop a signed-out reader from saving at all |
| ~~6b~~ | ~~UI: disable "Save draft" on an already published article~~ | **Done**, from the other direction: Publish is what is now hidden on a published article, and Save changes takes its place (decision #75) |
| 6c | UI: show `publishedAt` and `updatedAt` as distinct facts | They are now genuinely different values (decision #42). The editor and the article tiles should say "published on X, edited on Y" rather than showing one date |
| 7 | Google sign-in | Evaluated and deferred, decision #37 |
| 8 | Migrate to Flutter's Built-in Kotlin | The build warns that applying the Kotlin Gradle Plugin will stop working in a future Flutter, and names `firebase_auth`, `firebase_core` and `firebase_storage` as the plugins still doing it. Not actionable by us until those plugins migrate |
| 9 | A Firestore write reported as failed may still land | Decision #71. The SDK owns the offline queue and offers no way to withdraw a pending write, so an article the app has reported as unconfirmed can reach the server later. The person is told their connection is the problem, which is true and actionable, but the app does not actually know whether the write happened. A fix needs either a connectivity check before the write or a server-side idempotency key |
| 10 | The password reset link (`E-08`) | Decision #87. Not app code: the link is minted and consumed by Firebase. Needs a look at the console's email template, the authorised domains, and whether an email scanner is burning the one-time code |
| 11 | The launch-screen hang on a live language change (`M-06`) | Decision #82. Not reproduced from the code, and not explained. Decision #83 removes the one class of cause that fits the symptom; that is a mitigation, not a diagnosis. Needs a device, a logcat and a deliberate attempt to reproduce |
| 12 | Open a news article at its source | Decision #81. The reader shows the address as selectable text because the News API's free tier only sends a preview. `url_launcher` (or an in-app web view) would make it a tap. Left out of a bug-fixing pass rather than added at the end of one |
