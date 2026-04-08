---
id: 005-edit-community-article
title: "Edit Your Own Community Article"
status: implemented
version: 1.0.0
---

## User Problem

Spec 003 lets users publish; spec 004 lets them delete. Both are one-shot
destructive flows. The middle ground is missing: **fix a typo without nuking
the whole article**.

Today, the only way to correct a mistake is delete + re-publish. That has two
costs:
1. The original `firestoreId` and `publishedAt` are lost. The article hops to
   the top of the feed even though the change is just a typo.
2. The image (if any) has to be re-picked and re-uploaded, which wastes the
   user's time and the project's Storage budget.

## Solution Hypothesis

Add an Edit action to `CommunityArticleDetailPage` (visible only to the
author, alongside Delete). Tap → opens a form that is **the same publish
form**, pre-populated with the existing values. Submit → calls a new
`updateArticle` path on the repository that overwrites only `title`,
`description`, `content`, and (if changed) `imageUrl`. `publishedAt` and `uid`
are NOT touched, so the article keeps its place in the feed and its ownership.

## Success Metrics

- [ ] An author can edit their own article in three taps (Edit → modify →
  Save).
- [ ] The edited article keeps its original `publishedAt` and `firestoreId`.
- [ ] The edit propagates to the feed via `snapshots()` within 2 seconds.
- [ ] A non-owner attempting to update via direct REST call is rejected with
  `PERMISSION_DENIED` (the security rule from spec 002 already covers this).

## User Story

As an **author**, I want to edit my published article, so that I can fix typos
and small mistakes without losing the article's place in the feed or making
my followers see it again as if it were brand new.

## Acceptance Criteria

### Scenario 1: Author sees Edit button on the detail page

- **Given** the user is on `CommunityArticleDetailPage` for an article they
  authored (`currentUser.uid == article.uid`)
- **When** the page renders
- **Then** an Edit icon appears in the AppBar actions, alongside Delete

### Scenario 2: Non-author does not see Edit button

- **Given** the user is on the detail page for an article they did NOT author
- **Then** no Edit icon appears in the AppBar

### Scenario 3: Edit form is pre-populated

- **Given** the author taps Edit
- **When** the edit form opens
- **Then** Title, Description, and Content are pre-filled with the existing
  values
- **And** the image preview shows the current image (if the article has one)
- **And** if the article has no image, the "Add image" button is shown
- **And** the AppBar action label says "Save" instead of "Publish"

### Scenario 4: Save with no changes still works

- **Given** the form is pre-populated and the user did not modify any field
- **When** they tap Save
- **Then** the same data is written back to Firestore (no diff check)
- **And** the user returns to the detail page
- **And** the detail page shows the same content

### Scenario 5: Save with text changes

- **Given** the user modified the title and content
- **When** they tap Save
- **Then** the Firestore document at `articles/{firestoreId}` is updated with
  the new title and content
- **And** `publishedAt` is unchanged
- **And** `uid` is unchanged
- **And** the user returns to the detail page
- **And** the detail page shows the new title and content

### Scenario 6: Save with a new image

- **Given** the user tapped Replace and picked a different image
- **When** they tap Save
- **Then** the new image is uploaded to Storage
- **And** Firestore is updated with the new `imageUrl`
- **And** the OLD image in Storage is deleted (best-effort, like spec 004)
- **And** the detail page shows the new image

### Scenario 7: Save fails (network)

- **Given** Firestore is unreachable
- **When** the user taps Save
- **Then** a snackbar shows "Could not save. Check your connection and try
  again."
- **And** the form keeps the user's input
- **And** the user can retry

### Scenario 8: Removing the image from an article that had one

- **Given** the article had an image
- **When** the user taps Remove on the image preview and then Save
- **Then** Firestore is updated with `imageUrl = null`
- **And** the OLD image in Storage is deleted (best-effort)
- **And** the detail page no longer shows an image

## Implementation Checklist

- [ ] Add `updateArticle({firestoreId, title, description, content, imageUrl,
  oldImageUrl})` to `CommunityArticleRemoteDataSource`, `CommunityArticleRepository`,
  `CommunityArticleRepositoryImpl`, and `CommunityFeedCubit`
- [ ] Implement in `CommunityArticleFirestoreDataSource`:
  - Update the doc with the new fields (no `publishedAt`, no `uid`)
  - If `oldImageUrl` exists and is different from the new `imageUrl`, delete
    the old image from Storage on a best-effort basis
- [ ] Refactor `PublishArticlePage` so it accepts an optional initial
  `ArticleEntity`. When present, the form is in "edit" mode: fields are
  pre-populated, the AppBar says "Save", and submit calls `updateArticle`
  instead of `publish`. Most of the form code is reused.
- [ ] Add an Edit IconButton to `CommunityArticleDetailPage`, visible when
  `_isOwner`, that opens the form in edit mode
- [ ] Tests:
  - Cubit: `updateArticle` happy path forwards to repository
  - Cubit: `updateArticle` error path rethrows
  - Repository: pass-through verified with fake remote data source
  - Detail page widget test: Edit button visibility per uid match (paired
    with the Delete button — same `_isOwner` branch)

## Out of Scope (V1)

