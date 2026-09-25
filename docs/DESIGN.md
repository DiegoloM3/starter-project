---
name: Editorial Obsidian
colors:
  surface: '#f8f9ff'
  surface-dim: '#d8dadf'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f3f9'
  surface-container: '#eceef3'
  surface-container-high: '#e6e8ee'
  surface-container-highest: '#e1e2e8'
  on-surface: '#191c20'
  on-surface-variant: '#464555'
  inverse-surface: '#2e3135'
  inverse-on-surface: '#eff0f6'
  outline: '#777587'
  outline-variant: '#c7c4d8'
  surface-tint: '#4d44e3'
  primary: '#3525cd'
  on-primary: '#ffffff'
  primary-container: '#4f46e5'
  on-primary-container: '#dad7ff'
  inverse-primary: '#c3c0ff'
  secondary: '#4648d4'
  on-secondary: '#ffffff'
  secondary-container: '#6063ee'
  on-secondary-container: '#fffbff'
  tertiary: '#434853'
  on-tertiary: '#ffffff'
  tertiary-container: '#5b606b'
  on-tertiary-container: '#d7dbe8'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e2dfff'
  primary-fixed-dim: '#c3c0ff'
  on-primary-fixed: '#0f0069'
  on-primary-fixed-variant: '#3323cc'
  secondary-fixed: '#e1e0ff'
  secondary-fixed-dim: '#c0c1ff'
  on-secondary-fixed: '#07006c'
  on-secondary-fixed-variant: '#2f2ebe'
  tertiary-fixed: '#dee2ef'
  tertiary-fixed-dim: '#c2c6d3'
  on-tertiary-fixed: '#171c25'
  on-tertiary-fixed-variant: '#424751'
  background: '#f8f9ff'
  on-background: '#191c20'
  surface-variant: '#e1e2e8'
typography:
  display-lg:
    fontFamily: Newsreader
    fontSize: 40px
    fontWeight: '600'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Newsreader
    fontSize: 30px
    fontWeight: '600'
    lineHeight: 38px
    letterSpacing: -0.015em
  headline-lg-mobile:
    fontFamily: Newsreader
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Newsreader
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  title-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  title-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 22px
  body-lg:
    fontFamily: Inter
    fontSize: 17px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 15px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 13px
    fontWeight: '600'
    lineHeight: 18px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.04em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-mobile: 0.75rem
  margin: 1.25rem
  margin-tablet: 2rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

This design system establishes an elevated digital reading and publishing experience for Android. Rooted in the visual tradition of prestigious print broadsheets yet dynamically calibrated through modern Material 3 conventions, it creates an environment of calm focus, authority, and literary craft.

### Brand Personality & Emotional Atmosphere
- **Discerning & Authoritative:** The interface recedes cleanly into the background, prioritizing typography, crisp photography, and intellectual depth over transient visual gimmicks.
- **Warm Tactility:** Crisp paper surfaces paired with deep obsidian typography simulate natural daylight reading, mitigating screen fatigue during long-form reading sessions.
- **Contemporary Polish:** Subtle violet-tinted accents, pill tags, and soft, ambient physical depth ground the Android experience in tactile modernism.

### Design Movement
**Editorial Modernism infused with Material 3 Expressive:** High-contrast serif headlines meet hyper-clean geometric sans body copy. Layouts maintain structural breathing room with floating sheets, rounded-3xl container modals, and soft pill-shaped interactive anchors.

## Colors

The palette balances warm paper neutrals, deep carbon blacks, and dynamic indigo/violet anchors to communicate clarity and literary distinction.

