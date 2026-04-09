---
id: 011-daily-news-detail-widget-tests
title: "Widget Tests for the Daily News Article Detail Page"
status: implemented
version: 1.0.0
---

## User Problem

Spec 009 (v1.0.0 → v1.1.2) made aggressive changes to the Daily News
article detail page:

- `ArticleImage` switched to `CachedNetworkImage` and added a null
  short-circuit.
- `ArticleDescription` was rewritten to call `sanitizeArticleContent` and
  show an italic fallback when the content is null/empty/junk.
- `ArticleDetailBody` stopped force-unwrapping `article.urlToImage!`.

Each of those changes has unit tests for **its piece** (the image widget,
the sanitizer function, the model mapping). What is **not** tested is the
composition: that `ArticleDetailBody` actually wires the three subwidgets
together correctly, and that the full page renders without crashing for
the edge cases that v1.1.2 hotfixed (null image + junk content).

This is also the first item on the IMP-001 backlog that the project has
been carrying since spec 003.

## Solution Hypothesis

Add widget tests for the three directly-testable pieces of the detail
page. Skip the top-level `ArticleDetailsView` because it wraps everything
in `BlocProvider(create: (_) => sl<LocalArticleBloc>())` — testing that
composition adds coverage of DI wiring, not of behaviour, and would
require registering fakes in GetIt which every other test in the repo
avoids.

Pieces to test:

1. **`ArticleDetailBody`** — pure `StatelessWidget`, takes an
   `ArticleEntity`. Verify it composes `ArticleTitleAndDate`,
   `ArticleImage`, and `ArticleDescription` for each of the edge cases
   introduced by spec 009.

2. **`ArticleDetailAppBar`** — trivial. Verify it renders an `AppBar`
   with a tappable back button that pops the navigator.

3. **`SaveArticleFab`** — requires a `LocalArticleBloc` in scope.
   Verify that tapping it dispatches a `SaveArticle` event with the
   correct article and shows a success snackbar. Tested by pumping it
   inside a `BlocProvider.value` wired to a hand-rolled fake bloc (no
   GetIt, no real use cases, no database).

## Success Metrics

- [ ] `ArticleDetailBody` has widget tests for: happy path (valid image
      and normal content), null image URL (uses placeholder), null
      content (shows the italic fallback), scraper-junk content (shows
      the italic fallback).
- [ ] `ArticleDetailAppBar` has a test that verifies the back button
      pops the navigator.
- [ ] `SaveArticleFab` has a test that verifies `SaveArticle` is
      dispatched and a snackbar appears on tap.
- [ ] No existing test is modified.
- [ ] Full suite stays green; analyzer baseline unchanged.

## User Story

As an **engineer working on this codebase**, I want widget tests that
pin the behaviour of the Daily News article detail page, so that a
future refactor or a revert of spec 009 cannot silently reintroduce the
"red X", the JSON junk body, or the null-check crash — the suite will
fail first.

## Acceptance Criteria

### Scenario 1: ArticleDetailBody — happy path

- **Given** an `ArticleEntity` with a valid image URL, title, date,
  description, and normal content
- **When** `ArticleDetailBody` is pumped
- **Then** the title text is found
- **And** the description text is found
- **And** exactly one `ArticleImage`, `ArticleTitleAndDate`, and
  `ArticleDescription` are present in the tree

### Scenario 2: ArticleDetailBody — null image URL

- **Given** an `ArticleEntity` with `urlToImage = null`
- **When** `ArticleDetailBody` is pumped
- **Then** the body renders without throwing
- **And** `Icons.broken_image_outlined` is visible (proves the null
  short-circuit reached the placeholder — this is the regression from
  spec 009 v1.1.2)

### Scenario 3: ArticleDetailBody — null content

- **Given** an `ArticleEntity` with `content = null`
- **When** `ArticleDetailBody` is pumped
- **Then** the "Full article available at the source." fallback line
  is visible

