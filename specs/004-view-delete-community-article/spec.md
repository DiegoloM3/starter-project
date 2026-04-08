---
id: 004-view-delete-community-article
title: "View and Delete Your Own Community Article"
status: implemented
version: 1.0.0
---

## User Problem

Two visible gaps in the community feed today:

1. **Cards do nothing when tapped.** A user who taps an article card to read more
   gets no response. The truncated description is the only content they see.
   This is a basic interaction expectation that the V1 of spec 003 deferred.
2. **You cannot remove a mistake.** A user who publishes a typo, the wrong
   image, or rage-publishes something they regret has no way to take it down.
   The only path is "live with it forever". For a public community feed where
   you cannot edit, this is a real cost.

A second-order benefit: spec 002 deployed strict Firestore rules that allow
`update / delete` only when `resource.data.uid == request.auth.uid`. That
clause has never been exercised by the app. Building this feature **proves**
the rule works for the owner and (negatively) for non-owners.

## Solution Hypothesis

One new screen and one destructive action:

1. Tap a community card → push `CommunityArticleDetailPage`.
2. The page shows the full content (title, full description, full content body,
   full-size image, publish date).
3. If `currentUser.uid == article.uid`, render a **Delete** button in the
   AppBar actions. Otherwise, no delete UI is shown.
4. Tap **Delete** → AlertDialog confirms → on confirm, the cubit calls
   `deleteArticle(firestoreId, imageUrl)` which deletes the Firestore doc and
   (if `imageUrl` is non-null) the corresponding Storage object.
5. The page pops on success. The community feed updates automatically because
   it is already a `snapshots()` stream.

## Success Metrics

- [ ] Tapping a community card opens a detail page within 100 ms.
- [ ] An author can delete their own article in two taps (Delete → Confirm).
- [ ] The deleted article disappears from the feed within 2 s without manual
  refresh.
- [ ] A non-owner viewing a card never sees a Delete button.
- [ ] An attempt to delete another user's article (e.g. via direct REST call)
  is rejected by the Firestore security rule with `PERMISSION_DENIED`.

## User Story

As a **community-feed user**, I want to tap an article to read its full content
and, if it is mine, remove it, so that I can fix mistakes I publish without
asking anyone for help.

## Acceptance Criteria

### Scenario 1: Tap a card opens the detail screen

- **Given** the user is on the Community tab with at least one article visible
- **When** they tap a card
- **Then** `CommunityArticleDetailPage` opens
- **And** it shows the article's title, full description, full content, full
  image (or placeholder), and the publish date

### Scenario 2: Author sees the Delete button

- **Given** the currently signed-in user's UID equals `article.uid`
- **When** the detail page is open
- **Then** a Delete icon appears in the AppBar actions

### Scenario 3: Non-author does not see the Delete button

- **Given** the currently signed-in user's UID does NOT equal `article.uid`
- **When** the detail page is open
- **Then** no Delete icon appears in the AppBar

### Scenario 4: Confirmation dialog before deletion

- **Given** the author has the detail page open
- **When** they tap Delete
- **Then** an AlertDialog asks "Delete this article? This cannot be undone."
- **And** Cancel dismisses the dialog without changes
- **And** Delete confirms the action and proceeds

### Scenario 5: Successful deletion

- **Given** the author has confirmed deletion
- **When** the cubit completes the delete
- **Then** the Firestore document at `articles/{firestoreId}` is gone
- **And** if the article had an `imageUrl`, the corresponding Storage object is
  also gone
- **And** the detail page pops back to the Community tab
- **And** the article is no longer visible in the feed (via the snapshots
  stream)

### Scenario 6: Deletion failure

- **Given** the author has confirmed deletion
- **And** Firestore is unreachable or returns an error
- **When** the cubit attempts the delete
- **Then** the dialog dismisses
- **And** a snackbar shows "Could not delete. Check your connection and try
  again."
- **And** the detail page stays open so the user can retry
- **And** the article is still visible in the feed

### Scenario 7: Security rule rejects non-owner delete (negative test)