### Palette Architecture
- **Primary (`#4F46E5` / `#6366F1`):** Electric indigo serves as the primary action anchor, applied to key buttons, active navigation markers, selection states, and primary reading metrics.
- **Tertiary Tint (`#EEF2FF`):** Soft luminous lavender-indigo surface tint used for primary pill badges, floating action button containers, active chip backgrounds, and focused surface highlights.
- **Surface & Canvas (`#F8F9FA`):** Warm crisp newsprint-inspired background preventing harsh glare while maintaining high contrast.
- **Typography & Ink:**
  - `Ink Obsidian` (`#111418`): Used for primary headlines, titles, and critical actions.
  - `Ink Slate` (`#2D3139`): Used for continuous long-form body text to maximize legibility.
  - `Meta Muted Gray` (`#64748B`): Applied to datetimes, bylines, source attributions, and passive icons.
- **Structural Outlines (`#E2E8F0`):** Hairline borders delivering discrete surface separation across news cards and inputs without harsh visual weight.

## Typography

The typographic hierarchy establishes distinct roles across editorial presentation, narrative body reading, and system-level utility navigation.

### Editorial Display & Headlines (`Newsreader`)
Designed with optical sizing parameters, `Newsreader` delivers the authority of high-end print editorial design. Headlines use medium weights (`600`) with tight line height ratios and negative letter spacing to create cohesive, impactful title blocks that guide the eye without crowding thumbnail imagery.

### Reading Body (`Inter`)
For extended articles, summary cards, and user commentary, `Inter` guarantees effortless legibility across diverse Android screens. A generous `28px` line-height on `17px` body type supports optical cadence and rapid skimming.

### Labels & UI Metadata (`Plus Jakarta Sans`)
Clean, contemporary, and geometric, `Plus Jakarta Sans` handles operational labels, dates, publication tags, button triggers, and tab headers, preventing visual competition with serif titles.

## Layout & Spacing

The system utilizes an adaptive 8pt layout rhythm, tailored for vertical handheld scrolling and multi-pane tablet presentation.

### Layout Philosophy
- **Mobile Handheld (360dp - 599dp):** Single-column fluid feed with `1.25rem` (`20px`) canvas margins. Article cards follow an asymmetric layout: 112px fixed-width rounded thumbnail coupled with a fluid flex column for serif headlines, snippet lines, and timestamp meta.
- **Tablet / Large Screen (600dp+):** Dual-column reading structure with a persistent 84dp navigation rail, a `2rem` outer gutter, and maximum article reading column constrained to `680px` for optimal typographic line lengths (55-75 characters per line).

### Spacing Cadence
- **`space-xs` (4px):** Micro gaps between inline icons and metadata text (e.g., trend icon to timestamp).
- **`space-sm` (8px):** Internal spacing between headline, excerpt text, and author chips.
- **`space-md` (16px):** Standard card padding, input internal padding, and feed vertical separation.
- **`space-lg` (24px):** Section transitions and dialog content blocks.
- **`space-xl` (32px):** Top-level header offsets and major view separations.

## Elevation & Depth

Visual depth is achieved through layered surface tiers, delicate boundary definition, and diffuse tinted ambient shadows instead of heavy directional drop-shadows.

### Surface Hierarchy & Elevation Tiers
- **Tier 0 (Base Canvas):** `#F8F9FA` - The primary reading background for root feeds and article scrolling surfaces.
- **Tier 1 (Surface Cards & Lists):** Pure `#FFFFFF` resting directly over canvas, framed by a soft `1px` border (`#E2E8F0`). Under elevation states, cards receive a soft ambient aura: `0 4px 20px -2px rgba(17, 20, 24, 0.04)`.
- **Tier 2 (Floating Action Buttons & Toolbars):** `#EEF2FF` or `#FFFFFF` containers elevated via `0 8px 24px -4px rgba(79, 70, 229, 0.16)`. The indigo tint gives the floating element intentional weight.
- **Tier 3 (Modals & Sheet Overlays):** `#FFFFFF` surfaces positioned above a frosted scrim (`rgba(17, 20, 24, 0.40)` with `backdrop-filter: blur(12px)`). Modals carry `0 20px 48px -8px rgba(17, 20, 24, 0.14)`.

