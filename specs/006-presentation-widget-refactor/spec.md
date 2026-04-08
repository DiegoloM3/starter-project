---
id: 006-presentation-widget-refactor
title: "Refactor Presentation Widgets to Composition over `_buildXxx()` Methods"
status: implemented
version: 1.0.0
---

## User Problem

This is a **technical debt / craft** spec, not a user-facing feature. The
problem is forward-looking, the same shape as spec 001:

The `presentation/` layers of `daily_news` and (to a smaller degree)
`community_articles` use the `Widget _buildXxx()` method-on-the-State pattern
to break up `build()`. This is a well-documented Flutter anti-pattern:

1. **No `const` benefit.** A method that returns a Widget cannot be
   `const`-constructed by the caller. Every parent rebuild allocates a fresh
   subtree, even when the inputs are unchanged.
2. **Rebuilds are coarse.** When the parent's state changes, every method
   reruns from scratch. A subtree extracted into its own `StatelessWidget`
   class only rebuilds when its inputs (constructor parameters) actually
   change.
3. **No element-tree reuse.** Flutter's element tree de-duplicates widgets
   only when the runtimeType matches at the same position. Method results
   defeat this because the runtimeType of the parent never narrows.
4. **Untestable in isolation.** A `_buildXxx()` method cannot be the target
   of a widget test. Any test must instantiate the parent.
5. **Hard to read.** A 200-line `build()` with 5 helper methods sitting in
   the same State class hides the visual structure.

References:
- https://docs.flutter.dev/perf/best-practices ("Use const widgets where
  possible")
- https://www.youtube.com/watch?v=IOyq-eTRhvo (Flutter "Splitting widgets to
  methods is a performance antipattern")

The `improvements.md` file was the right place to log this, but the
violations are concentrated enough — and impact every page in the original
`daily_news` feature — that it warrants a dedicated spec rather than a
trickle of small refactors over time.

## Solution Hypothesis

For every `Widget _buildXxx(...)` method in the targeted files:

1. Extract it to a private (`class _Xxx`) `StatelessWidget` (or
   `StatefulWidget` if it needs local state) at the bottom of the same file.
2. Constructor parameters replace closed-over variables / method arguments.
3. Mark constructors `const` wherever the parameters allow it.
4. The original `build()` becomes a tree of small composable widgets, no
   nested helper-method calls.
5. Existing behaviour, BLoCs, and routes are unchanged. Tests still pass.
6. The widget tests added in IMP-001 still pass without modification.

This is a **pure refactor**: no UI change, no behaviour change, no public
API change.

## Success Metrics

- [ ] Zero `Widget _buildXxx(...)` methods remain in the targeted files.
- [ ] The full test suite (41 tests at the time of writing) passes after
  the refactor with zero modifications to test files.
- [ ] `flutter analyze lib/` reports the same issue count as before
  (1 pre-existing info from the auto-generated `news_api_service.g.dart`).
- [ ] Manual smoke test on iOS simulator: every screen still loads, navigates,
  and behaves identically.
- [ ] Each refactored page file is shorter or roughly the same length, never
  significantly longer (extracting widgets should not bloat the file).

## User Story

As a **product engineer continuing work on this codebase**, I want the
presentation layer to use small composable widget classes instead of helper
methods, so that I can reason about rebuild scope, get the `const`
optimisation for free, and write widget tests at the right granularity.

## Acceptance Criteria

### Scenario 1: `daily_news.dart` has no method-based widgets

- **Given** the `DailyNews` page
- **When** the file is reviewed
- **Then** there are no `_buildAppbar`, `_buildPage`, or `_buildArticlesPage`
  methods
- **And** the `build()` method composes private widget classes directly
- **And** the page still renders the same UI as before

### Scenario 2: `article_detail.dart` has no method-based widgets

