---
id: 001-architecture-violations
title: "Architecture Violations — Baseline Cleanup"
status: implemented
version: 1.0.0
---

## User Problem

There is no direct user-facing friction today. The app compiles and the existing
article feed works.

The risk is forward-looking: **the next two phases (Firebase backend + article
publishing) require touching the same files that contain these violations.** If the
violations are not corrected first, every new feature will either:

1. Inherit the broken patterns and propagate them further, or
2. Require fixing violations mid-feature, increasing cognitive load and diff noise.

The cost of not fixing this now: the Firebase integration (spec 002) cannot safely
introduce a `RemoteDataSource` because the repository currently bypasses the local
data source entirely — any new source would be inconsistent by design.

## Solution Hypothesis

Fix the 5 identified violations in isolation, before any feature work begins. Each
fix is a mechanical correction with no behavior change — the app should behave
identically before and after. This gives a clean, rule-conformant baseline to build
on.

## Success Metrics

- [ ] All 5 violations resolved with no new violations introduced.
- [ ] App compiles and passes smoke test on Android and iOS simulator.
- [ ] No behavior change visible to the user (same screens, same data, same flow).

## User Story

As a **product engineer adding Firebase integration in Phase 2**, I want the
existing data layer to follow the defined architecture contracts, so that I can
add a `RemoteDataSource` and `LocalDataSource` without refactoring pre-existing
violations at the same time.

## Acceptance Criteria

### Scenario 1: Model layer conforms to contract

- **Given** `ArticleModel` in `data/models/article.dart`
- **When** the class is reviewed
- **Then** it exposes `toEntity()` returning `ArticleEntity` (Rule 1.3.2)
- **And** the JSON constructor is named `fromRawData` not `fromJson` (Rule 1.3.3)

### Scenario 2: Repository returns domain types

- **Given** `ArticleRepositoryImpl` in `data/repository/article_repository_impl.dart`
- **When** either data source method returns a list
- **Then** the return type is `List<ArticleEntity>`, not `List<ArticleModel>` (Rule 2.4.2)

### Scenario 3: Repository accesses DB through data source

- **Given** `ArticleRepositoryImpl`
- **When** it reads or writes local data
- **Then** it delegates to `ArticleLocalDataSource`, not to `AppDatabase` directly (Rule 1.2.3)
- **And** `ArticleLocalDataSource` is defined as an abstract interface in `data/datasources/`

### Scenario 4: Domain layer has no external dependencies

- **Given** `ArticleEntity` in `domain/entities/article.dart`
- **When** its imports are reviewed
- **Then** it does not import `equatable` or any other third-party package (Rule 2.1.1)
- **And** equality is implemented with native Dart `==` and `hashCode` overrides

### Scenario 5: No behavior regression

- **Given** the app running after all corrections
- **When** the user opens the home screen, taps an article, and visits saved articles
- **Then** all three screens behave identically to the pre-fix baseline

## Out of Scope (V1)

- Adding `RemoteDataSource` or any Firebase integration — that is spec 002.
- Changing `ArticleModel` fields or JSON keys.
- Updating any test files beyond what breaks due to the rename `fromJson` → `fromRawData`.
- Fixing Gradle/AGP/Kotlin version warnings (logged in `improvements.md`).

## Assumptions

- `ArticleLocalDataSource` does not yet exist as an interface — it will be created as
  part of this spec at `data/datasources/local/article_local_datasource.dart`.
  Path rationale: `local/` vs `remote/` separation is explicit now so Phase 2's
  `RemoteDataSource` lands in the right place without a rename.
- Renaming `fromJson` to `fromRawData` requires updating every call site; a grep
  confirms the scope before implementation starts.
- Removing `equatable` from `ArticleEntity` is safe. Both BLoC state classes
  (`RemoteArticlesState`, `LocalArticlesState`) extend `Equatable` themselves
  (presentation layer — allowed) and put `List<ArticleEntity>` in `props`. Replacing
  the entity's `Equatable` with native `==`/`hashCode` over the same field list is
  functionally equivalent. The BLoC state classes keep their own `equatable` imports.

## Open Questions

None. All pre-implementation decisions are resolved.

## Test Coverage

| Acceptance criterion | Test file |
|---------------------|-----------|
| Scenario 1 (`toEntity`, `fromRawData`) | `test/features/daily_news/data/models/article_test.dart` |
| Scenario 2 (repo returns `List<ArticleEntity>`) | `test/features/daily_news/data/repository/article_repository_impl_test.dart` |
| Scenario 3 (repo delegates to local data source) | `test/features/daily_news/data/repository/article_repository_impl_test.dart` |
| Scenario 4 (entity has no `equatable`, native `==`/`hashCode`) | `test/features/daily_news/domain/entities/article_test.dart` |
| Scenario 5 (no behaviour regression) | Manual smoke test on Android + iOS simulator |

`getNewsArticles` repository path is not covered by an automated test because
the retrofit-generated `HttpResponse` type requires a real `Dio` to fake
ergonomically. It is exercised by the manual end-to-end run.
