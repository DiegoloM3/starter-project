---
id: 003-user-article-publishing
title: "User Article Publishing"
status: implemented
version: 1.0.0
---

## User Problem

Today the app is purely consumptive: users read curated NewsAPI headlines and can
save them locally. There is no way to contribute, comment, or share their own
perspective. The platform is passive — users have no reason to come back beyond
the next batch of news.

The cost of not having this:
- Zero user-generated content → no community, no stickiness, no reason to return.
- The FAB on the home screen is visible but unconnected, suggesting an unfinished
  product.
- The Firebase infrastructure built in spec 002 has no consumer.

## Solution Hypothesis

Allow any anonymous user to publish a short text article (with an optional image)
that becomes immediately visible to every other user. Publishing flow:

1. User taps the FAB on the home screen
2. A simple form opens (title, description, content, optional image)
3. On submit, the article is written to Firestore + image uploaded to Storage
4. The article appears in a new "Community" feed, separate from the curated
   NewsAPI feed

**Why separate feeds, not mixed:** mixing curated and user-generated content
forces complex sorting, dedup, and trust logic. Two clear feeds lets the user
choose what they're consuming. It also keeps the existing NewsAPI flow untouched
and reduces the risk of regression.

## Success Metrics

- [ ] A user can publish an article in under 30 seconds (no auth friction).
- [ ] An article published on device A appears on device B within 5 seconds of
  Firestore propagation.
- [ ] At least one happy-path publication completes end-to-end on both Android
  and iOS during validation.
- [ ] All error states (network, validation, upload failure) display a user-
  friendly message — no silent failures, no raw exceptions.

## User Story

As an **app user**, I want to publish my own short article with an optional image,
so that I can share content with the rest of the community without creating an
account.

## Acceptance Criteria

### Scenario 1: Happy path — publish with image

- **Given** the user is on the home screen
- **And** the Firebase emulator is running
- **When** they tap the FAB
- **Then** the "Publish Article" screen opens with empty form fields
- **When** they enter a title, description, and content, then pick an image
- **And** tap "Publish"
- **Then** a loading indicator is shown
- **And** the image is uploaded to Storage
- **And** the article document is written to Firestore with their UID
- **And** the screen returns to the Community feed
- **And** the new article appears at the top of the feed

### Scenario 2: Happy path — publish without image

- **Given** the user is on the "Publish Article" screen
- **When** they fill in title, description, content but skip the image
- **And** tap "Publish"
- **Then** the article is published with `imageUrl = null`
- **And** the Community feed shows the article with a placeholder image

### Scenario 3: Validation — missing required field

- **Given** the user is on the "Publish Article" screen
- **When** they tap "Publish" with an empty title
- **Then** the form shows an inline error under the title field
- **And** the submit action does not proceed
- **And** no Firestore write is attempted

### Scenario 4: Network failure on publish

- **Given** the user has filled in a valid form
- **And** the Firebase emulator is unreachable
- **When** they tap "Publish"
- **Then** a snackbar shows "Could not publish. Check your connection and try again."
- **And** the form retains the user's input (no data loss)
- **And** the user can retry without re-entering anything

### Scenario 5: Image upload failure

- **Given** the user has selected an image
- **And** Firebase Storage is unreachable
- **When** they tap "Publish"
- **Then** the upload fails before the Firestore write is attempted
- **And** a snackbar shows "Could not upload image. Try again or publish without image."
- **And** the user can either retry or remove the image and re-submit

### Scenario 6: Community feed loads

- **Given** at least one article exists in the `articles` Firestore collection
- **When** the user opens the Community tab
- **Then** articles are listed in reverse chronological order (newest first)
- **And** each card shows title, description, image (or placeholder), and
  publishedAt date

### Scenario 7: Empty Community feed

- **Given** the `articles` collection is empty
- **When** the user opens the Community tab
- **Then** an empty state is shown with a CTA pointing at the FAB
  ("Be the first to publish — tap +")

### Scenario 8: Real-time update

- **Given** user A has the Community tab open
- **And** user B publishes a new article
- **Then** within 5 seconds the new article appears at the top of user A's feed
  without manual refresh
