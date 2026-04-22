# Implementation Plan: Symmetry Frontend "Cyber Night" Redesign

This plan outlines the steps to transition the Symmetry (InfoVeraz) frontend to a premium "Cyber Night" design system and complete technical modernizations, as requested in the `@frontend_redesign_tasks.md.resolved` checklist.

## Proposed Changes

### 1. Technical Modernization
- **Analysis Options**: Update `analysis_options.yaml` with more rigorous linting rules to ensure high-quality code.
- **Dependencies**: Ensure `pubspec.yaml` uses the most stable versions of `dio`, `flutter_markdown`, and `flutter_lints`.

#### [MODIFY] [analysis_options.yaml](file:///c:/Users/soyko/Symmetry_fork/starter-project/frontend/analysis_options.yaml)
- Add rules for `always_use_package_imports`, `prefer_const_constructors`, `use_super_parameters`, etc.

### 2. Design System "Cyber Night"
- **Colors**: Refine `AppColors` with deeper "Deep Space" backgrounds and vibrant "Cyber Cyan" accents, including specific opacity levels for glassmorphism.
- **Theme**: Expand `ThemeData` in `app_themes.dart` to cover all semantic color schemes, text styles, and component themes (Button, Card, AppBar).

#### [MODIFY] [app_colors.dart](file:///c:/Users/soyko/Symmetry_fork/starter-project/frontend/lib/core/constants/app_colors.dart)
- Fine-tune primary and accent colors for a more cohesive neon palette.

#### [MODIFY] [app_themes.dart](file:///c:/Users/soyko/Symmetry_fork/starter-project/frontend/lib/config/theme/app_themes.dart)
- Implement comprehensive `ThemeData` including `inputDecorationTheme` for the publish page and `elevatedButtonTheme`.

### 3. Architecture & Navigation
- **Decoupling**: Ensure navigation logic is handled cleanly.
- **Routing**: Ensure all routes use the centralized `AppRoutes`.

#### [MODIFY] [daily_news.dart](file:///c:/Users/soyko/Symmetry_fork/starter-project/frontend/lib/features/daily_news/presentation/pages/home/daily_news.dart)
- Cleanup any remaining inline hardcoded styles by moving them to the theme.

### 4. Premium Components (Redesign)
- **ArticleTile**: Implement glassmorphism, glowing borders, and better typography.
- **OwlAssistant**: Add a "HUD" feel with blur filters and animated scanline effects.
- **CtaBanner**: Modernize with a gradient and a more integrated feel.

#### [MODIFY] [article_tile.dart](file:///c:/Users/soyko/Symmetry_fork/starter-project/frontend/lib/features/daily_news/presentation/widgets/article_tile.dart)
#### [MODIFY] [owl_assistant.dart](file:///c:/Users/soyko/Symmetry_fork/starter-project/frontend/lib/features/daily_news/presentation/widgets/owl_assistant.dart)
#### [MODIFY] [cta_banner.dart](file:///c:/Users/soyko/Symmetry_fork/starter-project/frontend/lib/features/daily_news/presentation/widgets/cta_banner.dart)

### 5. Enriched Reading Experience
- **Markdown Styling**: Provide a rich markdown style sheet that matches the "Cyber Night" theme.

#### [MODIFY] [article_detail.dart](file:///c:/Users/soyko/Symmetry_fork/starter-project/frontend/lib/features/daily_news/presentation/pages/article_detail/article_detail.dart)
- Finalize the layout with the new theme and markdown renderer.

## Verification Plan

### Automated Tests
- `flutter analyze`: Ensure 0 errors and minimal warnings.
- `build_runner`: Verify that no code generation issues are introduced.

### Manual Verification
- Visual inspection of the "Cyber Night" aesthetic on the home page and article details.
- Verify "Publish Article" flow with the new theme.