### Border Discipline
All elevated cards, bottom sheets, and modal forms combine their ambient shadow with a high-definition `1px` solid border (`#E2E8F0` or `#EEF2FF` for active states), maintaining crisp edge geometry across OLED displays.

## Shapes

The design language applies geometric roundness to harmonize physical broadsheet layouts with modern Android corner radii.

### Shape Taxonomy
- **Article Thumbnails:** `16px` (`rounded-2xl`) corner rounding, preventing image corners from feeling sharp while preserving square aspect integrity.
- **Buttons & Action Pills:** Full pill contour (`9999px`) for system chips, bookmark triggers, and primary interactive buttons.
- **Input Fields:** `12px` (`rounded-xl`) soft container geometry with inset bottom accent lines for focused state clarity.
- **Modals & Elevated Sheets:** `24px` to `28px` (`rounded-3xl`), evoking a friendly, premium sheet overlay as demonstrated in account conversion dialogs.
- **Floating Action Buttons (FAB):** Material 3 rounded squircle with `20px` corner radius.

## Components

### 1. Article Feed Cards
- **Structure:** Two-column horizontal card layout. Left side anchors a 112×112px (or 96×96px) media thumbnail with `16px` corner radius and `object-fit: cover`. Right side contains the serif headline (`headline-md`), truncated 2-line body excerpt (`body-md`), and inline metadata row.
- **Metadata Row:** Includes trending or timestamp glyph (`14px`), followed by publication time in `label-sm` (`#64748B`), and an optional trailing bookmark pill button.
- **State:** On press, active background transitions smoothly to `#F1F5F9`.

### 2. Buttons
- **Primary Action:** Solid electric violet (`#4F46E5`) container with white (`#FFFFFF`) bold label, pill geometry (`9999px`), horizontal padding `24px`, height `48px`.
- **Secondary / Soft Action:** Lavender tint container (`#EEF2FF`) with indigo text (`#4F46E5`), zero outline, pill geometry.
- **Ghost / Text Button:** Transparent background, `Ink Obsidian` (`#111418`) or Indigo (`#4F46E5`) text, minimum tap footprint of 48×48dp for accessibility.

### 3. Floating Action Button (FAB)
- **Geometry:** 56×56dp rounded container (`20px` radius).
- **Styling:** Soft lavender tint (`#EEF2FF`) background carrying an electric indigo icon (`#4F46E5`, 24px stroke-width 2px).
- **Depth:** Ambient indigo-tinted shadow (`0 8px 24px -4px rgba(79, 70, 229, 0.20)`).

### 4. Dialogs & Account Sheets
- **Structure:** Floating central sheet with `28px` corner radius, `24px` internal padding, and `#FFFFFF` background over a 12px blurred dark backdrop scrim.
- **Header:** Prominent serif title (`Newsreader`, 22px, `Ink Obsidian`), followed by descriptive supporting text in `Inter` (`14px`, `#64748B`).
- **Input Integration:** Floating labels or clean underline/box inputs with active indigo borders (`#4F46E5`).
- **Actions:** Dual horizontal alignment with text cancel button on the left and full-pill confirm button on the right.

### 5. Chips & Pills
- **Topic Filter Chips:** Pill geometry (`height: 32px`, `padding: 0 14px`). Inactive state uses white background with `#E2E8F0` border and `#2D3139` text. Active state uses `#4F46E5` background with pure white text.
- **Metric Badges:** Height 22px, micro pill container (`#EEF2FF`), text in `#4F46E5` (`label-sm`), used for reading time and live updates.

### 6. Input Fields
- **Container:** `#FFFFFF` background with subtle 1px border (`#E2E8F0`), rounding `12px`, height `52px`.
- **Focus State:** 2px solid `#4F46E5` outline with subtle outer glow (`0 0 0 3px rgba(79, 70, 229, 0.12)`).
- **Text:** Input values render in `Inter` (`15px`, `#111418`); placeholder renders in `#94A3B8`.
