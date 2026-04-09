---
id: 012-community-detail-widget-tests
title: "Widget Tests for the Community Article Detail Page"
status: implemented
version: 1.0.0
---

## User Problem

`CommunityArticleDetailPage` is the mirror of the Daily News detail page
on the community side. It is the only screen that exposes **owner-only
destructive actions** (edit + delete), and it has **zero widget-level
coverage**. The coverage report shows 94 lines across 4 files at 0%:

- `community_article_detail_page.dart` — 63 lines (the page itself,
  including the `isOwner` branch, the delete confirmation dialog, the
  error snackbar paths, and the deleting overlay).
- `community_article_detail_body.dart` — 14 lines.
- `community_article_detail_hero_image.dart` — 7 lines.
- `community_article_detail_title_and_date.dart` — 10 lines.

The functional risk is concentrated in the `isOwner` gate. A regression
there — for example, rendering the Delete icon for non-owners because a
condition was inverted — would be a security-shaped bug, not a cosmetic
one. That is exactly the kind of regression widget tests exist to catch.

This is the second installment of IMP-001 (widget tests for pages),
following spec 011 which covered the Daily News detail page.

## Solution Hypothesis

The existing `CommunityArticleDetailPage` reads the current user from
`FirebaseAuth.instance.currentUser?.uid` directly inside the widget.
That call is unmockable in a widget test without registering a
`FirebaseAuth` fake, which would require `firebase_core` platform
channels to be stubbed — heavy and not a pattern used anywhere else in
this project.

**The refactor:** expose `currentUid` as a constructor parameter on
`CommunityArticleDetailPage`, defaulting to
`FirebaseAuth.instance.currentUser?.uid` at the single call site
(`CommunityFeedPage._openDetail`). Inside the page, `_isOwner` reads
from `widget.currentUid` instead of touching `FirebaseAuth` directly.

This is a **two-file, ~8-line change** that:

- Keeps the production behaviour identical (same default, same call
  path).
- Removes the `firebase_auth` import from the page.
- Makes every branch of the page testable with no platform channels
  stubbed and no `GetIt` registrations.

The alternative — wrapping `FirebaseAuth` in an `AuthService` registered
via `GetIt` — was explicitly rejected for this submission: it touches
every call site that reads the current uid (feed, publish, detail),
becomes its own multi-file refactor, and does not add signal for a
showcase. That decision is documented here, not in code.

### Sub-widgets

The three sub-widgets under `widgets/community_article_detail_*` are
pure `StatelessWidget`s with no dependencies. They are tested in
isolation as regression guards, mirroring the spec 011 treatment of
`ArticleDetailBody` and friends.

## Success Metrics

- [ ] `CommunityArticleDetailPage.currentUid` exists as a named
      parameter, defaulting to `null`. `_isOwner` uses it.
- [ ] The one call site in `CommunityFeedPage._openDetail` passes
      `FirebaseAuth.instance.currentUser?.uid` explicitly.
- [ ] `firebase_auth` is no longer imported by the detail page.
- [ ] Widget tests exist for the 8 page-level scenarios below plus the
      3 sub-widget scenarios.
- [ ] Full suite stays green (no existing test is modified).
- [ ] Coverage of `community_article_detail_page.dart` moves from 0% to
      ≥85%. The 4 files together contribute ≥75 newly covered lines.
- [ ] Analyzer baseline unchanged.

## User Story

As an **engineer reviewing this codebase**, I want widget tests that
pin the owner-only gate and the delete flow of the community detail
page, so that a refactor cannot silently expose the Delete button to
non-owners, skip the confirmation dialog, or swallow a repository error
without surfacing it to the user. The tests should fail before such a
bug reaches production.

## Acceptance Criteria

### Scenario 1: Non-owner viewer sees no edit/delete actions

- **Given** an article authored by `uid = "alice"`
- **And** the page is mounted with `currentUid = "bob"`
- **Then** the AppBar title "Article" is visible
- **And** no `Icons.edit_outlined` icon is in the tree
- **And** no `Icons.delete_outline` icon is in the tree
- **And** the body, title, and hero image are visible

### Scenario 2: Anonymous viewer (null uid) sees no edit/delete actions

- **Given** an article authored by `uid = "alice"`
- **And** the page is mounted with `currentUid = null`
- **Then** neither edit nor delete icons are in the tree

### Scenario 3: Non-owner, article with null imageUrl

- **Given** an article with `urlToImage = null`
- **And** `currentUid` is different from the article's uid
- **When** the page is pumped
- **Then** no `CommunityArticleDetailHeroImage` is in the tree
- **And** the body still renders (title + content)

### Scenario 4: Owner sees edit and delete actions

- **Given** an article authored by `uid = "alice"`
- **And** the page is mounted with `currentUid = "alice"`
- **Then** the edit icon is visible
- **And** the delete icon is visible
- **And** both are enabled (not in deleting state)

### Scenario 5: Owner confirms delete — repository is called and page pops

- **Given** the owner is viewing the page
- **When** the delete icon is tapped
- **And** the confirmation dialog's "Delete" button is tapped
- **Then** `repository.deleteArticle(firestoreId, imageUrl)` is called
      exactly once with the article's values
- **And** the navigator pops back to the previous route

### Scenario 6: Owner cancels delete — repository is not called

- **Given** the owner is viewing the page
- **When** the delete icon is tapped
- **And** the confirmation dialog's "Cancel" button is tapped
- **Then** `repository.deleteArticle` is never called
- **And** the detail page is still visible

### Scenario 7: Delete with missing firestoreId shows a snackbar