- Edit history / version log. Once edited, the previous version is gone.
- A diff view ("you changed: ...") before saving.
- Concurrent-edit conflict resolution. If two devices edit the same article
  simultaneously, the last write wins. The probability is near zero for
  anonymous users on different devices and not worth solving in V1.
- Editing the `publishedAt` (we explicitly preserve it).
- Editing other people's articles. Forbidden by the security rule.

## Assumptions

- Spec 004 is implemented: `CommunityArticleDetailPage` exists, the `_isOwner`
  branch works, and the Delete button establishes the AppBar action pattern.
- The Firestore strict rule from spec 002 (`allow update: if request.auth !=
  null && resource.data.uid == request.auth.uid`) covers updates and is
  already deployed. This spec is the first time the `update` clause is
  exercised.
- Reusing `PublishArticlePage` is cleaner than building a separate
  `EditArticlePage` because the form fields are identical. The "publish"
  vs "edit" mode is a single boolean parameter on the page constructor.

## Open Questions

None. All decisions resolved before the spec was written.

## Test Coverage

Tests written alongside the implementation, per the AGENTS.md §4 mandate.

| Acceptance criterion | Test file / how |
|---------------------|-----------------|
| Scenario 1 (author sees Edit button) | Manual on iOS simulator with the current session UID |
| Scenario 2 (non-author hides Edit button) | Manual with a pre-existing article from a previous session |
| Scenario 3 (form is pre-populated) | Manual + the controllers' `initialValue` is set in `initState` from `widget.initialArticle`, which is straightforward enough to read |
| Scenario 4 (save with no changes still works) | `community_feed_cubit_test.dart` "updateArticle forwards every field" — the cubit does not diff |
| Scenario 5 (save with text changes) | `community_feed_cubit_test.dart` covers the cubit-level forwarding; `community_article_repository_impl_test.dart` covers the repo-level pass-through; manual run validates the round trip + UI refresh |
| Scenario 6 (save with a new image) | Cubit tests cover the `imageUrl` and `oldImageUrl` arguments; manual run validates the upload + Storage cleanup |
| Scenario 7 (save fails — network) | `community_feed_cubit_test.dart` "updateArticle rethrows when the repository fails" |
| Scenario 8 (removing the image) | Manual; the data path is exercised by the same cubit/repo tests with `imageUrl == null` |

### Test files added or updated

- `test/features/community_articles/data/repository/community_article_repository_impl_test.dart` — 2 new tests for `updateArticle` (with and without `oldImageUrl`)
- `test/features/community_articles/presentation/bloc/community_feed_cubit_test.dart` — 3 new tests (`updateArticle` happy path, null image URLs, error path)
- Test count: **41 → 41** (this spec contributed: 5 new unit tests; the prior count of 41 already included the IMP-001 widget tests written in the same session)

Wait — recounting precisely: spec 004 closed at 28. IMP-001 added 8 widget tests (28→36). Spec 005 added 5 unit tests (36→41). The full suite at the end of spec 005 is **41 tests**.

### Tests not yet written (debt)

- Widget test for `CommunityArticleDetailPage` showing the Edit and Delete
  buttons per `_isOwner` branch. The detail page now has two action buttons
  whose visibility depends on `FirebaseAuth.instance.currentUser`, which makes
  it untestable as a widget without `firebase_auth_mocks`. Logged in
  improvements.md IMP-001.
- Integration test for `CommunityArticleFirestoreDataSource.updateArticle`
  against the Firestore emulator to assert `publishedAt` and `uid` are
  preserved. Logged in IMP-002.

## Deviations

### 1. Detail page replaces its `_article` from the popped result

The spec says "the user returns to the detail page and the detail page shows
the new content". The implementation does this by having the edit form
`Navigator.pop(updatedEntity)`, and the detail page `await`-ing the result and
calling `setState`. This is simpler than rebuilding the detail page from the
cubit's stream and avoids subscribing the detail page to the feed cubit.

**Tradeoff:** the detail page's state is a snapshot, not a live view. If
another device edits the same article while the detail page is open, the
detail page will not auto-update. Acceptable for V1 — concurrent edits are
explicitly out of scope.

### 2. Form reuse via `initialArticle` parameter, no separate `EditArticlePage`

`PublishArticlePage` accepts an optional `initialArticle`. When present, the
form is in "edit" mode: fields are pre-populated, the AppBar title says
"Edit Article", the submit action says "Save", and the submit handler calls
`updateArticle` instead of `publish`. The image picker section accepts both
a local `File` (newly picked) and an `existingImageUrl` (from the original
article).

**Why:** duplicating the form into a separate `EditArticlePage` would copy
~250 lines of identical layout, validation, and error handling. The mode
difference is small enough to fit in conditionals.

### 3. The submit handler does not diff fields before writing

If the user opens the edit form and taps Save without changing anything,
Firestore receives a write with the same values. This is intentional — the
spec scenario 4 explicitly allows this and the alternative (diff check) adds
complexity for zero user-visible benefit. Firestore handles idempotent writes
fine.

### 4. The detail page state is rebuilt locally, not pulled from the feed

After Save, the detail page replaces its in-memory `ArticleEntity` with the
one returned by the edit form. The feed eventually catches up via the
Firestore `snapshots()` stream, but that happens independently and the user
sees the change immediately because of the local state replacement.