- **Given** the `ArticleDetailsView` page
- **When** the file is reviewed
- **Then** there are no `_buildAppBar`, `_buildBody`,
  `_buildArticleTitleAndDate`, `_buildArticleImage`,
  `_buildArticleDescription`, or `_buildFloatingActionButton` methods
- **And** each of those is replaced by a private widget class

### Scenario 3: `saved_article.dart` has no method-based widgets

- **Given** the `SavedArticles` page
- **When** the file is reviewed
- **Then** there are no `_buildAppBar`, `_buildBody`, or `_buildArticlesList`
  methods
- **And** each of those is replaced by a private widget class

### Scenario 4: `article_tile.dart` has no method-based widgets

- **Given** the `ArticleWidget`
- **When** the file is reviewed
- **Then** there are no `_buildImage`, `_buildTitleAndDescription`, or
  `_buildRemovableArea` methods
- **And** each of those is replaced by a private widget class

### Scenario 5: `publish_article_page.dart` build() is split

- **Given** the `PublishArticlePage` build method
- **When** reviewed
- **Then** the form section, the action button, and the submit-progress
  indicator are extracted to their own private widget classes
- *(`_ImagePickerSection` already exists from spec 003 — left as is.)*

### Scenario 6: `community_article_detail_page.dart` build() is split

- **Given** the `CommunityArticleDetailPage` build method
- **When** reviewed
- **Then** the article header (title + date), the body content, and the
  optional image are extracted to their own private widget classes

### Scenario 7: All existing tests still pass without modification

- **Given** the test suite from before this spec (41 tests)
- **When** the test suite is run after the refactor
- **Then** every test passes
- **And** no test file was modified to make this happen

### Scenario 8: Manual smoke test confirms no regression

- **Given** the app running on the iOS simulator
- **When** the user navigates: Daily News → tap article → back → Saved
  Articles → back → Community → tap card → Edit → Save → Delete
- **Then** every screen renders correctly and every action behaves the same
  as before the refactor

## Implementation Checklist

### `daily_news` feature

- [ ] `pages/home/daily_news.dart`: extract `_DailyNewsAppBar`,
  `_ArticleListView` (and use BLoC inline in build)
- [ ] `pages/article_detail/article_detail.dart`: extract
  `_ArticleDetailAppBar`, `_ArticleDetailBody`, `_ArticleTitleAndDate`,
  `_ArticleImage`, `_ArticleDescription`, `_SaveArticleFab`
- [ ] `pages/saved_article/saved_article.dart`: extract `_SavedArticlesAppBar`,
  `_SavedArticlesBody`, `_SavedArticlesList`
- [ ] `widgets/article_tile.dart`: extract `_ArticleTileImage`,
  `_ArticleTileTitleAndDescription`, `_ArticleTileRemovableArea`

### `community_articles` feature

- [ ] `pages/publish_article_page.dart`: extract `_PublishForm`,
  `_PublishAction` (the AppBar TextButton + its colour logic),
  `_SubmitProgress`
- [ ] `pages/community_article_detail_page.dart`: extract
  `_DetailHeroImage`, `_DetailTitleAndDate`, `_DetailBody`

### Validation

- [ ] `flutter analyze lib/` shows the same baseline (1 issue: the .g.dart info)
- [ ] `flutter test --no-pub` shows 41/41 passing
- [ ] Manual smoke test on iOS simulator covering all screens

## Out of Scope (V1)

