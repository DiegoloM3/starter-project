---
id: 010-user-friendly-published-at
title: "User-Friendly publishedAt Formatting Across Daily News and Community Feeds"
status: implemented
version: 1.1.0
---

## User Problem

Every place that renders `publishedAt` shows a raw ISO 8601 timestamp or an
unlabelled date substring:

- `ArticleTileTitleAndDescription` (daily_news list tile) — shows the full
  ISO string, e.g. `2026-04-07T16:39:52Z`.
- `ArticleTitleAndDate` (daily_news detail) — same.
- `CommunityArticleCard` (community list) — uses `substring(0, 10)` to show
  `2026-04-07`. Better than ISO but still not natural.
- `CommunityArticleDetailTitleAndDate` (community detail) — same substring.

Users do not read `2026-04-07T16:39:52Z` as "about an hour ago". It reads
like a database dump. Every other news app shows either relative time
("2 hours ago", "yesterday") or a clean absolute date ("Apr 7, 2026").
Ours looks unfinished.

## Solution Hypothesis

Introduce a single shared pure function
`formatPublishedAt(String? iso, {DateTime? now})` in
`lib/core/utils/format_published_at.dart`:

- `now` is injectable for deterministic tests. Defaults to `DateTime.now()`.
- Returns a human-readable string, using relative time for recent articles
  and absolute date for older ones:

  | Age of article                  | Output                    |
  |---------------------------------|---------------------------|
  | Invalid / null / empty input    | `""`                      |
  | Future (time skew)              | `"Just now"`              |
  | < 60 seconds                    | `"Just now"`              |
  | 1 minute                        | `"1 minute ago"`          |
  | 2–59 minutes                    | `"N minutes ago"`         |
  | 1 hour                          | `"1 hour ago"`            |
  | 2–23 hours                      | `"N hours ago"`           |
  | 24–47 hours                     | `"Yesterday"`             |
  | 2–6 days                        | `"N days ago"`            |
  | ≥ 7 days                        | Absolute: `"Apr 7, 2026"` (via `intl` `DateFormat('MMM d, y')`) |

- Parses via `DateTime.tryParse(iso)`; on failure returns `""`. No throws.

Every widget that currently renders `publishedAt` calls the formatter:

- `ArticleTileTitleAndDescription`
- `ArticleTitleAndDate`
- `CommunityArticleCard`  (removes the `substring(0, 10)`)
- `CommunityArticleDetailTitleAndDate` (removes the `substring(0, 10)`)

No data layer changes. The raw ISO string still lives on entities/models.
Format is a presentation concern.

## Success Metrics

- [ ] Every rendering site above calls `formatPublishedAt` instead of showing
      the raw string or an ad-hoc substring.
- [ ] The `intl` dependency is already present (`^0.18.1`) — no new deps.
- [ ] Unit tests pin every row of the table above using a fixed `now`.
- [ ] Invalid inputs (empty, garbage, null) return `""` and never throw.
- [ ] Full test suite stays green.
- [ ] Manual smoke test on iOS simulator: the Michael Jackson article tile
      and detail show `"Just now"` / `"1 hour ago"` / similar depending on
      when the run happens.

## User Story

As a **news app user**, I want to see when an article was published in plain
English (`"2 hours ago"` or `"Apr 5, 2026"`), so that I can tell at a glance
how fresh the article is without mentally parsing a timestamp.

## Acceptance Criteria

### Scenario 1: Just now

- **Given** `iso = "2026-04-08T12:00:00Z"` and `now = 2026-04-08T12:00:30Z`
- **When** `formatPublishedAt(iso, now: now)` is called
- **Then** the result is `"Just now"`

### Scenario 2: Minutes ago

- **Given** a publish time 5 minutes before `now`
- **Then** the result is `"5 minutes ago"`
- **And** 1 minute before `now` returns `"1 minute ago"` (singular)

### Scenario 3: Hours ago

- **Given** a publish time 3 hours before `now`
- **Then** the result is `"3 hours ago"`
- **And** 1 hour before `now` returns `"1 hour ago"` (singular)

### Scenario 4: Yesterday

- **Given** a publish time between 24 and 48 hours before `now`
- **Then** the result is `"Yesterday"`

### Scenario 5: N days ago

- **Given** a publish time 3 full days before `now`
- **Then** the result is `"3 days ago"`

### Scenario 6: Absolute date for old articles

- **Given** a publish time 30 days before `now = 2026-04-08T12:00:00Z`
- **Then** the result is `"Mar 9, 2026"` (or the locale-specific equivalent
  produced by `DateFormat('MMM d, y')`)

### Scenario 7: Future / time skew

