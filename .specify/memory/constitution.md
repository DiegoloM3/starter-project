<!--
  Sync Impact Report
  ==================================================
  Version change: N/A → 1.0.0 (initial ratification)
  Modified principles: N/A (first version)
  Added sections:
    - Core Principles (7 principles)
    - Technology Stack
    - Development Workflow & Quality Gates
    - Governance
  Removed sections: N/A
  Templates requiring updates:
    - .specify/templates/plan-template.md ✅ no change needed
      (consumes principles dynamically via Constitution Check)
    - .specify/templates/spec-template.md ✅ no change needed
      (structure already aligned with BDD acceptance criteria)
    - .specify/templates/tasks-template.md ✅ no change needed
      (phase structure supports layer-by-layer implementation)
    - .specify/templates/checklist-template.md ✅ no change needed
      (generic template, adapts at generation time)
  Follow-up TODOs: None
  ==================================================
-->

# Symmetry Applicant Showcase App Constitution

## Core Principles

### I. Clean Architecture (NON-NEGOTIABLE)

Every feature MUST be structured into exactly three layers,
each represented as a folder:

- **Data Layer**: data sources, models, repository implementations.
- **Domain Layer (Business Logic)**: entities, use cases, repository
  interfaces, params.
- **Presentation Layer**: BLoC/Cubit, screens, widgets.

Each layer MUST only communicate with the layer directly adjacent
to it. The Data Layer imports only from Domain. The Presentation
Layer imports only from Domain. Cross-layer imports (e.g.,
Presentation importing from Data) are a blocking violation that
MUST be rejected in review. Refer to `docs/ARCHITECTURE_VIOLATIONS.md`
for the exhaustive violation catalog.

### II. Domain Purity

The Domain Layer MUST have zero dependencies on external packages,
Flutter framework code, or any other project module. It MUST be
written in pure Dart. This guarantees the business logic is
independently testable, portable, and free from infrastructure
coupling. Entities define business objects and business rules only.
Use cases implement a single business operation via repository
interfaces. Repository interfaces are abstract classes — never
concrete implementations.

### III. Dependency Inversion

All dependencies MUST point inward (infrastructure → domain,
never the reverse). Repository contracts are defined as abstract
classes in `domain/repository/` and implemented in
`data/repository/`. Use cases depend on repository interfaces,
never on concrete data sources. Presentation components depend on
use cases, never on repositories or data sources directly.
Dependencies MUST be injected (via `injection_container.dart`
or equivalent DI mechanism), never imported as concrete types
from outer layers.

### IV. BLoC-Only State Management

All UI state management MUST use the BLoC/Cubit pattern. BLoCs
are the ONLY presentation components permitted to invoke use cases.
Screens and widgets MUST NOT contain business logic, network calls,
or direct data-layer access. Screens receive state from BLoCs and
dispatch events — nothing more. This ensures a testable,
predictable state flow with clear separation of concerns.

### V. Test-Driven Development

TDD MUST be followed for all production code per the three laws:

1. No production code without a failing test first.
2. Write only enough test to fail (compilation failure counts).
3. Write only enough production code to pass the failing test.

Red-Green-Refactor cycle is strictly enforced. Every feature MUST
have unit tests for use cases, repository implementations, and
BLoCs. Integration tests MUST be created or updated when a user
journey is added or changed. The `test/` folder MUST mirror the
`lib/` folder structure with `_test.dart` suffixes.

### VI. Clean Code Discipline

All code MUST adhere to the project coding guidelines
(`docs/CODING_GUIDELINES.md`):

- **Boy Scout Rule**: Every change MUST leave the code cleaner
  than it was found.
- **Meaningful Names**: Intention-revealing, pronounceable,
  convention-following. Class names are nouns; function names
  are verbs.
- **Small Functions**: Maximum nesting depth of 2. Each function
  does exactly one thing (SRP). Prefer fewer arguments (0-2);
  3+ arguments require justification.
- **Command-Query Separation**: Functions either mutate state or
  return data, never both.
- **Small Classes**: Single responsibility, low instance variable
  count, high cohesion.
- **Abstract Classes for Isolation**: Use interfaces to decouple
  from implementation details and isolate from change.

### VII. Spec-Driven Development

No implementation code MUST be written without a validated
specification. The spec MUST exist in `specs/` before any
implementation commit. Acceptance criteria MUST use
Given-When-Then (BDD) format. Every implemented behavior MUST
trace back to a spec acceptance criterion. Behavior not covered
by the spec MUST either be added to the spec (if valid) or
removed from the implementation (if scope creep). Spec commits
MUST predate implementation commits in git history.

## Technology Stack

- **Frontend**: Flutter (Dart), BLoC for state management
- **Backend**: Firebase Firestore (NoSQL), Firebase Cloud Storage
  for media assets
- **Local Persistence**: Floor (SQLite) via `app_database.dart`
- **Networking**: Retrofit/Dio for REST API consumption
- **DI**: `get_it` via `injection_container.dart`
- **Architecture**: Clean Architecture (3-layer) per
  `docs/APP_ARCHITECTURE.md`
- **Emulator**: Firebase Local Emulator Suite for local
  development and testing
- **Code Generation**: `build_runner` for Floor, Retrofit,
  and JSON serialization

Data sources are the ONLY classes permitted to interact with
external services (APIs, Firebase, local storage, hardware).
Models MUST extend domain entities and provide `toEntity()` and
`fromRawData()` conversions. Repository implementations MUST
return `DataState<Type>` when fetching remote data.

## Development Workflow & Quality Gates

1. **Branch-per-feature**: Every change is developed on a
   dedicated branch and merged via pull request.
2. **Spec before code**: A spec in `specs/` with status
   `accepted` MUST exist before implementation begins.
3. **Architecture review**: Every PR MUST be verified against
   `docs/ARCHITECTURE_VIOLATIONS.md`. Any violation is a
   blocking rejection.
4. **Code quality review**: Every PR MUST be verified against
   `docs/CODING_GUIDELINES.md` (rules referenced as CG{n}).
5. **Test coverage**: No PR is mergeable without passing tests
   that cover all acceptance criteria from the spec.
6. **Commit convention**: Spec commits use
   `feat: spec — <feature-name> [spec-kit]`. Implementation
   commits reference spec IDs:
   `feat: implement <description> [<spec-id>]`.

## Governance

This constitution supersedes all ad-hoc practices. All PRs and
code reviews MUST verify compliance with these principles.
Complexity beyond what the principles permit MUST be justified
in the plan's Complexity Tracking table. Amendments to this
constitution require:

1. A written proposal documenting the change and its rationale.
2. CTO approval before the amendment takes effect.
3. A migration plan for existing code if the amendment
   invalidates current patterns.
4. Version bump following semantic versioning:
   - MAJOR: Principle removal or backward-incompatible redefinition.
   - MINOR: New principle or materially expanded guidance.
   - PATCH: Clarifications, typo fixes, non-semantic refinements.

Reference `docs/APP_ARCHITECTURE.md`,
`docs/ARCHITECTURE_VIOLATIONS.md`, and `docs/CODING_GUIDELINES.md`
as the runtime development guidance for day-to-day implementation.

**Version**: 1.0.0 | **Ratified**: 2026-04-07 | **Last Amended**: 2026-04-07
