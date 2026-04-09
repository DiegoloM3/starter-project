---
id: 009-robust-article-detail-image
title: "Robust Image and Content Rendering on the Daily News Article Detail Page"
status: implemented
version: 1.1.2
---

> **Amendment v1.1.0** — after the initial fix (v1.0.0), a console inspection of
> the actual NewsAPI response revealed two deeper issues: the image bug was
> caused by our own `kDefaultImage` fallback constant (not by NewsAPI returning
> bad URLs), and the `content` field arrives in multiple formats that the UI
> was rendering raw. This amendment expands the scope to fix the root cause and
> add content sanitization. The v1.0.0 work (CachedNetworkImage + errorWidget)
> is preserved — it is still the right defensive layer.

## User Problem

On the Daily News article detail page, the user was seeing a raw Flutter error
widget — a red X with `Exception: Invalid image data` — instead of a graceful
placeholder. v1.0.0 of this spec fixed the symptom by switching the widget to
`CachedNetworkImage` with an `errorWidget`.

v1.1.0 digs into the root cause and a second, related issue with content
rendering:

1. **Root cause of the image bug** — NewsAPI returned `urlToImage: null` for
   the affected article. Our own model substituted a hardcoded constant
   `kDefaultImage` (in `core/constants/constants.dart`) which is **not an
   image URL** — it is a Google Images search page URL. `CachedNetworkImage`
   dutifully downloaded the HTML and then threw `Invalid image data` during
   decode. The constant was junk since the base repository. The console still
   logs the decode exception even though v1.0.0 hides it from the user.

2. **Content field is not plain text** — The NewsAPI `content` field arrives
   in several shapes that the UI was rendering raw:

   - `"Local\r\nUPDATE: An ICE spokesperson...\u2026 [+2978 chars]"` — normal
     article text, with `\r\n` line breaks and NewsAPI's own `[+N chars]`
     truncation marker glued to the end.
   - `"{\"en\":{\"access_disabled\":\"Internet access has been disabled...\",\"code\":\"Code\",\"custom_block_list\":\"it is on a custom block list\"...}} [+6792 chars]"` —
     when NewsAPI's scraper hit a block page (Cloudflare, captcha, etc.), it
     captured the page's JSON translation dictionary as "content". This is
     junk. It was being rendered verbatim to the user.
   - `""` or `null` — no content at all.

   The current `ArticleDescription` widget concatenates `description` and
   `content` with `$description\n\n$content`, so junk content pollutes the
   screen directly.

### v1.0.0 reproduction

The bug was a direct inconsistency inside our own codebase:

- `daily_news/.../widgets/article_tile_image.dart` uses `CachedNetworkImage`
  with `errorWidget` — the listing rendered a clean error icon.
- `daily_news/.../widgets/article_image.dart` used raw `Image.network` with
  no `errorBuilder` — the detail page let the exception bubble up.
- `community_articles/.../widgets/community_article_detail_hero_image.dart`
  already did the right thing.

v1.0.0 fixed the detail page to match the community pattern.

### v1.1.0 reproduction

After v1.0.0 was running, a `curl` of `https://newsapi.org/v2/top-headlines`
showed that the "Michael Jackson Movie..." article has
`"urlToImage": null` — NewsAPI itself is not sending a bad URL, it sends
`null`. Our `ArticleModel.fromRawData` then substitutes `kDefaultImage`
(the Google search URL). That is why the UI error branch kept firing even
after v1.0.0: the widget is robust, but the data layer was lying about
the URL being present.

## Solution Hypothesis

### v1.0.0 (shipped)

Replace `Image.network` with `CachedNetworkImage` in
`daily_news/presentation/widgets/article_image.dart`:

- `placeholder` → centered `CupertinoActivityIndicator` in a grey container.
- `errorWidget` → `Icons.broken_image_outlined` in the same grey container.
- Preserve existing dimensions.

This is the defensive layer and stays in place.

### v1.1.0 additions

**1. Delete `kDefaultImage` and stop lying about URLs.**

- Remove the constant from `core/constants/constants.dart`.
- In `ArticleModel.fromRawData`, map missing/empty `urlToImage` to
  `null` (not to a fake URL).
