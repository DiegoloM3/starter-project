---
id: 008-community-cubit-to-bloc
title: "Migrate Community Articles from Cubit to Bloc"
status: deprecated
version: 1.0.0
---

> **ABORTED — never implemented.** See `## Why Aborted` at the bottom for the
> technical reasoning. This spec is preserved as an audit trail so that future
> engineers see we considered this migration and decided against it on
> technical merit, not by oversight.

## User Problem

Spec 003 (Deviation #1) explicitly chose to use `Cubit` for the
`community_articles` feed because the inputs were simple. The pre-existing
`daily_news` feature uses event-driven `Bloc<Event, State>`. The result is
**two state-management styles in the same codebase**, which is exactly the
"minor inconsistency" that spec 003 flagged as a tradeoff.

The cost of leaving it:

1. A new contributor sees two patterns and has to ask which one to follow.
2. Code review must distinguish "this is a Cubit" from "this is a Bloc"
   every time.
3. Future tests will be written in two different styles.

This spec closes the deviation by aligning the community feature with the
existing project convention.

## Solution Hypothesis

Replace `CommunityFeedCubit` with a `Bloc<CommunityFeedEvent, CommunityFeedState>`
that mirrors the structure of `daily_news/.../local_article_bloc.dart`:

- Three files: `community_feed_bloc.dart`, `community_feed_event.dart`,
  `community_feed_state.dart`.
- Each public action becomes an event class:
  - `cubit.start()` → `WatchCommunityArticles` event
  - `cubit.publish(article)` → `PublishCommunityArticle` event
  - `cubit.uploadImage(uid, file)` → `UploadCommunityArticleImage` event
  - `cubit.deleteArticle(...)` → `DeleteCommunityArticle` event
  - `cubit.updateArticle(...)` → `UpdateCommunityArticle` event
- The bloc subscribes to `repository.watchArticles()` and forwards each
  emission via `emit.forEach` (the canonical bloc-with-stream pattern).
- The state class hierarchy stays the same (`Loading`, `Loaded`, `Error`).
- Public-facing return values (e.g. `publish` returning the new doc id,
  `uploadImage` returning the URL) require careful handling because Bloc
  events are fire-and-forget. **They will be moved to the bloc as
  read-only methods that delegate to the repository directly**, NOT
  through the event stream. This preserves the existing UI flow where the
  publish form awaits the result.

## Success Metrics

- [ ] `community_feed_cubit.dart` and `community_feed_state.dart` are
  replaced by `community_feed_bloc.dart`, `community_feed_event.dart`,
  `community_feed_state.dart`.
- [ ] Every `Cubit` mention in the project is gone (except in comments
  that explicitly cite the migration history).
- [ ] All call sites in `pages/` use `BlocProvider<CommunityFeedBloc>`
  and `context.read<CommunityFeedBloc>().add(...)` for stream-driven
  state changes.
- [ ] Methods that need a return value (publish, upload, update, delete
  with awaitable success) are exposed as plain methods on the bloc that
  delegate to the repository — same approach as if they were Cubit
  methods, just hosted on a Bloc class.
- [ ] All existing tests are updated to the new API and pass.
- [ ] Manual smoke test confirms no regression on iOS simulator.

## User Story

As a **new contributor** opening the codebase, I want every state
management class to follow the same pattern, so that I don't have to ask
"is this a Bloc or a Cubit?" before I can read the code.

## Acceptance Criteria

### Scenario 1: Bloc files exist with the right structure

- **Given** the community_articles feature
- **When** the bloc folder is listed
- **Then** it contains exactly:
  `community_feed_bloc.dart`, `community_feed_event.dart`,
  `community_feed_state.dart`
- **And** no `community_feed_cubit.dart` remains

### Scenario 2: Bloc has explicit event classes

- **Given** `community_feed_event.dart`
- **When** the file is reviewed
- **Then** it defines `abstract class CommunityFeedEvent extends Equatable`
  and concrete subclasses for each user action that drives state changes
- **And** the events follow the same naming and equatable convention as
  `local_article_event.dart`

### Scenario 3: Stream subscription via `emit.forEach`

- **Given** `CommunityFeedBloc`
- **When** the `WatchCommunityArticles` handler runs
- **Then** it uses `emit.forEach(repository.watchArticles(), onData: ...,
  onError: ...)` so the bloc is canonically reactive to the Firestore stream

### Scenario 4: Awaitable methods preserved

- **Given** the publish form needs to know if a `publish` succeeded
- **When** it calls `bloc.publish(article)`
- **Then** the bloc returns the Firestore doc id (as before)
- **And** internally the bloc delegates to `repository.publishArticle`
- **And** the return value is **not** routed through the event stream

### Scenario 5: All UI and DI sites updated

- **Given** the app
- **When** searched for `CommunityFeedCubit`
- **Then** zero references remain
- **And** every former reference now points to `CommunityFeedBloc`

### Scenario 6: All tests still pass

- **Given** the test suite
- **When** the migration is complete
- **Then** every test passes
- **And** the test files are updated to instantiate `CommunityFeedBloc`
  instead of `CommunityFeedCubit`
- **And** stream-driven assertions use `bloc.add(WatchCommunityArticles())`
  instead of `cubit.start()`

### Scenario 7: Manual smoke test confirms no regression

- **Given** the app on the iOS simulator
- **When** the user navigates Daily News → Community → publish → edit → delete
- **Then** every screen renders and behaves identically to before the
  migration

## Implementation Checklist

- [ ] Create `community_feed_event.dart` with `WatchCommunityArticles`
  event (publish/upload/update/delete are direct methods, not events)
- [ ] Create `community_feed_bloc.dart` with `on<WatchCommunityArticles>`
  handler using `emit.forEach`
- [ ] Move the awaitable methods (`publish`, `uploadImage`, `updateArticle`,
  `deleteArticle`) onto the bloc as plain methods
- [ ] Delete `community_feed_cubit.dart`
- [ ] Update `injection_container.dart` to register the bloc
- [ ] Update `main.dart` to provide the bloc
- [ ] Update `community_feed_page.dart`, `publish_article_page.dart`,
  `community_article_detail_page.dart`, `root_screen.dart` to use the bloc
- [ ] Update tests:
  - `community_feed_cubit_test.dart` → `community_feed_bloc_test.dart`
  - `community_feed_page_test.dart` (rename internal references)
  - `publish_article_page_test.dart` (rename internal references)
- [ ] Run the full suite, expect 41/41 passing
- [ ] Manual smoke test on iOS simulator

## Out of Scope (V1)

- Adding use case classes between the bloc and the repository (the
  daily_news pattern uses use cases; community has been direct repository
  access since spec 003 — this spec does NOT introduce use cases).
- Renaming the awaitable methods.
- Touching the data layer, repository, or domain entities.
- Refactoring the daily_news blocs.
- Adding new functionality.

## Assumptions

- The "awaitable methods on the bloc" pattern is acceptable. The strict
  bloc-purist view would route everything through events, but that
  forces the UI to listen to the state stream for "did my publish
  succeed?" — which loses the natural async/await flow that the publish
  form already uses. Hosting them as methods on the bloc class is a
  pragmatic middle ground that mirrors what `LocalArticleBloc` already
  does (its event handlers also call repository methods directly).
- The existing widget tests for `CommunityFeedPage` and
  `PublishArticlePage` can be updated to use the bloc with minimal
  changes — they instantiate the cubit directly and assert on the page,
  so swapping the constructor is a one-line change per file.
- The `_FakeRepository` test helpers stay the same — they implement the
  same `CommunityArticleRepository` interface that both the cubit and
  the bloc consume.

## Open Questions

None. All decisions are resolved before the spec was written.

## Why This Spec Exists

Spec 003 deferred this with Deviation #1. Closing a documented deviation
deserves its own spec so the audit trail in `specs/` shows when and why
the decision changed. This is exactly the same pattern as spec 007
closing spec 006's "Out of Scope" item.

## Why Aborted

After writing the spec but before implementing it, the question
"is the current Cubit implementation actually better than Bloc for this
specific case?" was raised and honestly answered. The answer is **yes,
Cubit is technically better for `community_articles`**. The four reasons:

### 1. Awaitable methods with return values fight the Bloc model

The community feature has four actions that must return a value or signal
explicit success/failure to the caller:

- `publish(article)` → returns `Future<String>` (the new Firestore doc id)
- `uploadImage(uid, file)` → returns `Future<String>` (the download URL)
- `updateArticle(...)` → must signal success so the form can pop and
  return the updated entity to the detail page
- `deleteArticle(...)` → must signal success so the detail page can pop

These are naturally `await`-driven. With Cubit, the form does:

```dart
try {
  await cubit.publish(article);
  Navigator.pop(context);
} catch (_) {
  showSnackBar('Could not publish...');
}
```

A pure-Bloc rewrite would force:

- A `CommunityFeedPublishing` state, a `CommunityFeedPublishSuccess(docId)`
  state, a `CommunityFeedPublishFailure(error)` state
- A `BlocListener` in the publish form
- Logic to disambiguate "this success/failure is mine, not someone else's"
  because the bloc may be shared across pages
- Loss of the natural `try / await / catch` flow that the form already
  uses correctly

That is a lot of boilerplate for zero behaviour change.

### 2. The community feature has none of the benefits Bloc events were
designed for

Bloc events shine when you need:

- An audit log of "what happened" for time-travel debugging in DevTools
- Throttling, debouncing, or `bloc_concurrency` transformers
- A clear state machine of user intentions (e.g. form wizards)

Community has 5 simple actions. None of those benefits apply.

### 3. `LocalArticleBloc` in `daily_news` is the wrong example to imitate

Look at what `LocalArticleBloc.onSaveArticle` actually does:

```dart
void onSaveArticle(SaveArticle event, Emitter emit) async {
  await _saveArticleUseCase(params: saveArticle.article);
  final articles = await _getSavedArticleUseCase();
  emit(LocalArticlesDone(articles));
}
```

That is functionally a Cubit method with an event wrapper on top. The
event contributes nothing — it is not logged, transformed, throttled, or
debounced. It is then called with a `_saveArticleUseCase` that wraps a
single repository call, which `AGENTS.md` §3 Phase C explicitly warns
against ("a use case that wraps a single repository call with no logic
is ceremony, not architecture").

`daily_news` is over-engineered. Migrating community to match it would
**propagate the ceremony**, not resolve a real inconsistency.

### 4. The "right" fix for consistency would be the opposite

If the only goal is "one state-management style in the codebase",
the cleaner direction is **`daily_news` → Cubit**, not community → Bloc.
Daily_news doesn't actually need events either.

But touching `daily_news` is high-risk: it works, it has no tests
beyond the architectural ones from spec 001, and its event-driven
plumbing is reasonably well understood by anyone who has seen
`flutter_bloc` once. Rewriting working code for stylistic consistency
is exactly the kind of change `AGENTS.md` §4 ("Build the right thing
before building it right") cautions against.

## Outcome

- Spec 008 is `deprecated`. No code change.
- Spec 003 Deviation #1 is updated with this technical reasoning so
  the next reader of `specs/` sees the choice as deliberate, not
  defaulted.
- Mixed Cubit + Bloc remains a documented, deliberate choice in the
  codebase. If the codebase grows enough that this becomes a real
  cost, the right move at that point would be to migrate `daily_news`
  to Cubit, not the other way around.
