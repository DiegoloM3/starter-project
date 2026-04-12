# Applicant Showcase App

---

## Implementation by Luis Alberto De La Torre

### Delivery Summary

Full implementation of the **article upload feature** for journalists, built with Clean Architecture across backend (Firebase Firestore + Cloud Storage), frontend (Flutter + BLoC), and **19 overdelivery features** that go beyond the original requirements.

The app was personalized with **my personal logo** (golden T) and **my brand colors** (`#E8D44D` golden yellow + `#3D3D3D` charcoal gray), applied to the splash screen, app icon, app theme (light/dark), and login/onboarding screens.


### Personal Branding

| Element | Detail |
|---|---|
| **Logo** | My personal logo (golden T) replaces all generic icons |
| **Primary color** | `#E8D44D` — FABs, buttons, badges, indicators |
| **Secondary color** | `#3D3D3D` — dark mode scaffold, splash screen, app icon background |
| **Splash screen** | Centered logo on #3D3D3D background on app launch |
| **App icon** | Adaptive icon with my logo and brand background |
| **Dark mode** | Dark theme with my brand colors, activated automatically based on system preference |

### Core Features (Assignment Requirements)

| Feature | Status |
|---|---|
| Create article with image upload | Completed |
| List own articles | Completed |
| View article detail | Completed |
| Edit article | Completed |
| Delete article (soft-delete) | Completed |
| Firestore schema documented | Completed |
| Firestore/Storage security rules | Completed |

### 19 Overdelivery Features

| # | Feature |
|---|---|
| 1 | Google Sign-In (real authentication) |
| 2 | Onboarding (3 slides, first time only) |
| 3 | Mandatory login before accessing content |
| 4 | Dark mode (ThemeMode.system) |
| 5 | Centralized design tokens (ThemeExtension) |
| 6 | Internationalization EN/ES (80+ strings) |
| 7 | In-app language switcher |
| 8 | Offline cache with Floor (SQLite) |
| 9 | Cursor-based pagination |
| 10 | Search/filter by title, description, author |
| 11 | Skeleton loaders (shimmer) |
| 12 | Hero animations (list to detail) |
| 13 | Soft delete with deletedAt field |
| 14 | 14 unit tests (mocktail + bloc_test) |
| 15 | Personal branding (logo, splash, icon, colors) |
| 16 | Modular DI (one module per feature) |
| 17 | Premium UI/UX (featured cards, sectioned form, human-readable dates) |
| 18 | Accessibility (Semantics, tooltips, AA contrast) |
| 19 | iOS platform support |

### Improvements to Existing Feature (daily_news)

- Redesigned article tiles with featured card (1st article) and rounded-corner cards
- Human-readable dates ("3h ago", "2d ago") instead of raw ISO strings
- Shimmer loading instead of generic spinner
- Pull-to-refresh
- Error state with icon + message + Retry button
- DioException removed from presentation layer
- ArticleModel.toEntity() added per architecture rules
- GestureDetector replaced with IconButton + tooltips
- kDefaultImage fixed (broken URL replaced with valid placeholder)
- DI separated into independent module

### Documentation

| Document | Description |
|---|---|
| [Final Technical Report](./README_final.md) | Full architecture detail, dependencies, technical decisions |
| [Database Schema](./backend/docs/DB_SCHEMA.md) | NoSQL schema with Mermaid diagrams, design decisions, cost estimation |
| [Project Report](./docs/REPORT.md) | 7 sections: introduction, learning journey, challenges, reflection, overdelivery, self-audit |
| [App Architecture](./docs/APP_ARCHITECTURE.md) | Clean Architecture layers and folder structure |
| [Architecture Violations](./docs/ARCHITECTURE_VIOLATIONS.md) | Layer import rules and compliance |
| [Coding Guidelines](./docs/CODING_GUIDELINES.md) | Code quality standards |
| [Contribution Guidelines](./docs/CONTRIBUTION_GUIDELINES.md) | Branch and PR conventions |