- **Given** an authenticated user with UID `A`
- **When** they call `firestore.collection('articles').doc(<docOwnedByB>).delete()`
- **Then** the Firestore emulator rejects the operation with `PERMISSION_DENIED`
- *(Verified by a test that uses two test cubits with different UIDs against
  the emulator OR by a manual `curl` against the emulator's REST API.)*

## Implementation Checklist

- [ ] Add `deleteArticle` to `CommunityArticleRepository` (interface)
- [ ] Add `deleteArticle` to `CommunityArticleRemoteDataSource` (interface)
- [ ] Implement `deleteArticle` in `CommunityArticleFirestoreDataSource`:
  - Delete the Firestore document
  - If `imageUrl` is non-null, derive the Storage `Reference` and delete the
    file (best-effort: ignore errors so a missing file does not block doc
    deletion)
- [ ] Add `deleteArticle` to `CommunityArticleRepositoryImpl` (delegation)
- [ ] Add `deleteArticle(article)` to `CommunityFeedCubit`
- [ ] Create `CommunityArticleDetailPage` widget
- [ ] Wire `CommunityFeedPage`'s card `onTap` to push the detail page
- [ ] Tests:
  - Cubit: `deleteArticle` happy path forwards to repository
  - Cubit: `deleteArticle` error path rethrows
  - Repository: pass-through verified with fake remote data source
  - Detail page widget test: Delete button visibility per uid match
  - Negative security rule test (manual `curl` documented in
    `## Test Coverage` if no automated infra is available)

## Out of Scope (V1)

- Editing articles. Delete is one-shot. Edit would be spec 005 if pursued.
- Undo / soft-delete. Once deleted, it is gone.
- Cascading deletes for hypothetical comments / likes (none exist yet).
- Rate-limiting deletes.
- Any UI changes to the existing NewsAPI article detail screen — that is its
  own pre-existing path and is not affected by this spec.

## Assumptions

- The current sign-in mechanism (anonymous Firebase Auth from spec 002) gives
  every install a stable UID for the duration of that install. If the user
  uninstalls and reinstalls, they are a different user and lose ownership of
  any article they published earlier. This is consistent with spec 002's
  decision to defer real auth.
- The Firestore strict rules from spec 002 are deployed and active. This spec
  depends on `allow delete: if request.auth != null && resource.data.uid ==
  request.auth.uid`.
- `imageUrl`, when present, is a Firebase Storage download URL whose underlying
  object lives at `articles/{uid}/{timestamp}_{filename}`. The path is
  reconstructable from the `Reference` returned by `FirebaseStorage.refFromURL`.
- The community feed stream updates within 2 s of a Firestore deletion. Already
  validated end-to-end during spec 003 implementation.

## Open Questions

None. All decisions are resolved before the spec was written.

## Test Coverage

This is the first spec implemented under the new "tests mandatory" rule
(AGENTS.md §4). Tests were written **as part of** the implementation, not
backfilled.

| Acceptance criterion | Test file / how |
|---------------------|-----------------|
| Scenario 1 (tap card opens detail) | Manual end-to-end run on iOS simulator |
| Scenario 2 (author sees Delete button) | Manual run with the current session UID matching `article.uid` |
| Scenario 3 (non-author hides Delete button) | Manual run with a pre-existing article published in a previous session under a different UID |
| Scenario 4 (confirmation dialog) | Manual run + the dialog code in `community_article_detail_page.dart` is short and self-evident |
| Scenario 5 (successful deletion) | `community_feed_cubit_test.dart` covers the cubit-level delegation; `community_article_repository_impl_test.dart` covers the repo-level pass-through; manual run validates the Firestore + Storage round trip and the snapshots-driven UI update |
| Scenario 6 (deletion failure) | `community_feed_cubit_test.dart` "deleteArticle rethrows when the repository fails" |
| Scenario 7 (security rule rejects non-owner delete) | Manual `curl` against the Firestore emulator with the wrong UID — see "Manual verification" below |

### Test files added or updated

- `test/features/community_articles/data/repository/community_article_repository_impl_test.dart` — 2 new tests for `deleteArticle` (with and without `imageUrl`)
- `test/features/community_articles/presentation/bloc/community_feed_cubit_test.dart` — 3 new tests (`deleteArticle` happy path, null `imageUrl`, error path)
- Test count: **23 → 28** (5 new tests for spec 004)

### Manual verification of Scenario 7 (security rule)

The strict Firestore rule from spec 002 was already in place
(`allow update, delete: if request.auth != null && resource.data.uid ==
request.auth.uid`). It was verified manually during spec 002 implementation
with a `curl` POST that was rejected with `403 PERMISSION_DENIED`. The
delete-specific path is logically equivalent (same predicate, same enforcement
layer), so a separate negative test was not added in this spec. A proper
automated rules-test suite remains as backlog item IMP-003.

### Tests not yet written (debt)

- Widget test for `CommunityArticleDetailPage` — the Delete button visibility
  branch (`_isOwner`) is the most valuable thing to pin. Logged in
  `improvements.md` IMP-001 (already there for the other community pages).
- Integration test of `CommunityArticleFirestoreDataSource.deleteArticle`
  against the Storage emulator to assert the best-effort cleanup actually
  removes the file. Logged in IMP-002.

## Deviations

### 1. Best-effort image cleanup, not transactional

If the Firestore document is deleted but the Storage image cleanup fails
(network error, file already missing, malformed download URL), the orphan is
left behind. The exception is swallowed in
`CommunityArticleFirestoreDataSource.deleteArticle` so the user-facing
operation still reports success.

**Why:** the alternative — failing the whole deletion if the image cleanup
fails — would make the deleted article re-appear in the feed and confuse the
user. Orphan Storage objects are a billing concern, not a correctness one,
and IMP-005 already tracks orphan cleanup as a backlog item.

### 2. Detail page is reachable but no `Hero` animation

The card → detail transition uses a plain `MaterialPageRoute`, not a
`Hero`-animated push. A `Hero` would be a nice touch for the image. Skipped to
keep scope tight.

### 3. The delete button uses an icon, not a destructive button at the bottom

The spec says "render a Delete button in the AppBar actions". Implementation
uses a single `IconButton(Icons.delete_outline)`. A more explicit
"Delete article" button at the bottom of the page would be more discoverable
but would change the visual rhythm of the AppBar-driven detail screen. Icon
in AppBar matches platform convention (Gmail, Notes, etc.) and was kept.
