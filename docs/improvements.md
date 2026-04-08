# Improvements & Known Deviations

> This file tracks two things:
> 1. **Known deviations** from the project constitution — intentional shortcuts taken
>    under time constraints, documented honestly per *Truth is King* and *Total Accountability*.
> 2. **Backlog items** — improvements identified during development that are out of scope
>    for this iteration but worth returning to.
>
> Nothing in this file is hidden. Every entry is a deliberate, documented decision.

---

## Known Deviations from Constitution

### DEV-001 — Tests not retroactively backfilled to 100% coverage

**Constitution rule violated:** AGENTS.md §4 ("Every spec must ship with
automated tests that exercise its acceptance criteria") and §3 Phase E
("Every acceptance criterion has at least one automated test that proves it").

**Affected scope:** specs 001, 002, 003.

**Reason for deviation:** the tests-mandatory rule was added to AGENTS.md
*after* specs 001-003 were marked `implemented`. Backfilling 100% test coverage
retroactively would have blocked the rest of the work in the iteration.

**What was done instead:** unit tests were written for the highest-value
surfaces (entity equality, model conversions, repository delegation, cubit
orchestration). Each spec's `## Test Coverage` section lists what is covered,
what is not, and which specific items live in this file as backlog (IMP-001
through IMP-004).

**Resolution path:** treat the rule as binding for all future specs (004+).
Backfill the items in IMP-001 through IMP-004 when there is capacity.

**Priority:** Medium

### DEV-002 — `firebase_auth 4.16.0` Pigeon decoding workaround

**Constitution rule violated:** none directly, but a workaround in production
code is debt that should be removed.

**Affected scope:** `frontend/lib/core/firebase/emulator_config.dart`

**Reason for deviation:** `firebase_auth 4.16.0` has a known bug
([flutterfire#12274](https://github.com/firebase/flutterfire/issues/12274))
where the iOS native plugin returns a payload the Dart-side Pigeon codec
cannot decode. The sign-in itself completes; only the result decoding fails.

**What was done instead:** wrapped `signInAnonymously()` in `try / on TypeError`
and verified the user via `currentUser` after the call.

**Resolution path:** upgrade to `firebase_auth >= 4.17.4` once the rest of the
Firebase BoM allows it. Remove the try-catch block.

**Priority:** Low (the workaround works correctly).

### DEV-003 — Xcode 26 Podfile fixes

**Constitution rule violated:** none directly. Documented for future engineers.

**Affected scope:** `frontend/ios/Podfile`

**Reason for deviation:** Xcode 26.2's Explicit Module Builds reject
`<Firebase/Firebase.h>` non-modular includes inside the `firebase_auth`,
`firebase_storage`, and `cloud_firestore` Flutter plugin pods.

**What was done instead:** `DEFINES_MODULE = NO` for those three pods in the
post_install hook. They link as frameworks but skip module precompilation.

**Resolution path:** revisit when FlutterFire publishes versions with proper
modular headers. Documented in `docs/DISCOVERY.md` "iOS Podfile — Key Decisions".

**Priority:** Low

---

## Backlog Items

### IMP-001 — Widget tests for community pages (partially done)

**Status:** partially done after the second pass of testing work in this
iteration. What is in:

- `community_feed_page_test.dart` — loading, empty, loaded, and error states
- `publish_article_page_test.dart` — text fields render, Publish action
  renders, validation errors block submit, no errors before submit

**Still missing:**

- Widget test for `CommunityArticleDetailPage` covering the `_isOwner` branch
  for both Edit and Delete buttons. Blocked by direct
  `FirebaseAuth.instance.currentUser` access — would need
  `firebase_auth_mocks` or a UID-injection refactor.
- The image picker flow in `PublishArticlePage` (load → preview → replace →
  remove transitions). Blocked by direct `ImagePicker` use — would need
  a platform channel mock or a picker abstraction.
- The submit happy path (`Uploading image…` → `Publishing…` → pop). Blocked
  by the same `FirebaseAuth.instance.currentUser?.uid` direct access.

**Affected files:**
- `test/features/community_articles/presentation/pages/community_article_detail_page_test.dart` (new — when the auth refactor lands)
- Possibly a small refactor in `publish_article_page.dart` and
  `community_article_detail_page.dart` to inject the current user's UID
  rather than reading it from a static instance.

**Estimated remaining effort:** 1-2 hours of refactor + 1-2 hours of tests

### IMP-002 — Integration tests for Firestore datasource against the emulator

`CommunityArticleFirestoreDataSource` is currently exercised only by the manual
end-to-end run. The mapping logic (`Timestamp` → ISO 8601, document → entity,
Storage path composition) is plain enough to fake but worth pinning against
the real emulator to catch SDK breaking changes.

**Affected files:**
- `integration_test/community_article_firestore_datasource_test.dart` (new)
- Test infra: a `setUpAll` that boots the emulator if needed, or assumes it is
  already running.

**Estimated effort:** 2-3 hours

### IMP-003 — Firestore security rules tests

The strict rules (`request.auth != null`, `request.resource.data.uid ==
request.auth.uid`) were verified manually with `curl` during implementation.
They should be pinned with `@firebase/rules-unit-testing`. This is independent
of the Flutter app — pure JS / TS suite that runs against the Firestore
emulator.

**Suite to write:**
- Unauth read of `articles/{id}` → allowed
- Unauth write to `articles/{id}` → denied
- Auth user with UID `A` writing `{uid: 'A', ...}` → allowed
- Auth user with UID `A` writing `{uid: 'B', ...}` → denied
- Auth user with UID `A` deleting a document where `uid: 'B'` → denied

**Affected files:**
- `tests/rules/firestore.test.ts` (new, repo root)
- `package.json` with `@firebase/rules-unit-testing`

**Estimated effort:** 2-3 hours

### IMP-004 — Repository test for `getNewsArticles`

The retrofit-based remote path of `ArticleRepositoryImpl` is not unit-tested
because faking `HttpResponse<List<ArticleModel>>` requires a real `Dio`
instance. Options:

1. Use a `MockDio` that returns canned responses, then construct `HttpResponse`
   manually.
2. Refactor `NewsApiService` to return a plain `Future<List<ArticleModel>>` and
   move the HTTP-status handling into the data source. This makes faking
   trivial and removes Dio knowledge from the repository.

Option 2 is cleaner but is a real refactor of a working code path. Defer
unless we touch this surface again.

**Affected files:**
- `test/features/daily_news/data/repository/article_repository_impl_test.dart`
- Possibly `lib/features/daily_news/data/data_sources/remote/news_api_service.dart`

**Estimated effort:** 1-2 hours (option 1) or 3-4 hours (option 2)

### IMP-005 — Orphan image cleanup

If the image upload to Firebase Storage succeeds but the Firestore document
write fails, the uploaded file becomes an orphan. There is no cleanup pass.

**Resolution options:**
- Cloud Function trigger that deletes images with no matching Firestore doc.
- Storage lifecycle rule that deletes files older than X days with no metadata.
- Client-side rollback: catch the publish error and call `ref.delete()`.

**Affected files:**
- `lib/features/community_articles/presentation/pages/publish_article_page.dart` (client-side option)
- Or new Cloud Function (out of current scope)

**Estimated effort:** 1 hour (client-side) to 4 hours (Cloud Function)

### IMP-006 — Pre-existing analyzer info warnings (closed)

**Status:** closed. The two `prefer_const_constructors` warnings in
`article_tile.dart` were fixed in the same session that added IMP-001. The
remaining `.g.dart` info is auto-generated by retrofit and would be
regenerated on the next `build_runner` run, so it is left alone.

`flutter analyze lib/` now reports a single info item, all in the
auto-generated file:

- `news_api_service.g.dart:10` — generated file with unused `baseUrl` (cannot
  fix without re-running `build_runner`, which is out of scope here)

### IMP-007 — Display name on community articles

Spec 003 explicitly defers user profiles to V2. The result is that every
community article card shows no author at all. The minimum viable improvement
would be to render `'Anonymous'` or to expose a one-time "set your display
name" prompt that stores the name in `FirebaseAuth.currentUser.updateDisplayName`
and writes it into the article document.

**Affected files:**
- `frontend/lib/features/community_articles/data/data_sources/remote/community_article_firestore_datasource.dart`
- `frontend/lib/features/community_articles/presentation/pages/community_feed_page.dart`
- `frontend/lib/features/daily_news/domain/entities/article.dart` (add `displayName`)

**Estimated effort:** 1-2 hours

### IMP-008 — Gradle / AGP / Kotlin upgrades

`flutter doctor -v` warns that the project's Gradle/AGP/Kotlin versions are
below upcoming Flutter minimums. Currently non-blocking. Logged in
`docs/DISCOVERY.md` under "What Doesn't Work".

**Affected files:** `frontend/android/` build configs

**Estimated effort:** 1-2 hours