- **Given** a publish time after `now` (clock drift between server and
  client)
- **Then** the result is `"Just now"` — never a negative duration

### Scenario 8: Invalid, null, empty input

- **Given** `iso = null`, `iso = ""`, or `iso = "not-a-date"`
- **Then** the result is `""`
- **And** the function does not throw

### Scenario 9: All rendering sites use the formatter

- **Given** the daily_news list, daily_news detail, community list, and
  community detail pages
- **When** each renders an article
- **Then** the displayed date is produced by `formatPublishedAt`
- **And** no call site contains `substring(0, 10)` or a raw `publishedAt`
  passthrough to `Text()`

## Out of Scope

- Localization of the relative strings ("hace 2 horas" for Spanish). The
  rest of the app is English-only and there is no l10n infra.
- Showing the absolute time (hours/minutes) alongside the relative label.
- Tooltips with the full ISO timestamp on hover/long-press.
- A timezone selector. The device's local timezone is used implicitly via
  `DateTime.now()` and the UTC parse from the ISO string.
- Periodic re-rendering so `"5 minutes ago"` ticks to `"6 minutes ago"` in
  real time. Each widget build produces a snapshot; the user gets the
  current value on page rebuild.
- Server-side clock correction beyond the "clamp future to Just now" rule.

## Assumptions

- `intl: ^0.18.1` is already in `pubspec.yaml`. Verified.
- NewsAPI emits ISO 8601 with a `Z` suffix; `DateTime.tryParse` handles it.
- Community articles (Firestore) serialize `publishedAt` as an ISO 8601
  string via the existing datasource mapper. Verified: the datasource
  converts `Timestamp` to ISO at read time.
- The empty-string fallback for invalid input is acceptable — the rendering
  widgets all tolerate an empty date cleanly (the icon row just shows
  nothing after the icon).

## Open Questions

None.

## Test Coverage

| Acceptance criterion | Test |
|----------------------|------|
| Scenarios 1–8 (formatter logic) | `test/core/utils/format_published_at_test.dart` — 16 tests covering null/empty/garbage, future-clamp, < 60s, 1 and 5 min, 59 min, 1 and 3 hours, 24 and 47 hours, 3 and 6 days, 7 and 30 days (absolute branch). |
| Scenario 9 (call sites use the formatter) | Verified: `grep 'substring' lib/` on `publishedAt` returns no results. Raw `publishedAt` no longer flows into any `Text`. |
| Visual check | Pending manual smoke test on iOS simulator. |

Suite total after spec 010: **79/79 passing** (63 previous + 16 new). Analyzer baseline unchanged.

## v1.1.0 Amendment — Always Show the Publish Time

### Change

The v1.0.0 formatter only showed a relative bucket ("3 hours ago") or an
absolute date ("Apr 7, 2026"). The user then loses the exact publish time.

v1.1.0 **always appends `· HH:mm`** (24h, device local timezone) to every
non-empty result. Examples:

```
Just now · 14:30
1 minute ago · 14:29
5 minutes ago · 14:25
1 hour ago · 13:30
3 hours ago · 11:30
Yesterday · 16:39
3 days ago · 09:12
Apr 1, 2026 · 09:12
```

### Design decisions

1. **24h format.** `DateFormat('HH:mm')` is locale-independent and avoids
   AM/PM ambiguity. The rest of the app is English-neutral on times.
2. **Local timezone.** `parsed.toLocal()` before formatting. NewsAPI emits
   UTC, so without this conversion the displayed time would be wrong for
   most users. Consistent with the absolute-date branch which already
   used `toLocal()`.
3. **Middle dot separator (`·`).** Visually clean, consistent with the
   `community_article_card` layout conventions. Tests also assert it
   explicitly.
4. **Invalid input still returns `""`**, not `"· HH:mm"`. The guard at the
   top of the function is unchanged.
5. **Future-clamp still wins.** A future timestamp still renders
   `"Just now · HH:mm"` — never a negative relative.

### Test updates

The 16 v1.0.0 tests were rewritten to compute the expected `HH:mm` suffix
**dynamically** from the same ISO input:

```dart
String expectedSuffix(String iso) =>
    DateFormat('HH:mm').format(DateTime.parse(iso).toLocal());
```

This keeps the suite deterministic across machine timezones — an important
property since CI and local dev may run in different zones.

Two sanity tests were added:

- "uses 24h format (no am/pm markers)" — guards against a future change
  accidentally switching to `jm` or `hm`.
- "time suffix is exactly HH:mm zero-padded" — pins the trailing shape.

Suite total after v1.1.0: **81/81 passing** (79 previous + 2 sanity tests).
Analyzer baseline unchanged.