- *(Implementation note: use Firestore `snapshots()` not `get()`)*

## Form Fields

| Field        | Type   | Required | Validation                          |
|--------------|--------|----------|-------------------------------------|
| title        | string | yes      | 1–120 chars                         |
| description  | string | yes      | 1–280 chars                         |
| content      | string | yes      | 1–5000 chars                        |
| image        | file   | no       | jpeg/png, ≤5 MB, picked from gallery|

## Navigation Changes

The home screen gains a bottom navigation bar (or tab bar) with two tabs:

1. **Daily News** — existing NewsAPI feed (unchanged)
2. **Community** — new feed of user-published articles (this spec)

The FAB lives on both tabs and always opens the publish screen.

## Out of Scope (V1)

- Editing or deleting your own articles. Publish is one-way for V1.
- Comments, likes, or any social interactions.
- Pagination — V1 loads up to 50 most recent articles in one query.
- User profiles, display names, avatars.
- Camera capture — image picker uses gallery only.
- Image cropping or editing.
- Rich text formatting (bold, links, headings) in `content`.
- Moderation, reporting, or content filtering.
- Push notifications when new articles are published.
- Offline publishing queue — publishing requires an active connection.
- Categories, tags, or search.

## Assumptions

- Spec 002 (Firebase backend) is implemented and the emulator is running.
- The user is automatically signed in anonymously on app start (from spec 002).
- The existing `ArticleEntity` from spec 001 is reused for community articles.
  Two new nullable fields are added: `firestoreId` (string, the Firestore document
  ID) and `uid` (string, the author's Firebase UID). Both are null for NewsAPI
  articles. Rationale: domain entities are allowed to carry optional fields per
  data source. Creating a separate `CommunityArticleEntity` would duplicate every
  field and force two parallel BLoC/repo stacks for no semantic gain.
- The existing `daily_news` BLoC and screens are not modified — only a new tab
  and a new BLoC for Community articles are introduced.
- Image picker plugin (`image_picker`) is added as a new dependency.
- The image is uploaded to Storage at path `articles/{uid}/{timestamp}_{filename}`.
- Validation runs client-side. Server-side enforcement is out of scope for V1.

## Open Questions

None. All decisions resolved before spec was written.

## Deviations

Things that diverged from this spec during implementation. They do not change
the user-visible behaviour but a future engineer should know they exist.

### 1. State management uses `Cubit`, not full `Bloc`

The existing `daily_news` feature uses BLoCs with explicit event classes
(`flutter_bloc`'s `Bloc<Event, State>`). The new community feed uses a `Cubit`
(`Cubit<State>`) instead — `start()`, `publish()`, `uploadImage()`,
`updateArticle()`, and `deleteArticle()` are called directly as methods on
the cubit.

**Why this is the right choice for this feature, not just the easy one:**

1. **Awaitable methods with return values fight the Bloc model.** `publish`
   returns the new doc id. `uploadImage` returns the download URL. `update`
   and `delete` need explicit success/failure signalling so the form can pop
   the navigator on success and show a snackbar on failure. With a Cubit:
   ```dart
   try {
     await cubit.publish(article);
     Navigator.pop(context);
   } catch (_) { showSnackBar('...'); }
   ```
   A pure-Bloc rewrite would force three new states per action
   (`Publishing`, `PublishSuccess(docId)`, `PublishFailure(error)`), a
   `BlocListener`, and disambiguation logic for "this success is mine, not
   someone else's". A lot of boilerplate for zero behaviour change.

2. **None of Bloc's actual benefits apply here.** Bloc events shine when
   you need an audit log for time-travel debugging, throttling/debouncing
   via `bloc_concurrency` transformers, or an explicit state machine of
   user intent. Community has 5 simple, distinct actions and none of those
   needs.

3. **`LocalArticleBloc` in `daily_news` is functionally a Cubit with an
   event wrapper.** Its handlers call use cases that wrap single repo
   calls and emit a new state — exactly what a Cubit method does, with
   more ceremony. Imitating it would propagate the over-engineering, not
   resolve an inconsistency.

The full reasoning is preserved in `specs/008-community-cubit-to-bloc/spec.md`
as a deprecated spec — that migration was considered after spec 003 shipped
and was explicitly aborted on technical merit.

**Tradeoff:** mixing Cubit and Bloc in the same codebase is a minor
visual inconsistency. If the team grows and the inconsistency starts
costing onboarding time, the cleaner fix at that point would be to
migrate `daily_news` to Cubit, not the other way around — but that
work is out of scope and not a current priority.

### 2. `daily_news` did not become a tab inside an existing screen — a new
`RootScreen` was introduced

The spec says "the home screen gains a bottom navigation bar". In practice, the
existing `DailyNews` screen was kept untouched (its FAB was removed) and a new
`RootScreen` was created that hosts both tabs and the FAB. This was needed
because `DailyNews` returns its own `Scaffold` and embedding bottom navigation
inside it would have conflicted with the existing app bar.

**Net effect for the user is the same** as the spec describes — two tabs and a
FAB on the home screen — but the navigation structure has one extra widget in
the tree.

### 3. Storage upload happens before Firestore write — no rollback

Scenarios 4 and 5 of the spec are honoured (image-upload failure shows a
snackbar and aborts the publish; network failure on write shows a snackbar and
preserves form input). What is **not** done: if the image upload succeeds but
the Firestore write fails, the orphan image stays in Storage. There is no
cleanup pass.

**Why deferred:** the spec does not require it, and orphan files in the
emulator are zero cost. For a production deployment with billing, a Cloud
Function trigger that deletes orphans (or a Storage lifecycle rule) would be
the right fix.

### 4. Validation does not enforce a minimum length above 1

The spec's "Form Fields" table says `1-120` for title, etc. The implementation
treats `length >= 1 after trim()` as the minimum. There is no separate "title
must be at least N characters" beyond non-empty. This matches the spec literally
but is worth noting because product copy on `Required` errors uses the phrase
"is too short" — that branch never triggers in practice.

### 5. Anonymous auth UID is the only `uid` written

`uid` is `FirebaseAuth.instance.currentUser!.uid`. There is no display name,
email, or other identity attached. This is consistent with the spec
(`Out of Scope (V1)` lists "User profiles, display names, avatars") but means
all authors render as anonymous in the feed. The card shows no author at all.

## Test Coverage

| Acceptance criterion | Test file / how |
|---------------------|-----------------|
| Scenario 1 (publish with image — happy path) | `test/features/community_articles/presentation/bloc/community_feed_cubit_test.dart` (cubit-level: upload + publish forwarding); manual end-to-end run for the actual Storage + Firestore round trip |
| Scenario 2 (publish without image) | Cubit test (publish without prior upload); manual run |
| Scenario 3 (validation — missing field) | Implemented in `_validateLength` (publish_article_page.dart). Not covered by an automated widget test — see "Tests not yet written" |
| Scenario 4 (network failure on publish) | `community_feed_cubit_test.dart` "publish rethrows when the repository fails" |
| Scenario 5 (image upload failure) | `community_feed_cubit_test.dart` "uploadImage rethrows when the repository fails" |
| Scenario 6 (community feed loads) | `community_feed_cubit_test.dart` "start() emits Loaded with whatever the repository emits" |
| Scenario 7 (empty feed state) | Implemented in `CommunityFeedPage`. Not covered by a widget test |
| Scenario 8 (real-time update) | Cubit stream test proves the listener mechanism; the actual Firestore `snapshots()` propagation is exercised by manual run |

### Tests not yet written (debt)

Logged in `improvements.md`:

- Widget tests for `PublishArticlePage` (validation snackbars, submit states,
  image-picker integration).
- Widget tests for `CommunityFeedPage` (empty / loading / loaded / error states,
  card rendering).
- An integration test of `CommunityArticleFirestoreDataSource` against the
  Firebase emulator (mapping `Timestamp` → ISO 8601, Storage path composition).

These were deferred so the spec could ship with cubit + repository unit tests,
which cover the orchestration logic where bugs are most likely to land.
