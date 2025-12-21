# Cross-Divisional Project Database - Theme Documentation

## Futuristic Dark Theme Specification

This document details the global UI theme applied across all screens for a consistent, modern, futuristic dark aesthetic.

---

## Color Palette

### Base Colors (Backgrounds)

| Token | RGBA | Hex | Usage |
|-------|------|-----|-------|
| `Background` | `RGBA(13, 17, 23, 1)` | `#0D1117` | Primary screen background |
| `BackgroundSecondary` | `RGBA(22, 27, 34, 1)` | `#161B22` | Headers, footers, elevated surfaces |
| `BackgroundCard` | `RGBA(30, 37, 46, 1)` | `#1E252E` | Cards, containers, panels |
| `BackgroundCardHover` | `RGBA(38, 45, 56, 1)` | `#262D38` | Hover state for interactive cards |
| `BackgroundInput` | `RGBA(22, 27, 34, 1)` | `#161B22` | Input fields, dropdowns |

### Accent Colors (Neon Highlights)

| Token | RGBA | Hex | Usage |
|-------|------|-----|-------|
| `Primary` | `RGBA(0, 188, 212, 1)` | `#00BCD4` | CTAs, links, primary actions (cyan neon) |
| `PrimaryDark` | `RGBA(0, 150, 170, 1)` | `#0096AA` | Pressed/active primary |
| `PrimaryLight` | `RGBA(0, 229, 255, 1)` | `#00E5FF` | Glow effects |
| `Secondary` | `RGBA(124, 77, 255, 1)` | `#7C4DFF` | Secondary accents (purple neon) |
| `SecondaryDark` | `RGBA(98, 61, 204, 1)` | `#623DCC` | Pressed/active secondary |
| `Accent` | `RGBA(255, 64, 129, 1)` | `#FF4081` | Highlights, badges (pink neon) |

### Status Colors

| Token | RGBA | Hex | Usage |
|-------|------|-----|-------|
| `Success` | `RGBA(0, 230, 118, 1)` | `#00E676` | Complete, success states (green neon) |
| `Warning` | `RGBA(255, 193, 7, 1)` | `#FFC107` | Drafts, cautions (amber) |
| `Error` | `RGBA(255, 82, 82, 1)` | `#FF5252` | Errors, validation failures (red neon) |
| `Info` | `RGBA(33, 150, 243, 1)` | `#2196F3` | Informational toasts, tips |

### Text Colors

| Token | RGBA | Hex | Usage |
|-------|------|-----|-------|
| `TextPrimary` | `RGBA(255, 255, 255, 1)` | `#FFFFFF` | Main headings, body text |
| `TextSecondary` | `RGBA(158, 167, 179, 1)` | `#9EA7B3` | Labels, subtitles, hints |
| `TextMuted` | `RGBA(110, 118, 129, 1)` | `#6E7681` | Disabled text, placeholders |
| `TextOnPrimary` | `RGBA(0, 0, 0, 1)` | `#000000` | Text on Primary-colored buttons |

### Border Colors

| Token | RGBA | Hex | Usage |
|-------|------|-----|-------|
| `Border` | `RGBA(48, 54, 61, 1)` | `#30363D` | Default card/input borders |
| `BorderFocus` | `RGBA(0, 188, 212, 1)` | `#00BCD4` | Focus states |

### Effects

| Token | RGBA | Usage |
|-------|------|-------|
| `ShadowColor` | `RGBA(0, 0, 0, 0.4)` | Drop shadows |

---

## Spacing & Sizing Tokens

| Token | Value | Usage |
|-------|-------|-------|
| `RadiusSmall` | `6px` | Buttons, small cards |
| `RadiusMedium` | `10px` | Dropdowns, input fields |
| `RadiusLarge` | `16px` | Main panels, dialog boxes |
| `SpacingXS` | `4px` | Tight spacing |
| `SpacingS` | `8px` | Between related elements |
| `SpacingM` | `16px` | Standard padding |
| `SpacingL` | `24px` | Section spacing |
| `SpacingXL` | `32px` | Major section gaps |

---

## Component Patterns

### Cards

```yaml
rectCard As rectangle:
    Fill: =gblTheme.BackgroundCard
    BorderColor: =gblTheme.Border
    BorderThickness: =1
    BorderRadius: =12  # RadiusLarge
```

### Primary Button

```yaml
btnPrimary As button:
    Fill: =gblTheme.Primary
    Color: =gblTheme.TextOnPrimary
    BorderRadius: =10
    FontWeight: =FontWeight.Bold
```

### Secondary/Ghost Button

```yaml
btnSecondary As button:
    Fill: =gblTheme.BackgroundCard
    Color: =gblTheme.TextPrimary
    BorderColor: =gblTheme.Border
    BorderThickness: =1
    BorderRadius: =10
```

### Input Field

```yaml
txtInput As textInput:
    Fill: =gblTheme.BackgroundInput
    Color: =gblTheme.TextPrimary
    BorderColor: =gblTheme.Border
    BorderRadius: =10
    # On focus: BorderColor: =gblTheme.BorderFocus
```

### Status Badge

```yaml
rectBadge As rectangle:
    Fill: =Switch(Status, 
        "Complete", RGBA(0, 230, 118, 0.15),
        "In Progress", RGBA(255, 193, 7, 0.15),
        RGBA(110, 118, 129, 0.15)
    )
    BorderRadius: =13  # Pill shape
```

---

## Screen Layout Structure

Every screen follows this structure:

```
┌─────────────────────────────────────────────┐
│ ▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔ │ ← Accent line (3px, Primary)
│ Header (BackgroundSecondary, 70px)          │
│  • Title (TextPrimary, Bold)                │
│  • Subtitle (TextSecondary)                 │
│  • Action buttons (right-aligned)           │
├─────────────────────────────────────────────┤
│                                             │
│  Content Area (Background)                  │
│                                             │
│  ┌───────────────────────────────────────┐  │
│  │ Card (BackgroundCard, BorderRadius)   │  │
│  │                                       │  │
│  └───────────────────────────────────────┘  │
│                                             │
├─────────────────────────────────────────────┤
│ Footer (BackgroundSecondary, 60-80px)       │
│  • Navigation buttons                       │
└─────────────────────────────────────────────┘
```

---

## Step Indicator Pattern (Wizard)

```yaml
lblStepTitle As label:
    Text: ="Project " & gblCurrentProjectIndex & " — Step 1 of 4"
    Color: =gblTheme.TextPrimary
    FontWeight: =FontWeight.Bold
    
lblStepSubtitle As label:
    Text: ="Project Basics"
    Color: =gblTheme.Primary  # Cyan accent
```

---

## Applying the Theme

All theme values are accessed via the global `gblTheme` record, initialized in `App.OnStart`:

```powerapps
// Usage in any control
Fill: =gblTheme.BackgroundCard
Color: =gblTheme.TextPrimary
BorderColor: =gblTheme.Border
```

---

## Visual Examples

### Home Screen
- Dark `#0D1117` background
- Cyan `#00BCD4` CTA buttons
- Purple `#7C4DFF` admin button
- Amber `#FFC107` draft warning card

### Wizard Steps
- Consistent header with step indicator
- Rounded cards for form sections
- Cyan accent line at top (3px)
- Validation feedback in red/green

### Project Cards
- Green border = Complete
- Amber border = In Progress
- Red text = Missing required fields

---

*Theme version: 2.1 | Dark Futuristic Neon*