- Update `ArticleImage` to accept a **nullable** `String? imageUrl`. When
  null or empty, short-circuit to the same error placeholder without ever
  asking `CachedNetworkImage` to load anything. This eliminates the
  `Invalid image data` log noise because there is no longer an HTTP
  request to fail.
- Update `ArticleDetailBody` to stop force-unwrapping `article.urlToImage!`.

**2. Sanitize `content` before rendering.**

Add a pure function `sanitizeArticleContent(String? raw) → String?` in
`daily_news/presentation/utils/sanitize_article_content.dart`:

- Return `null` for null, empty, or whitespace-only input.
- Strip the trailing `[+N chars]` NewsAPI truncation marker via regex.
- Normalize `\r\n` → `\n`.
- If the trimmed result starts with `{` or `[` **and** parses as JSON,
  return `null` — it is scraper junk (translation dictionaries, block
  pages), not article content.
- Otherwise return the cleaned string.

Wire `ArticleDescription` to call the sanitizer. When the sanitized
content is `null`, render a small italic line:
`"Full article available at the source."` (already links via the existing
page URL — no new navigation needed).

**3. No upstream changes.** We do not touch `NewsApiService`, `Dio`, or
the repository. Sanitization is presentation-layer concern; the raw data
stays intact in storage and entities in case a future caller wants it.

## Success Metrics

- [x] **(v1.0.0)** Opening an article whose `urlToImage` is invalid shows the
      broken-image placeholder instead of a red error widget.
- [x] **(v1.0.0)** Widget tests prove the error path renders the placeholder.
- [ ] **(v1.1.0)** The `kDefaultImage` constant no longer exists anywhere in
      the codebase.
- [ ] **(v1.1.0)** Opening the affected article produces **no**
      `Exception: Invalid image data` line in the console — not even a
      caught/hidden one.
- [ ] **(v1.1.0)** The affected article renders its header + description + a
      "Full article available at the source." line instead of the JSON scraper
      junk.
- [ ] **(v1.1.0)** An article with a normal `content` field still renders it,
      with the `[+N chars]` suffix stripped and `\r\n` normalized.
- [ ] **(v1.1.0)** Unit tests pin the sanitizer for: null, empty, whitespace,
      JSON junk, `[+N chars]` stripping, and plain text passthrough.

## User Story

As a **Daily News reader**, I want every article — even the ones where
NewsAPI has no image or where the scraper hit a block page — to open cleanly
and show only the information that is actually useful, so that I can read
the headline, description, and (when available) body text without the app
looking broken or dumping raw JSON at me.

## Acceptance Criteria

### Scenario 1: Valid image URL renders normally

- **Given** an article whose `urlToImage` resolves to a real image
- **When** the user opens the detail page
- **Then** the image renders at the same size and position as before
- **And** no error is shown

### Scenario 2: Invalid URL shows placeholder instead of error

- **Given** an article whose `urlToImage` is not a valid image
  (e.g. HTML page, 404, malformed URL)
- **When** the user opens the detail page
- **Then** a grey placeholder with `Icons.broken_image_outlined` is shown
- **And** no red error widget appears
- **And** no `Exception: Invalid image data` is logged

### Scenario 3: Loading state shows a progress indicator

- **Given** an article whose image is still downloading
- **When** the user opens the detail page
- **Then** a centered `CupertinoActivityIndicator` is shown in the same box
- **And** it is replaced by the image once loaded, or by the placeholder on
  error

### Scenario 4: NewsAPI returns `urlToImage: null` — no network call at all

- **Given** an article whose NewsAPI `urlToImage` field is `null` or `""`
- **When** the model is built via `ArticleModel.fromRawData`
- **Then** `model.urlToImage` is `null` (not a fake URL)
- **And** when the detail page renders, the placeholder is shown directly
- **And** no image download is attempted
- **And** no `Invalid image data` exception reaches the console

### Scenario 5: Content is a truncated plain-text body

- **Given** NewsAPI returns
  `"Local\r\nUPDATE: An ICE spokesperson issued this statement... [+2978 chars]"`
