# Design System: Cyber Night

## Overview
"Cyber Night" is the suggested visual theme for Symmetry (InfoVeraz). It aims for a premium, high-tech aesthetic inspired by cyberpunk and futuristic HUDs.

**Key Principles:**
- **High Contrast**: Pure blacks vs. vibrant neon accents.
- **Glassmorphism**: Translucent surfaces with blur effects.
- **Glow & Light**: Subtle glows around interactive elements.
- **Modern Typography**: clean, geometric sans-serif (Muli).

---

## 1. Color Palette

| Category | Color | HEX | Usage |
|----------|-------|-----|-------|
| **Background** | Deep Space | `#05050A` | Main scaffold background |
| **Surface** | Slate Blue | `#0E0E1A` | Cards, bars, and overlays |
| **Surface Light** | Midnight | `#1A1A2E` | Secondary surfaces, input fields |
| **Primary** | Neon Cyan | `#00E5FF` | Primary actions, icons, active states |
| **Accent** | Neon Purple | `#D600FF` | Decorative elements, highlights |
| **Highlight** | Cyber Pink | `#FF006E` | Errors, urgent alerts |
| **Success** | Emerald | `#00FF9C` | Success states |

### Gradients
- **Cyber Gradient**: `LinearGradient(primary, accent)` starting from Top-Left to Bottom-Right.

---

## 2. Typography
- **Primary Font**: Muli (Geometric Sans)
- **Headlines**: Bold, white (`#FFFFFF`), letter-spacing 0.5.
- **Body**: Light/Medium weight, off-white (`#E2E2E2`) for readability.
- **Muted**: Grey-Blue (`#71718F`) for metadata and captions.

---

## 3. UI Components

### Cards & Surfaces
- **Border**: 1px solid Primary with 0.1 opacity.
- **Radius**: 16px.
- **Elevation**: 4.
- **Glassmorphism**: Use `BackdropFilter` with `ImageFilter.blur(sigmaX: 10, sigmaY: 10)`.

### Buttons
- **Primary**: Solid Neon Cyan with black text.
- **Glow**: Subtle shadow with `AppColors.primaryGlow`.

---

## 4. Owl Assistant (HUD Feel)
The Owl AI Assistant should feel like a holographic HUD:
- Use translucent backgrounds.
- Add animated "scanline" or "flicker" effects where appropriate.
- Maintain floating positioning.