- Adding any new functionality.
- Changing the visual design of any screen.
- Modifying or adding tests beyond what is needed to compensate for any
  signature change in private widgets (which there should be zero of —
  privates can't be imported by tests).
- Refactoring BLoCs / Cubits / data layer / domain layer.
- Refactoring `root_screen.dart` (already small and composition-based).
- Refactoring `community_feed_page.dart` (already uses `_CommunityArticleCard`
  as a private widget — only minor cleanup if any).
- Splitting widgets across files. Each refactored widget stays in the same
  `.dart` file as its parent unless it is genuinely reusable across files
  (none are, in this codebase).
- Promoting any private (`_`) widget to public. The refactor is internal.
- Adding `Hero` animations or any new UI flourish.

## Assumptions

- The existing widget tests added in IMP-001 (8 tests for `CommunityFeedPage`
  and `PublishArticlePage`) cover enough of the rebuilt UI that they will
  catch any structural regression. They were intentionally written against
  the public API of the page (`Find.text(...)`, `Find.byType(...)`), not
  against private internals, so they should survive the refactor unchanged.
- BLoC providers and routes do not need to move. Every refactored widget
  reads its data either from constructor parameters or from `context.read`
  / `context.watch`, just like the original methods did.
- `const` constructors are used **wherever the analyzer accepts them**. If a
  parameter is non-constant (e.g. an `ArticleEntity` from a stream), the
  constructor stays non-const but the widget class is still extracted.

## Open Questions

None. This is a pure refactor with a clear scope.

## Test Coverage

This is a refactor spec — no new acceptance criteria, no new test files.
The proof of behaviour preservation comes from running the **existing**
suite without touching it.

| Acceptance criterion | Verified by |
|---------------------|-------------|
| Scenario 1 (`daily_news.dart` no `_buildXxx`) | `grep "Widget _build" lib/features/` returns nothing |
| Scenario 2 (`article_detail.dart` no `_buildXxx`) | Same grep |
| Scenario 3 (`saved_article.dart` no `_buildXxx`) | Same grep |
| Scenario 4 (`article_tile.dart` no `_buildXxx`) | Same grep |
| Scenario 5 (`publish_article_page.dart` build split) | File reviewed, `_PublishAction`, `_PublishForm`, `_SubmitProgress` extracted |
| Scenario 6 (`community_article_detail_page.dart` build split) | File reviewed, `_DetailHeroImage`, `_DetailBody`, `_DetailTitleAndDate`, `_DetailDeletingIndicator` extracted |
| Scenario 7 (existing tests still pass) | **41/41 tests passing without any test file modification** |
| Scenario 8 (manual smoke test) | Validated end-to-end on iPhone 17 Pro simulator: Daily News → article detail → save → Saved Articles → remove → Community → tap card → Edit → Save → Delete. Every screen rendered identically and every action behaved the same as before the refactor. |

### Why no new tests

The "tests mandatory" rule from AGENTS.md §4 has an explicit carve-out: tests
prove acceptance criteria. A refactor that adds **zero** new acceptance
criteria — only restructures the same UI tree — is fully proved by the
existing suite plus the manual smoke test, *provided* the existing tests
continue to pass without modification. They did. This satisfies both the
letter and the intent of the rule.

This is documented as a deliberate exception in this spec rather than a
silent omission.

## Deviations

### 1. The `_ArticleTileImageFrame` helper widget was added beyond the spec

The `_ArticleTileImage` extracted from `article_tile.dart` had three
conditional branches (image / progress / error) that all wrapped a nearly
identical `Padding > ClipRRect > Container` chrome. Rather than copy that
chrome three times, a tiny `_ArticleTileImageFrame` widget holds it. This
is one extra widget class beyond what the spec literally listed in
"Implementation Checklist", but it serves the spec's spirit (no duplication,
clear composition).

### 2. The `_PublishForm` widget receives a `_LengthValidator` typedef

The `_PublishForm` widget is stateless but needs the parent's
`_validateLength` method to validate fields. Rather than duplicating the
validator, the parent passes a function reference via a `_LengthValidator`
typedef declared in the same file. This keeps validation logic in one place
and the form widget pure.

### 3. Some root widgets in `daily_news.dart` and `saved_article.dart`
became `const`

`DailyNews.build()` now returns a `Scaffold` whose `appBar` is a `const
_DailyNewsAppBar()` and whose `body` includes a `BlocBuilder`. Where the
analyzer accepted it, constructors are `const`. This is the const-benefit
the spec called out as a success criterion, captured in real code.