- **Given** the owner is viewing an article whose `firestoreId` is null
- **When** the delete icon is tapped and confirmed
- **Then** `repository.deleteArticle` is never called
- **And** a snackbar with `"Could not delete: missing article id."` is
      visible

### Scenario 8: Repository throws on delete — error snackbar + overlay cleared

- **Given** the owner is viewing the page
- **And** `repository.deleteArticle` throws on call
- **When** the owner taps delete and confirms
- **Then** a snackbar with
      `"Could not delete. Check your connection and try again."` is
      visible
- **And** the `CommunityArticleDetailDeletingIndicator` is no longer in
      the tree (the state was cleared)

### Scenario 9: `CommunityArticleDetailBody` — sub-widget

- **Given** a body pumped with non-empty title, description, and content
- **Then** all three strings are found in the tree
- **And** a `CommunityArticleDetailTitleAndDate` is a descendant
- **Given** a body pumped with an empty description
- **Then** the description slot is absent but title and content still
      render

### Scenario 10: `CommunityArticleDetailHeroImage` — sub-widget

- **Given** the widget is pumped with a non-empty image URL
- **Then** a `CachedNetworkImage` with that URL is in the tree
- **When** its `placeholder` builder is invoked
- **Then** a `CircularProgressIndicator` is returned
- **When** its `errorWidget` builder is invoked
- **Then** an `Icons.broken_image_outlined` icon is returned

### Scenario 11: `CommunityArticleDetailTitleAndDate` — sub-widget

- **Given** the widget is pumped with a non-null, non-empty
      `publishedAt`
- **Then** the title is visible
- **And** a formatted date (via `formatPublishedAt`) is visible
- **Given** the widget is pumped with `publishedAt = null`
- **Then** only the title is visible, with no date row

## Out of Scope

- Testing the `_openEdit` flow end-to-end (the destination
  `PublishArticlePage` has its own dependencies — image picker, submit
  path — and belongs to a future spec 013).
- Testing `CommunityFeedCubit` or `CommunityArticleRepositoryImpl` —
  both already have unit tests.
- Testing `CommunityArticleDetailDeletingIndicator` — trivial 5-line
  `CircularProgressIndicator` wrapper.
- Integration tests against a real Firestore emulator.
- Visual / golden tests.
- Wrapping `FirebaseAuth` behind an `AuthService` (explicitly rejected
  above — documented trade-off, not backlog).

## Assumptions

- The `_FakeRepository` pattern already used in
  `community_feed_page_test.dart` is reusable verbatim; it implements
  `CommunityArticleRepository` in full and records method calls on
  public fields.
- `ArticleEntity` is trivially constructible with any mix of nullable
  fields. Verified during spec 011.
- No `GetIt` registration is required — the page receives its
  `CommunityFeedCubit` via `BlocProvider.value` in the test wrapper,
  same as production.

## Open Questions

None. The A-vs-B decision (constructor param vs `AuthService`) was
explicitly resolved in favour of A before the spec was written.

## Test Coverage

| Acceptance criterion | Test file / how |
|----------------------|-----------------|
| Scenarios 1–8 (page-level) | `test/features/community_articles/presentation/pages/community_article_detail_page_test.dart` — uses `_FakeRepository` from the existing community feed test pattern and a real `CommunityFeedCubit`. Asserts on `repository.deleteCalls` and on the presence/absence of widgets and snackbars. |
| Scenario 9 (body) | `test/features/community_articles/presentation/widgets/community_article_detail_body_test.dart` |
| Scenario 10 (hero image) | `test/features/community_articles/presentation/widgets/community_article_detail_hero_image_test.dart` — invokes `CachedNetworkImage.placeholder` and `errorWidget` builders directly, same pattern as `article_image_test.dart`, so the test does not hang waiting for the real image pipeline. |
| Scenario 11 (title + date) | `test/features/community_articles/presentation/widgets/community_article_detail_title_and_date_test.dart` |

Expected new test count: **~14 tests** (8 page + 2 body + 3 hero image
+ 2 title-and-date, give or take one). Suite total after implementation
should land around **103 tests**.

### Actual shipped numbers

- **16 new tests** (8 page + 2 body + 3 hero image + 3 title-and-date).
  The extra title-and-date test covers the empty-string publishedAt
  branch explicitly, not just null.
- Suite total: **105/105 passing**.
- Line coverage jumped from **59.3% → 74.1%** (+14.8pp).
- Target file coverage:
  - `community_article_detail_page.dart`: 0% → **87.3%** (55/63)
  - `community_article_detail_body.dart`: 0% → **100%** (14/14)
  - `community_article_detail_hero_image.dart`: 0% → **100%** (7/7)
  - `community_article_detail_title_and_date.dart`: 0% → **100%** (10/10)
- The 8 uncovered lines in the page are `_openEdit` (navigation to
  `PublishArticlePage`), explicitly listed as out of scope.

### Deviation: delete-flow tests use articles without urlToImage

Scenarios 5–8 mount the page with `urlToImage = null` instead of a real
image URL. The reason: `CachedNetworkImage` in the hero image widget
schedules frames indefinitely under `pumpAndSettle` in the Flutter test
environment (same hang that spec 009/011 worked around with direct
builder invocation). Scenario 5 still verifies the `imageUrl`
propagation through the delete call — it asserts
`repository.deleteCalls.single.imageUrl == null`, which is
`_article.urlToImage` passed through verbatim. A non-null URL would
prove the same assertion but would deadlock the test loop.

The hero-image show/hide behaviour itself is still covered by scenario
3 (non-owner, null URL) and the dedicated
`community_article_detail_hero_image_test.dart` file. Nothing lost.
