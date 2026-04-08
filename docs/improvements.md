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

### IMP-001 — Widget tests for community publishing UI

`PublishArticlePage` and `CommunityFeedPage` have no widget tests. They contain
non-trivial UI logic that warrants pinning:

- Validation: empty title shows inline error and blocks submit
- Image picker: loaded → preview → replace → remove transitions
- Submit: shows "Uploading image…" then "Publishing…" then pops
- Snackbars: each error path produces the right message
- Empty state: shows the "Be the first" CTA copy
- Loaded state: card renders title, description, image, date

**Affected files:**
- `test/features/community_articles/presentation/pages/publish_article_page_test.dart` (new)
- `test/features/community_articles/presentation/pages/community_feed_page_test.dart` (new)

**Estimated effort:** 3-4 hours

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

### IMP-006 — Pre-existing analyzer info warnings

`flutter analyze lib/` reports 3 `info` items that have been there since the
project was forked. They are not blockers but should be cleaned up:

- `news_api_service.g.dart:10` — generated file with unused `baseUrl`
- `article_tile.dart:64` — `prefer_const_constructors`
- `article_tile.dart:78` — `prefer_const_constructors`

The `.g.dart` one is auto-generated and would be regenerated on next
`build_runner` run; not worth manual fixing. The other two are trivial.

**Affected files:**
- `frontend/lib/features/daily_news/presentation/widgets/article_tile.dart`

**Estimated effort:** 5 minutes

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