### Scenario 4: ArticleDetailBody — JSON scraper junk content

- **Given** an `ArticleEntity` whose `content` is the real-world
  scraper-junk string from NewsAPI
  (`{"en":{"access_disabled":...` truncated)
- **When** `ArticleDetailBody` is pumped
- **Then** the fallback line is visible
- **And** no part of the JSON body is visible on screen (no
  `access_disabled`, no curly braces in a `Text` widget)

### Scenario 5: ArticleDetailAppBar — back button pops

- **Given** `ArticleDetailAppBar` is mounted inside a `Navigator` that
  has a previous route
- **When** the back icon is tapped
- **Then** the previous route is shown (the current route was popped)

### Scenario 6: SaveArticleFab — dispatches SaveArticle on tap

- **Given** a `SaveArticleFab` wired to a fake `LocalArticleBloc`
- **When** the FAB is tapped
- **Then** the fake bloc records exactly one `SaveArticle` event
- **And** the event carries the same `ArticleEntity` that was passed
  to the FAB
- **And** a snackbar with the copy `"Article saved successfully."` is
  visible

## Out of Scope

- Testing `ArticleDetailsView` at the page level (the `sl<>()` DI call
  makes that a GetIt-registration test, not a widget test).
- Testing the full navigation stack from the list tile to the detail
  page.
- Testing `LocalArticleBloc` itself (it belongs to spec 001's domain).
- Integration tests against the Floor database.
- Visual/golden tests. Out of scope for the whole project.
- Re-testing the sanitizer or the image widget — those already have
  dedicated unit/widget tests.

## Assumptions

- `ArticleEntity` is easy to instantiate in tests with any mix of
  nullable fields. Verified.
- A hand-rolled fake bloc is acceptable for `SaveArticleFab` — the
  community_feed test file already uses a hand-rolled fake repository
  (`_FakeRepository`) as an established pattern.
- No GetIt registration is required for `ArticleDetailBody` or
  `ArticleDetailAppBar`; only `SaveArticleFab` needs a bloc in scope.

## Open Questions

None.

## Test Coverage

| Acceptance criterion | Test file / how |
|----------------------|-----------------|
| Scenarios 1–4 (body composition + edge cases) | `test/features/daily_news/presentation/widgets/article_detail_body_test.dart` |
| Scenario 5 (app bar back button) | `test/features/daily_news/presentation/widgets/article_detail_app_bar_test.dart` |
| Scenario 6 (save fab event + snackbar) | `test/features/daily_news/presentation/widgets/save_article_fab_test.dart` — uses a hand-rolled `_FakeLocalArticleBloc` that extends `Bloc<LocalArticlesEvent, LocalArticlesState>` and records every event it receives in a `List<LocalArticlesEvent>`. No real use cases, no DI. |

Actual new test count: **8 tests** (4 body + 1 app bar + 3 fab). Suite total after implementation: **89/89 passing**. Analyzer baseline unchanged.

### Deviation: fab test asserts on the repository, not on bloc events

The spec originally said the fab test would use a hand-rolled fake bloc and assert that a `SaveArticle` event was recorded. The first cut of the test did exactly that by `implements LocalArticleBloc` on a fake, but Dart's `implements` requires every concrete method (`onGetSavedArticles`, `onSaveArticle`, `onRemoveArticle`) to be reimplemented — those methods close over the use cases and exist only to satisfy the abstract contract. Reimplementing them adds noise without adding coverage.

The shipped test instead constructs a **real `LocalArticleBloc`** over real use cases over a hand-rolled `_FakeArticleRepository`. The assertion moves down one layer: instead of "the bloc received a `SaveArticle` event", it's "the repository received a `saveArticle(article)` call". That is actually a stronger guarantee — it verifies the full dispatch path including the handler, not just the event arrival — and mirrors the pattern used in `article_repository_impl_test.dart`. No real database, no DI, no GetIt.
