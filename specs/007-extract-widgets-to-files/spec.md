---
id: 007-extract-widgets-to-files
title: "Extract Private Widgets into Separate Files Under `widgets/`"
status: implemented
version: 1.0.0
---

## User Problem

Spec 006 split every `Widget _buildXxx()` method into a private widget
class (`class _Xxx extends StatelessWidget`) **inside the same `.dart`
file** as the page that uses it. Spec 006 explicitly listed
"splitting widgets across files" in `## Out of Scope`.

That decision is being reversed:

1. The page files are still long (200–400 lines) because they hold both
   the page widget and 4–6 private helper widgets. Long files are harder
   to navigate and to grep.
2. Private widgets are not testable in isolation. With Dart's per-file
   privacy model, anything `_`-prefixed cannot be the target of a widget
   test from another file.
3. The repository already has the convention `presentation/widgets/`
   for `daily_news` (with `article_tile.dart`). It is inconsistent that
   `community_articles` has no equivalent folder and that `daily_news`
   only uses it for one widget.

## Solution Hypothesis

For every private (`_`-prefixed) widget class introduced in spec 006:

1. Move it to its own `.dart` file under
   `<feature>/presentation/widgets/<snake_case_name>.dart`.
2. Drop the leading `_` (the class becomes public so it can be imported).
3. The parent page file imports it like any other widget.
4. Create `community_articles/presentation/widgets/` (does not exist yet).
5. Move the existing private `_CommunityArticleCard` from
   `community_feed_page.dart` for consistency.

This is a **pure refactor** in the same spirit as spec 006: no UI change,
no behaviour change, no public API surface for the rest of the app.
The classes become public *within their feature* but are not exported
beyond it.

## Success Metrics

- [ ] Every `_`-prefixed widget class introduced by spec 006 lives in its
  own file under `widgets/`.
- [ ] No `class _SomeWidget extends StatelessWidget` remains in any
  `pages/*.dart` file.
- [ ] All existing tests (41) pass without any test file modification.
- [ ] `flutter analyze lib/` shows the same baseline (1 info from .g.dart).
- [ ] Manual smoke test on iOS simulator: every screen still loads and
  behaves identically.

## User Story

As a **product engineer working on this codebase**, I want every reusable
piece of UI to live in its own file under `presentation/widgets/`, so
that I can find it quickly, write a widget test against it directly, and
keep page files focused on layout composition only.

## Acceptance Criteria

### Scenario 1: `daily_news/presentation/widgets/` is the home of every helper

- **Given** the daily_news feature
- **When** the `widgets/` folder is listed
- **Then** it contains one file per widget extracted in spec 006:
  `daily_news_app_bar.dart`, `daily_news_articles_list.dart`,
  `saved_articles_app_bar.dart`, `saved_articles_body.dart`,
  `saved_articles_list.dart`, `article_detail_app_bar.dart`,
  `article_detail_body.dart`, `article_title_and_date.dart`,
  `article_image.dart`, `article_description.dart`, `save_article_fab.dart`,
  `article_tile_image.dart`, `article_tile_image_frame.dart`,
  `article_tile_title_and_description.dart`,
  `article_tile_removable_area.dart`
- **And** the existing `article_tile.dart` is unchanged in its public API

### Scenario 2: `community_articles/presentation/widgets/` exists and contains every helper

- **Given** the community_articles feature
- **When** the `widgets/` folder is listed
- **Then** it contains:
  `community_article_card.dart`,
  `community_article_detail_hero_image.dart`,
  `community_article_detail_body.dart`,
  `community_article_detail_title_and_date.dart`,
  `community_article_detail_deleting_indicator.dart`,
  `publish_action.dart`, `publish_form.dart`, `submit_progress.dart`,
  `image_picker_section.dart`

### Scenario 3: Page files only contain page-level widgets

- **Given** any file under `presentation/pages/`
- **When** the file is reviewed
- **Then** it contains exactly one public page widget (and at most its
  `State` class for `StatefulWidget`)
- **And** no private (`_`-prefixed) widget classes remain

### Scenario 4: All existing tests still pass without modification

- **Given** the test suite from spec 006 (41 tests)
- **When** the test suite is run after this refactor
- **Then** every test passes
- **And** no test file is modified

### Scenario 5: Manual smoke test confirms no regression

- **Given** the app running on the iOS simulator
- **When** the user navigates Daily News → article detail → save → Saved
  Articles → remove → Community → tap card → Edit → Save → Delete
- **Then** every screen behaves identically to before this refactor

## Implementation Notes

- **Naming convention:** snake_case for files, PascalCase for classes,
  drop the leading `_`.
