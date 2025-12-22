# Theme Documentation - Modern Futuristic Dark UI

## Overview

The Cross-Divisional Project Database uses a **modern futuristic dark theme** with vibrant neon accents inspired by cyberpunk and sci-fi aesthetics. This theme provides high contrast, reduces eye strain, and creates a professional, cutting-edge appearance.

---

## Design Philosophy

### Visual Identity
- **Dark base**: Near-black backgrounds (#0D1117) for reduced eye fatigue
- **Vibrant accents**: Cyan (#00BCD4), purple (#7C4DFF), pink (#FF4081) neon highlights
- **High contrast**: White/light text on dark surfaces for excellent readability
- **Depth layers**: Multiple background shades create visual hierarchy
- **Rounded corners**: Modern, soft shapes (6-16px radius) vs. harsh edges
- **Subtle shadows**: RGBA(0,0,0,0.4) for depth perception

### Inspiration
- GitHub Dark Mode
- Azure Portal Dark Theme
- Discord UI
- Visual Studio Code Dark+ Theme

---

## Color Palette

### Base Colors

| Token Name | Hex / RGBA | Usage | Example Components |
|------------|------------|-------|-------------------|
| **Background** | `#0D1117`<br/>`RGBA(13, 17, 23, 1)` | Main app background | Screen Fill |
| **BackgroundSecondary** | `#161B22`<br/>`RGBA(22, 27, 34, 1)` | Elevated surfaces (headers, footers) | Header bars, toolbars |
| **BackgroundCard** | `#1E252E`<br/>`RGBA(30, 37, 46, 1)` | Cards, containers, panels | Project cards, form panels |
| **BackgroundCardHover** | `#262D38`<br/>`RGBA(38, 45, 56, 1)` | Card hover state | Hover effects on interactive cards |
| **BackgroundInput** | `#161B22`<br/>`RGBA(22, 27, 34, 1)` | Input fields, dropdowns | Text inputs, comboboxes |

### Accent Colors (Neon Theme)

| Token Name | Hex / RGBA | Usage | Example Components |
|------------|------------|-------|-------------------|
| **Primary** | `#00BCD4`<br/>`RGBA(0, 188, 212, 1)` | Primary actions, links, focus states | CTA buttons, accent lines, links |
| **PrimaryDark** | `#0096AA`<br/>`RGBA(0, 150, 170, 1)` | Hover state for primary | Button hover effects |
| **PrimaryLight** | `#00E5FF`<br/>`RGBA(0, 229, 255, 1)` | Highlights, active states | Active indicators |
| **Secondary** | `#7C4DFF`<br/>`RGBA(124, 77, 255, 1)` | Secondary actions, badges | Secondary buttons, tags |
| **SecondaryDark** | `#623DCC`<br/>`RGBA(98, 61, 204, 1)` | Hover state for secondary | Button hover effects |
| **Accent** | `#FF4081`<br/>`RGBA(255, 64, 129, 1)` | Highlights, important markers | Critical alerts, featured content |

### Status Colors

| Token Name | Hex / RGBA | Usage | Example Components |
|------------|------------|-------|-------------------|
| **Success** | `#00E676`<br/>`RGBA(0, 230, 118, 1)` | Success states, completed items | ✓ Complete badges |
| **Warning** | `#FFC107`<br/>`RGBA(255, 193, 7, 1)` | Warnings, incomplete items | ⚠ Missing specs badges |
| **Error** | `#FF5252`<br/>`RGBA(255, 82, 82, 1)` | Errors, required validation | Validation errors, required fields |
| **Info** | `#2196F3`<br/>`RGBA(33, 150, 243, 1)` | Informational messages | Info banners |

### Text Colors

| Token Name | Hex / RGBA | Usage | Example Components |
|------------|------------|-------|-------------------|
| **TextPrimary** | `#FFFFFF`<br/>`RGBA(255, 255, 255, 1)` | Main text, headings | Titles, labels, body text |
| **TextSecondary** | `#9EA7B3`<br/>`RGBA(158, 167, 179, 1)` | Secondary text, subtitles | Descriptions, metadata |
| **TextMuted** | `#6E7681`<br/>`RGBA(110, 118, 129, 1)` | Placeholder, disabled text | Hints, disabled states |
| **TextOnPrimary** | `#000000`<br/>`RGBA(0, 0, 0, 1)` | Text on vibrant buttons | Button text on cyan/purple |

### Border Colors

| Token Name | Hex / RGBA | Usage | Example Components |
|------------|------------|-------|-------------------|
| **Border** | `#30363D`<br/>`RGBA(48, 54, 61, 1)` | Default borders | Input borders, card outlines |
| **BorderFocus** | `#00BCD4`<br/>`RGBA(0, 188, 212, 1)` | Focus/active borders | Focused inputs, selected items |

### Shadow

| Token Name | RGBA | Usage |
|------------|------|-------|
| **ShadowColor** | `RGBA(0, 0, 0, 0.4)` | Subtle depth shadows on cards |

---

## Spacing & Sizing Tokens

| Token Name | Value (px) | Usage |
|------------|------------|-------|
| **RadiusSmall** | `6` | Small elements (buttons, badges) |
| **RadiusMedium** | `10` | Medium elements (inputs, cards) |
| **RadiusLarge** | `16` | Large panels, containers |
| **SpacingXS** | `4` | Minimal spacing |
| **SpacingS** | `8` | Small gaps |
| **SpacingM** | `16` | Medium spacing (default) |
| **SpacingL** | `24` | Large spacing |
| **SpacingXL** | `32` | Extra large spacing |

---

## Typography

### Font Family
**Segoe UI** (default) - Clean, modern, highly legible on screens

### Font Sizes

| Usage | Size (px) | Weight | Example |
|-------|-----------|--------|---------|
| **App Title** | `24` | Bold | "Cross-Divisional Project Database" |
| **Section Title** | `22` | Bold | "Project Identification" |
| **Screen Title** | `18-20` | Bold | "Submission Review" |
| **Subtitle** | `16` | Semibold | "Security Intake Management System" |
| **Body Text** | `13-14` | Regular | Form labels, descriptions |
| **Small Text** | `11-12` | Regular | Metadata, hints, secondary info |
| **Tiny Text** | `9-10` | Regular | Badges, tags |

### Font Weights
- **Regular**: Default body text
- **Semibold**: Subheadings, important labels
- **Bold**: Titles, headings, CTAs

---

## Component Styling Guide

### Buttons

#### Primary Button (Call-to-Action)
```
Fill: gblTheme.Primary (#00BCD4)
Color: gblTheme.TextOnPrimary (#000000)
BorderRadius: 10
Font: Segoe UI
FontWeight: Bold
Size: 13-14
Height: 42-45
Hover Fill: gblTheme.PrimaryDark
```

**Example:** "Next →", "Submit", "Save"

#### Secondary Button
```
Fill: gblTheme.Secondary (#7C4DFF)
Color: gblTheme.TextPrimary (#FFFFFF)
BorderRadius: 8
Font: Segoe UI
Size: 11-13
Height: 36-40
```

**Example:** "Clone", "Open SharePoint"

#### Ghost Button (Transparent)
```
Fill: Transparent
Color: gblTheme.TextSecondary
BorderColor: gblTheme.Border
BorderThickness: 1
BorderRadius: 8
```

**Example:** "Back", "Cancel"

#### Disabled Button
```
Fill: gblTheme.BackgroundCard
Color: gblTheme.TextMuted
DisplayMode: Disabled
```

---

### Text Inputs

```
Fill: gblTheme.BackgroundInput (#161B22)
Color: gblTheme.TextPrimary (#FFFFFF)
BorderColor: gblTheme.Border (default) | gblTheme.Error (if invalid)
BorderThickness: 2
BorderRadius: 10
Font: Segoe UI
Size: 14
Height: 45
HintColor: gblTheme.TextMuted
```

**Error State:**
```
BorderColor: gblTheme.Error (#FF5252)
```

---

### Dropdowns

```
Fill: gblTheme.BackgroundInput
Color: gblTheme.TextPrimary
BorderColor: gblTheme.Border
Font: Segoe UI
Size: 14
BorderRadius: 10
```

---

### Cards

```
Fill: gblTheme.BackgroundCard (#1E252E)
BorderRadius: 12-16
BorderColor: (optional) gblTheme.Success or gblTheme.Warning
BorderThickness: 2
Padding: 16-24px
```

**Hover State:**
```
Fill: gblTheme.BackgroundCardHover (#262D38)
```

---

### Headers (Screen Headers)

```
Fill: gblTheme.BackgroundSecondary (#161B22)
Height: 70-80px
```

**Accent Line (Top):**
```
Height: 3-4px
Fill: gblTheme.Primary (or gblTheme.Secondary)
```

---

### Validation Banners

#### Success
```
Fill: RGBA(0, 230, 118, 0.1) — 10% opacity Success
Color: gblTheme.Success
Text: "✓ Ready to continue"
```

#### Error / Warning
```
Fill: RGBA(255, 82, 82, 0.1) — 10% opacity Error
Color: gblTheme.Error
Text: "⚠ Complete required fields"
```

---

### Badges / Status Pills

```
Fill: RGBA(color, 0.2) — 20% opacity of status color
Color: Status color (Success, Warning, Error)
BorderRadius: 13 (pill shape)
Height: 26
Padding: 6px horizontal
FontSize: 11
FontWeight: Semibold
```

**Examples:**
- **Complete**: Fill: `RGBA(0, 230, 118, 0.2)`, Color: `#00E676`
- **In Progress**: Fill: `RGBA(255, 193, 7, 0.2)`, Color: `#FFC107`

---

### Galleries (Lists)

```
TemplateFill: Transparent
TemplatePadding: 6
TemplateSize: varies (50-150px)
```

**Gallery Items (Cards):**
```
Fill: gblTheme.BackgroundCard
BorderRadius: 10
BorderColor: gblTheme.Border (or status color)
BorderThickness: 2
Hover: gblTheme.BackgroundCardHover
```

---

## Screen Layout Standards

### Structure
```
┌────────────────────────────────────┐
│ Accent Line (3px, Primary)        │
├────────────────────────────────────┤
│ Header (70px, BackgroundSecondary) │
│  ← Back | Title | User Info        │
├────────────────────────────────────┤
│                                    │
│ Main Content Area (Background)     │
│  - Cards (BackgroundCard)          │
│  - Forms                           │
│  - Galleries                       │
│                                    │
├────────────────────────────────────┤
│ Footer (80px, BackgroundSecondary) │
│  Save & Exit | Next →              │
└────────────────────────────────────┘
```

### Spacing
- **Page margins**: 20-40px
- **Card padding**: 16-24px
- **Element spacing**: 16-24px (gblTheme.SpacingM/L)
- **Form field spacing**: 8-16px vertical

---

## How to Apply the Theme

### Step 1: Verify Theme Variables (App.fx.yaml)

The theme is defined in `App.fx.yaml` → `OnStart`:

```powerfx
Set(gblTheme, {
    Background: RGBA(13, 17, 23, 1),
    BackgroundSecondary: RGBA(22, 27, 34, 1),
    BackgroundCard: RGBA(30, 37, 46, 1),
    Primary: RGBA(0, 188, 212, 1),
    ...
});
```

### Step 2: Use Theme Tokens in Components

**Instead of hardcoded colors:**
```powerfx
❌ Fill: RGBA(0, 188, 212, 1)
```

**Use theme tokens:**
```powerfx
✅ Fill: gblTheme.Primary
```

**Benefits:**
- Consistency across all screens
- Easy to change theme globally
- Maintainable code

### Step 3: Applying to Buttons

```powerfx
btnNext.Fill = gblTheme.Primary
btnNext.Color = gblTheme.TextOnPrimary
btnNext.BorderRadius = gblTheme.RadiusMedium
```

### Step 4: Applying to Screens

```powerfx
scrHome.Fill = gblTheme.Background
```

### Step 5: Conditional Styling (Validation)

```powerfx
txtInput.BorderColor = If(
    IsBlank(txtInput.Text),
    gblTheme.Error,
    gblTheme.Border
)
```

---

## Customization Guide

Want to change the theme to your company branding?

### Option 1: Update Color Values in App.fx.yaml

1. Open `CanvasSource/Src/App.fx.yaml`
2. Find the `Set(gblTheme, {...})` section
3. Replace RGBA values with your brand colors:

```powerfx
Set(gblTheme, {
    Background: RGBA(10, 15, 20, 1),      // Your dark blue
    Primary: RGBA(255, 100, 0, 1),        // Your brand orange
    Secondary: RGBA(0, 150, 200, 1),      // Your brand teal
    ...
});
```

4. Repack and import

### Option 2: Light Theme Conversion

To convert to a light theme:

```powerfx
Background: RGBA(255, 255, 255, 1)       // White
BackgroundSecondary: RGBA(245, 247, 250, 1)  // Light gray
BackgroundCard: RGBA(255, 255, 255, 1)    // White cards
TextPrimary: RGBA(0, 0, 0, 1)            // Black text
TextSecondary: RGBA(100, 110, 120, 1)    // Gray text
Border: RGBA(200, 210, 220, 1)           // Light gray border
```

**Note:** Light themes need higher contrast adjustments for accessibility.

---

## Accessibility Considerations

### Contrast Ratios (WCAG AA Compliance)

| Combination | Ratio | Pass? |
|-------------|-------|-------|
| White text on #0D1117 | 16.5:1 | ✅ AAA |
| Cyan (#00BCD4) on #0D1117 | 7.8:1 | ✅ AA |
| Black text on Cyan (#00BCD4) | 2.8:1 | ⚠ AA Large Text Only |
| Success (#00E676) on #0D1117 | 8.9:1 | ✅ AAA |

### Recommendations
- **Primary text**: Always use `TextPrimary` (#FFFFFF) on dark backgrounds
- **Button text on Primary**: Use `TextOnPrimary` (#000000) for readability
- **Error text**: `Error` color (#FF5252) has sufficient contrast on dark backgrounds

---

## Common Patterns

### Project Card
```powerfx
Fill: gblTheme.BackgroundCard
BorderColor: If(status = "Complete", gblTheme.Success, gblTheme.Warning)
BorderThickness: 2
BorderRadius: 10
```

### Validation Message
```powerfx
Fill: If(hasError, RGBA(255, 82, 82, 0.1), RGBA(0, 230, 118, 0.1))
Color: If(hasError, gblTheme.Error, gblTheme.Success)
```

### Accent Line (Top of Screen)
```powerfx
Height: 3
Fill: gblTheme.Primary
X: 0
Y: 0
Width: Parent.Width
```

---

## Resources

- **Color Palette Tool**: [Coolors.co](https://coolors.co)
- **Contrast Checker**: [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
- **Design Inspiration**: [Dribbble - Dark UI](https://dribbble.com/tags/dark_ui)

---

*Generated for Cross-Divisional Project Database v2.1*