- **When** the detail page renders
- **Then** the `[+2978 chars]` marker is not visible
- **And** `\r\n` is normalized so the UI shows clean line breaks
- **And** the plain text is rendered as the body

### Scenario 6: Content is JSON scraper junk

- **Given** NewsAPI returns
  `"{\"en\":{\"access_disabled\":\"Internet access has been disabled...\"}} [+6792 chars]"`
- **When** the detail page renders
- **Then** no JSON or braces are visible to the user
- **And** the body area shows the italic fallback line
  `"Full article available at the source."`
- **And** the header and description still render normally

### Scenario 7: Content is null or empty

- **Given** NewsAPI returns `content: null` or `content: ""`
- **When** the detail page renders
- **Then** the body area shows the same italic fallback line
- **And** no spurious blank paragraph is injected

## Out of Scope

- Filtering or sanitizing NewsAPI responses in the data layer. Sanitization
  lives in the presentation layer so the raw entity is preserved.
- Rendering the full article body via an in-app WebView — we just direct the
  user to the source URL that already exists on the article.
- Changing the tile image (already has `errorWidget`).
- Changing the community feed / detail (already have `errorWidget`).
- Adding retry UI or "report broken image" actions.
- Detecting image MIME type before download — the short-circuit is only for
  null/empty URLs; non-image URLs still fall through to `errorWidget`.
- Rich text formatting (bold, links) for `content`.

## Assumptions

- `cached_network_image` is already a dependency (it is).
- The visual design of the placeholder (grey box + `broken_image_outlined`)
  is acceptable and consistent with the rest of the app.
- 250px height on the detail page is unchanged.
- The only existing consumer of `kDefaultImage` is `ArticleModel.fromRawData`
  at `lib/features/daily_news/data/models/article.dart:44`. Grep-verified.
- `ArticleEntity.urlToImage` is already `String?` in the domain layer, so
  allowing nulls through the model does not require an entity migration.
- Sanitizing content in presentation (not data) means the Floor-persisted
  saved articles continue to store the raw string; the same sanitizer runs
  on read. No database migration.
- The fallback line for missing/junk content is static copy — no
  localization framework is in use, consistent with the rest of the app.

## Open Questions

None.

## Test Coverage

| Acceptance criterion | Test |
|----------------------|------|
| Scenario 1 (valid URL path) | Not automated — relies on real network. Manual smoke test on simulator. |
| Scenario 2 (error → placeholder) | `article_image_test.dart` → "errorWidget builder shows Icons.broken_image_outlined" invokes the `errorWidget` callback directly with a fake exception and asserts the placeholder renders. |
| Scenario 3 (loading indicator) | `article_image_test.dart` → "placeholder builder shows a CupertinoActivityIndicator" invokes the `placeholder` callback directly and asserts the indicator renders. |
| Structural guarantee | `article_image_test.dart` → "uses CachedNetworkImage instead of raw Image.network" pins the widget choice so a future refactor back to raw `Image.network` fails this test. |

Widget tests live in `test/features/daily_news/presentation/widgets/article_image_test.dart`. v1.1.0 adds two more (null and empty URL short-circuit) bringing it to 5 tests in that file.

### v1.1.0 test additions

| Acceptance criterion | Test |
|----------------------|------|
| Scenario 4 (null urlToImage → null in model) | `article_test.dart` → 3 new tests covering `null`, missing field, and empty string input. The previous "substitutes the default image" test was replaced. |
| Scenario 4 (null urlToImage → placeholder, no network call) | `article_image_test.dart` → "renders the placeholder directly when imageUrl is null" + same for empty string. Assert `find.byType(CachedNetworkImage)` is empty — proves the short-circuit. |
| Scenarios 5, 6, 7 (content sanitization) | `sanitize_article_content_test.dart` → 10 unit tests covering null, empty, whitespace, `[+N chars]` stripping, CRLF normalization, JSON scraper junk (object + array), text that starts with `{` but is not valid JSON, plain text passthrough. |

Suite total after v1.1.0: **59/59 passing**. Analyzer baseline unchanged (1 info from auto-generated `.g.dart`).

## v1.1.2 Hotfix

Manual validation on iOS simulator after v1.1.0 shipped revealed three
regressions introduced by that change. All three are fixed here.