- **`_LengthValidator` typedef:** stays in `publish_article_page.dart`
  (or moves to `publish_form.dart` alongside the form widget — whichever
  yields no extra import). It is a helper for the form, not a widget.
- **Imports inside `widgets/`:** prefer relative imports for siblings in
  the same `widgets/` folder; package imports for crossing layer
  boundaries (domain entity, etc.).
- **Constructors stay `const` wherever the analyzer accepts them.**

## Out of Scope (V1)

- Adding any new functionality.
- Changing the visual design.
- Modifying or adding tests.
- Promoting widgets to a shared `core/widgets/` folder. Each widget stays
  inside its feature.
- Adding documentation comments to each new file.

## Assumptions

- The widget tests added in IMP-001 reference `CommunityFeedPage` and
  `PublishArticlePage` via `find.text` / `find.byType` and do not import
  any private widget. They will continue to pass after this refactor
  because the public widgets they target keep the same API.
- The previous `_CommunityArticleCard` was private (`_`-prefixed) and is
  not referenced by any test. Moving and renaming it to
  `CommunityArticleCard` will not break anything.
- The widgets added in spec 006 are tightly coupled to one parent page
  and not reused across pages. Moving them to `widgets/` does not imply
  they are public API of the feature — only that they live in a
  predictable place.

## Open Questions

None. This is a pure mechanical move with naming rules already decided.

## Why This Spec Exists Even Though Spec 006 Just Shipped

Spec 006 explicitly chose "stays in the same file as its parent" as a
deliberate decision. That decision is being reversed here. The audit
trail matters: a future engineer reading `specs/` should see both
decisions and understand that the current state is the result of a
considered reversal, not an oversight.

## Test Coverage

Same exception as spec 006: this is a pure file move with zero new
acceptance criteria. The proof of behaviour preservation is the existing
suite passing without modification, plus the manual smoke test.

| Acceptance criterion | Verified by |
|---------------------|-------------|
| Scenario 1 (`daily_news/widgets/` complete) | `ls lib/features/daily_news/presentation/widgets/` shows 15 files including the original `article_tile.dart` |
| Scenario 2 (`community_articles/widgets/` exists and complete) | `ls lib/features/community_articles/presentation/widgets/` shows 9 files (`community_article_card.dart` plus 4 detail-page widgets and 4 publish-page widgets) |
| Scenario 3 (page files only contain page widgets) | `grep "^class _" lib/features/**/presentation/pages/*.dart` returns nothing — only the auto-generated `.g.dart` files have private classes, and none of those are in `pages/` |
| Scenario 4 (existing tests pass) | **41/41 tests passing without any test file modification** |
| Scenario 5 (manual smoke test) | Validated end-to-end on iPhone 17 Pro: Daily News → article detail → save → Saved Articles → remove → Community → tap card → Edit → Save → Delete. Every screen rendered identically and every action behaved the same as before this refactor. |

### Why no new tests

Same justification as spec 006. The "tests mandatory" rule from
AGENTS.md §4 applies to acceptance criteria. A pure file-move refactor
adds zero acceptance criteria. The unmodified existing suite passing is
the strongest possible proof of behaviour preservation. Documented as a
deliberate exception.

### Side benefit

Now that the previously-private widgets are public classes in their own
files, **future widget tests can target them directly** without needing
to instantiate the parent page. This unblocks part of IMP-001 (the
backlog item for widget test coverage). Specifically, `CommunityArticleCard`,
`PublishForm`, `PublishAction`, `SubmitProgress`, `ImagePickerSection`,
the four `CommunityArticleDetail*` widgets, and every `daily_news` widget
extracted here can now be widget-tested in isolation. That work remains
in IMP-001 — this spec only unblocks it.

## Deviations

### 1. `_LengthValidator` typedef became public as `LengthValidator`

Moved from `publish_article_page.dart` into `widgets/publish_form.dart`
alongside the form widget that uses it. The leading underscore was
dropped because Dart privacy is per-file and the typedef is now imported
by the page from the form file. No functional change.

### 2. `cached_network_image` import migrated where needed

The publish page no longer needs `cached_network_image` directly because
the existing-image preview moved to `widgets/image_picker_section.dart`
along with the import. Same for the detail page → `community_article_detail_hero_image.dart`.
This is a side effect of the move, not an intentional cleanup, but it
reduces page-file imports.

### 3. `community_article_card.dart` was migrated even though it predated
spec 006

`_CommunityArticleCard` was a private widget in `community_feed_page.dart`
since spec 003. It was not part of spec 006's `_buildXxx → class`
conversion, but it was still a private widget in a `pages/` file. Moving
it to `widgets/` for consistency is a small scope expansion beyond a
strict reading of "widgets that became classes in spec 006". Documented
here so the audit trail is honest.