### Regression 1 — sanitizer missed truncated JSON

**Symptom:** the Michael Jackson article detail page still rendered the raw
`{"en":{"access_disabled":...` JSON body after v1.1.0.

**Root cause:** the v1.1.0 sanitizer used `jsonDecode` to detect JSON. NewsAPI
truncates the scraper junk mid-string (followed by its `[+N chars]` marker),
so after stripping the marker the remainder is structurally broken JSON and
`jsonDecode` throws. The sanitizer's `catch` branch fell through and returned
the junk unchanged.

**Fix:** replace the parse-based detection with a regex that matches the
**prefix shape** of JSON scraper dumps — `^\s*[\{\[][\{\[\s,]*"[^"]+"\s*:`.
This looks for "opens with `{` or `[` (possibly nested), then a quoted key,
then a colon" — the universal shape of every scraped dictionary, parseable
or not. False positives on prose are vanishingly rare (article text does not
typically start with a quoted-key pattern) and are protected by the existing
"text that starts with `{` but is not JSON" test.

Regression covered by
`sanitize_article_content_test.dart` → "returns null for truncated JSON
scraper junk (real NewsAPI shape)". The test uses the actual string from
the NewsAPI response (including the unicode ellipsis).

### Regression 2 — `ArticleTileImage` rendered the default error icon

**Symptom:** the tile for the Michael Jackson article in the Daily News list
showed a generic `Icons.error` (`!`) circle instead of the clean
`broken_image_outlined` placeholder used on the detail page.

**Root cause:** `article_tile_image.dart` took a non-nullable
`String imageUrl` and always constructed a `CachedNetworkImage`. With
`urlToImage: null` now preserved, the caller was passing `""` (or, after
regression 3 below, crashing). Even when a value was passed, the
`errorWidget` was the stale `Icons.error` from the base repo.

**Fix:** make `ArticleTileImage.imageUrl` nullable and short-circuit to the
same `broken_image_outlined` placeholder inside `ArticleTileImageFrame` when
null/empty. Update the `errorWidget` callback to use the same icon for
visual consistency with the detail page and the community hero image.

### Regression 3 — Null-check crash on scroll

**Symptom:** after hot-restart, scrolling the Daily News feed threw:

```
_TypeError: Null check operator used on a null value
  at article_tile.dart:44
```

**Root cause:** `ArticleWidget` force-unwrapped
`article!.urlToImage!` on line 44. Before v1.1.0, `urlToImage` was never
null at the model level (the fake `kDefaultImage` hid the problem). v1.1.0
correctly preserved null but did not update this call site.

**Fix:** remove the `!` on `urlToImage` in `article_tile.dart:44` and let the
now-nullable `ArticleTileImage` handle the null case. Other force-unwraps in
that file (`publishedAt!`) are untouched — they are pre-existing tech debt
unrelated to this spec, and changing them is out of scope.

### v1.1.2 test additions

| Regression | Test |
|-----------|------|
| Sanitizer truncated JSON | `sanitize_article_content_test.dart` → "returns null for truncated JSON scraper junk (real NewsAPI shape)" |
| Sanitizer JSON array keyed by identifier | `sanitize_article_content_test.dart` → "returns null for a JSON array keyed by a quoted identifier" (replaces the removed `[1,2,3]` test — the new regex deliberately does not match that shape) |
| ArticleTileImage null URL | `article_tile_image_test.dart` → "renders the placeholder directly when imageUrl is null" + same for empty |
| ArticleTileImage valid URL | `article_tile_image_test.dart` → "constructs a CachedNetworkImage when imageUrl is provided" |

Suite total after v1.1.2: **63/63 passing**. Analyzer baseline unchanged.

### Deviation: builder callbacks tested directly, not via full image load

The original test plan was to pump `ArticleImage` and wait for the real image loader to settle. In the Flutter test environment, `CachedNetworkImage`'s retry/decode pipeline does not settle within `pumpAndSettle`, so the tests timed out. The builders are tested by invoking `placeholder(...)` and `errorWidget(...)` directly on the found `CachedNetworkImage` widget, which exercises the same code paths that the bug triggered in production without fighting the loader.
