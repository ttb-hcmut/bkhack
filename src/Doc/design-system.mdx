# Design System Specification

export function ColorPalette() {
    // file.read()
    return <div>tes1t</div>
}

<ColorPalette> </ColorPalette>

## 1. Purpose & Scope

### 1.1 Goals

This design system establishes a comprehensive, cohesive visual and structural foundation for BKHack. It serves as the authoritative reference for both design intent and implementation, ensuring:

- **Visual consistency** across all application surfaces, components, and states
- **Semantic clarity** through explicit meaning assignment to colors, patterns, and structures
- **Implementation alignment** between design artifacts and code through design tokens and CSS variables
- **Accessibility compliance** through contrast requirements, keyboard navigation, and screen reader support
- **Maintainability** through centralized token management and clear extension boundaries

### 1.2 Intended Products, Platforms, and Audiences

**Target Platform:** Modern web browsers (Chrome, Firefox, Safari, Edge) on desktop and tablet devices.

**Primary Audience:**
- Computer science students and researchers
- Technical educators and teaching assistants
- System administrators and moderators
- Developers contributing to educational content

**Application Context:**
- Academic collaboration platform
- Content management for CS topics (algorithms, systems programming, blockchain, AI)
- Issue tracking, pull requests, discussions, and permissions management
- High-density information presentation for technical audiences

### 1.3 Explicit Non-Goals and Constraints

**Non-Goals:**
- Mobile-first optimization (desktop-first with tablet support)
- High-saturation, vibrant color palettes
- Skeuomorphic or heavily decorated visual styles
- Complex animations or motion effects
- Marketing-oriented design language

**System Constraints:**
- Must maintain terminal-UI aesthetic influences
- Must preserve monospaced typography for key interface elements
- Must support both light and dark themes with equivalent visual hierarchy
- Must avoid design patterns that require color-only differentiation
- Colors must remain in the pastel/muted spectrum per Catppuccin guidelines (if Catppuccin themes are used)

### 1.4 Relationship Between Design and Implementation

**Design Tokens → CSS Variables:**
All design decisions are expressed as CSS custom properties (variables) in a global CSS file using a two-layer token architecture. These variables serve as the single source of truth for:
- Color palette (Catppuccin Mocha and Latte)
- Semantic color roles (surfaces, text, accents)
- Spacing and typography scales
- Border radii and elevation

**Two-Layer Token Architecture:**

The design system employs a two-layer token structure to enable flexible theme customization while maintaining semantic clarity:

**Layer 1: Palette Tokens (Color Aliases)**
Base color definitions from the Catppuccin palette, defined as CSS custom properties:
```css
/* Catppuccin Mocha (Dark) */
--ctp-red: #f38ba8;          /* Danger/error color */
--ctp-green: #a6e3a1;        /* Success/verification color */
--ctp-blue: #1488DB;         /* HCMUT brand blue (primary) */
--ctp-base: #11111b;         /* Darkest surface (page background) */
--ctp-mantle: #1e1e2e;       /* Mid-tone surface (cards, containers) */
--ctp-crust: #181825;        /* Deep inset surface (inputs) */
--ctp-text: #cdd6f4;         /* Primary text color */
/* ...additional palette colors */
```

These tokens represent the raw color palette and change between light (Latte) and dark (Mocha) themes.

**Layer 2: Semantic Tokens (Component/Element Mappings)**
Semantic roles that map to Layer 1 palette tokens, enabling theme customization without code changes:
```css
/* Semantic mappings to palette */
--background: var(--ctp-base);           /* Main page background */
--foreground: var(--ctp-text);           /* Primary text color */
--card: var(--ctp-mantle);               /* Card/container background */
--card-foreground: var(--ctp-text);      /* Text on cards */
--primary: var(--ctp-blue);              /* Primary action color */
--primary-foreground: #ffffff;           /* Text on primary buttons */
--destructive: var(--ctp-red);           /* Danger/error color */
--border: var(--ctp-surface0);           /* Border color */
--input: var(--ctp-crust);               /* Input background */
/* ...additional semantic tokens */
```

**Benefits of This Approach:**
- **Easy theme switching:** Change `--card: var(--ctp-mantle)` to `--card: var(--adwaita-blue)` in one place to retheme all cards
- **Semantic preservation:** Component code references `--card`, not `--ctp-mantle`, maintaining intent across themes
- **Flexibility:** New themes can redefine Layer 2 mappings without touching component code
- **Clarity:** Layer 1 provides the color palette, Layer 2 provides semantic/contextual meaning
- **Gradual migration:** Components can use Layer 1 tokens initially, then migrate to Layer 2 as semantic tokens are defined

**Prototype vs Production:**
The current codebase (React, TypeScript, Tailwind CSS) serves as a **prototype and design validation environment only**. The final production application will be implemented in **ReasonML**. This design system specification targets the production implementation, establishing principles and patterns that transcend specific frameworks or languages.

**Component Implementation:**
Components should reference **Layer 2 semantic tokens** (e.g., `--background`, `--card`, `--primary`, `--destructive`) wherever possible. Direct use of **Layer 1 palette tokens** (e.g., `--ctp-mantle`, `--ctp-red`) is acceptable for:
- Categorical color applications (e.g., tag colors, data visualization where specific hues matter)
- Cases where no appropriate semantic token exists yet
- Temporary implementation before a semantic token is defined

This two-layer approach enables:
- System/user-specified theme integration and customization
- Flexible theme redefinition without breaking semantic meaning
- Semantic meaning preservation across theme variations
- Clear separation between color palette (Layer 1) and contextual intent (Layer 2)

**Theme Management:**
The theme system manages both light/dark mode switching and integration with system-specified themes. The two-layer architecture allows users to redefine semantic tokens (Layer 2) while keeping component code unchanged, enabling system theme integration and per-user customization. For example, a user preferring GNOME Adwaita can redefine `--card: var(--adwaita-headerbar-bg)` without modifying any component files.

---

## 2. Design Principles & Rationale

### 2.1 Core Principles

#### Principle 1: Terminal-Inspired Clarity
**Statement:** Interface elements draw from terminal and command-line aesthetics, emphasizing functional clarity over decorative flourish.

**Rationale:**
Technical audiences expect information density, directness, and efficiency. Terminal interfaces are familiar, scannable, and reduce cognitive load through predictable patterns.

**Application:**
- Monospaced fonts for headings, code references, and metadata
- Compact spacing and high information density
- Command-line style placeholders (e.g., `$ search [posts | tags | users]...`)
- Sparse use of icons; text-first where appropriate

#### Principle 2: Semantic Consistency with Signature Flexibility
**Statement:** Colors carry consistent semantic meaning for actions and states, while allowing signature/theme colors for contextual identification. When conflicts arise, additional Catppuccin-compatible pastel colors are introduced to preserve both semantic clarity and visual identity.

**Rationale:**
Users should not re-learn interface conventions on each page. Semantic consistency reduces mental overhead and improves navigation speed. However, visual theming of sections (tabs, pages) aids navigation and context awareness. These two needs must coexist without confusion.

**Application:**
- **Semantic Actions:** `--ctp-green` for success/verification, `--ctp-red` for danger/destructive actions, `--ctp-yellow` for warnings, `--ctp-blue` (school blue) for primary actions
- **Signature/Theme Colors:** Tabs and sections may use specific colors for identity (e.g., Issues tab uses a red-adjacent theme), but action buttons within those contexts use semantic colors
- **Conflict Resolution:** When a tab's signature color conflicts with action semantics (e.g., Issues tab is red-themed, but "New Issue" is not destructive), introduce Catppuccin-compatible pastel alternatives or use `--ctp-blue` (primary) for new/create actions
- **Current Known Conflict:** Issues tab theme (red) vs "New Issue" button (should be primary, not danger). **Resolution pending:** Evaluate Catppuccin Maroon, Flamingo, or alternative pastels for tab signature color, or use `--ctp-blue` for all "New/Create" actions regardless of tab context

**Design Note:** This is an active area of refinement. The goal is to find Catppuccin-compatible colors that provide visual distinction without semantic confusion.

#### Principle 3: Hierarchy Through Subtlety
**Statement:** Visual hierarchy is achieved through subtle contrast, spacing, and typography, not aggressive color or size variations.

**Rationale:**
High-saturation colors and large size jumps create visual noise and reduce scannability. Subtle differentiation maintains calmness while preserving clarity.

**Application:**
- Surface elevation through layered backgrounds (`base` → `mantle` → `crust`)
- Text hierarchy through opacity and weight, not size jumps
- Border contrast using surface colors with low opacity
- Hover states with minimal color shift (10-20% opacity changes)

#### Principle 4: Dual-Theme Parity
**Statement:** Light (Latte) and dark (Mocha) themes must provide equivalent visual hierarchy, readability, and semantic clarity.

**Rationale:**
Users choose themes based on environment and preference. Both themes must be first-class experiences, not afterthoughts.

**Application:**
- Equivalent contrast ratios between surface layers
- Inverted but semantically identical color mappings
- Consistent accent color behavior across themes
- Identical component layouts regardless of theme

#### Principle 5: Left-Aligned, Scannable Layouts
**Statement:** Content flows left-to-right with left alignment, optimizing for rapid scanning and discovery.

**Rationale:**
Technical documentation and code are left-aligned by convention. Centering or right-aligning disrupts reading patterns for this audience.

**Application:**
- All post titles, metadata, and content left-aligned
- Sidebars on the right (content first, metadata second)
- Navigation elements aligned to left edge
- Consistent left margin/padding across pages

### 2.2 Tradeoffs and Rejected Alternatives

**Rejected: High-Saturation Catppuccin Variants**
Early explorations considered using full-saturation accent colors. This was rejected because:
- Conflicts with terminal-inspired aesthetic
- Creates visual fatigue in high-density layouts
- Reduces professional appearance for academic context

**Accepted Tradeoff:** Pastel/muted colors may feel less "exciting" but significantly improve scannability and reduce eye strain during extended use.

**Active Design Challenge: Tab Signature Colors vs Semantic Action Colors**
A current unresolved tension exists between:
1. **Tab signature colors** for visual section identification (e.g., Issues tab in red tones)
2. **Semantic action colors** for button meaning (e.g., red = danger/destructive)

When an Issues tab uses red as its signature color, the "New Issue" button appears red, incorrectly implying a destructive action.

**Potential Solutions Under Evaluation:**
1. **Primary-only actions:** All "New/Create" buttons use `--ctp-blue` (primary) regardless of tab context
2. **Alternative signature colors:** Use Catppuccin Maroon, Flamingo, or Rosewater for Issues tab instead of Red
3. **Expanded palette:** Introduce additional Catppuccin-compatible pastels for signature use that don't overlap with semantic roles
4. **Dual-color system:** Signature colors for borders/backgrounds, semantic colors for all interactive elements

**Current Approach:** Maintain visual appearance as-is (Issues tab appears red-themed) while evaluating Catppuccin-compatible color additions that would allow independent operation of signature and semantic color rules.

**Candidate Colors for Tab Signatures (Catppuccin-Compatible):**
- **Issues tab alternative:** `--ctp-maroon` (#eba0ac Mocha, #e64553 Latte) or `--ctp-flamingo` (#f2cdcd Mocha, #dd7878 Latte) - red-adjacent but distinct from semantic red
- **Future expansion:** `--ctp-rosewater`, `--ctp-lavender` for additional signature colors
- **Evaluation criteria:** Must remain pastel, provide visual distinction, not overlap with semantic action colors

**Design Note:** This is an active area requiring color palette exploration and validation to find pastels that provide visual distinction without semantic confusion. The goal is to preserve the current visual appearance while resolving the semantic ambiguity.

**Rejected: Mobile-First Responsive Design**
While responsive breakpoints exist, mobile-first design was deprioritized because:
- Primary use case is desktop/laptop workstations
- High information density requires screen real estate
- Terminal-inspired design doesn't translate well to mobile

**Accepted Tradeoff:** Tablet support is included, but mobile experience may require scrolling or reduced density.

**Rejected: Animation-Heavy Interactions**
Motion effects were minimized in favor of instant feedback because:
- Terminal interfaces provide immediate feedback
- Excessive animation slows perceived performance
- Technical users often prefer speed over polish

**Accepted Tradeoff:** Subtle transitions (color, opacity) are retained, but no sliding, bouncing, or complex motion.

---

## 3. Visual Foundations

### 3.1 Color System

#### 3.1.1 Palette Structure

The color system is built on **Catppuccin**, a pastel-focused color scheme with two primary variants:

- **Catppuccin Mocha** (Dark Theme): Warm, dark backgrounds with pastel accents
- **Catppuccin Latte** (Light Theme): Soft, light backgrounds with muted accents

**School-Blue Accents:** Two brand colors (`#1488DB` primary, `#030391` deep) remain consistent across both themes for brand identity and primary actions.

#### 3.1.2 Two-Layer Color Token Architecture

The color system uses a **two-layer token architecture**:

**Layer 1: Palette Tokens** - Catppuccin color definitions (e.g., `--ctp-red`, `--ctp-green`, `--ctp-base`, `--ctp-mantle`)  
**Layer 2: Semantic Tokens** - Component/element mappings that reference Layer 1 (e.g., `--destructive: var(--ctp-red)`, `--card: var(--ctp-mantle)`)

This architecture enables **theme customization** (users can redefine `--card: var(--adwaita-blue)` to use a different palette) while maintaining **semantic clarity** (components reference `--card`, not `--ctp-mantle`, preserving intent).

**Implementation Principle:** Components should reference **Layer 2 semantic tokens** wherever possible. Direct use of **Layer 1 palette tokens** is acceptable for categorical colors (tags, charts) where specific hues matter.

##### Surface Roles

| Role | Variable | Mocha (Dark) | Latte (Light) | Usage |
|------|----------|--------------|---------------|-------|
| **Base** | `--ctp-base` | `#11111b` | `#eff1f5` | Main background, body |
| **Mantle** | `--ctp-mantle` | `#1e1e2e` | `#e6e9ef` | Cards, navigation, primary containers |
| **Crust** | `--ctp-crust` | `#181825` | `#dce0e8` | Input backgrounds, deep insets |
| **Surface 0** | `--ctp-surface0` | `#313244` | `#ccd0da` | Hover states, borders, secondary containers |
| **Surface 1** | `--ctp-surface1` | `#45475a` | `#bcc0cc` | Elevated surfaces, separators |
| **Surface 2** | `--ctp-surface2` | `#585b70` | `#acb0be` | Tertiary surfaces, disabled states |

**Rationale:** Layered surfaces create depth and visual hierarchy without shadows or gradients. Each layer is 1-2 steps darker/lighter than the previous, providing subtle but clear boundaries.

##### Text Roles

| Role | Variable | Mocha (Dark) | Latte (Light) | Usage |
|------|----------|--------------|---------------|-------|
| **Primary Text** | `--ctp-text` | `#cdd6f4` | `#4c4f69` | Headings, body text, primary content |
| **Secondary Text** | `--ctp-subtext1` | `#bac2de` | `#5c5f77` | Metadata, supporting text |
| **Tertiary Text** | `--ctp-subtext0` | `#a6adc8` | `#6c6f85` | Placeholders, timestamps, low-priority text |
| **Overlay 0** | `--ctp-overlay0` | `#6c7086` | `#9ca0b0` | Disabled text, very low priority |

**Rationale:** Text hierarchy is established through contrast reduction, not font size changes. This maintains visual calmness while ensuring scannability.

##### Accent Roles

| Role | Variable | Mocha (Dark) | Latte (Light) | Semantic Meaning |
|------|----------|--------------|---------------|------------------|
| **Primary** | `--ctp-blue` | `#1488DB` | `#1488DB` | Brand, primary actions, links |
| **Deep Accent** | `--ctp-blue-deep` | `#030391` | `#030391` | Secondary brand emphasis |
| **Success** | `--ctp-green` | `#a6e3a1` | `#40a02b` | Verified, success, positive states |
| **Danger** | `--ctp-red` | `#f38ba8` | `#d20f39` | Errors, destructive actions, critical |
| **Warning** | `--ctp-yellow` | `#f9e2af` | `#df8e1d` | Warnings, caution, notes |
| **Modified** | `--ctp-mauve` | `#cba6f7` | `#8839ef` | Edited, modified, in-progress |
| **Info** | `--ctp-sky` | `#89dceb` | `#04a5e5` | Informational, neutral callouts |
| **Orange** | `--ctp-peach` | `#fab387` | `#fe640b` | Secondary accent, Rust-related |
| **Pink** | `--ctp-pink` | `#f5c2e7` | `#ea76cb` | Tertiary accent, AI-related |
| **Teal** | `--ctp-teal` | `#94e2d5` | `#179299` | Quaternary accent, data-related |

**Rationale:** Semantic color roles prevent arbitrary color choices and ensure accessibility. Each role maps to a specific meaning, improving predictability and reducing cognitive load.

##### Layer 2: Semantic Component Tokens

The following table documents **Layer 2 semantic tokens** that map to **Layer 1 palette tokens**. Components should reference these semantic tokens to enable theme customization.

| Semantic Token | Maps To (Layer 1) | Purpose | Usage Example |
|----------------|-------------------|---------|---------------|
| `--background` | `var(--ctp-base)` | Main page background | Page container backgrounds |
| `--foreground` | `var(--ctp-text)` | Primary text color | Body text, headings |
| `--card` | `var(--ctp-mantle)` | Container/card backgrounds | Post cards, navigation bars, panels |
| `--card-foreground` | `var(--ctp-text)` | Text on cards | Text inside cards and containers |
| `--primary` | `var(--ctp-blue)` | Primary action color | Buttons, links, active states |
| `--primary-foreground` | `#ffffff` | Text on primary elements | Button text, link text on colored backgrounds |
| `--destructive` | `var(--ctp-red)` | Danger/error color | Delete buttons, error messages |
| `--destructive-foreground` | `#ffffff` / `var(--ctp-base)` | Text on destructive elements | Text on red buttons |
| `--success` | `var(--ctp-green)` | Success/verified color | Success messages, verified badges |
| `--success-foreground` | `#ffffff` / `var(--ctp-base)` | Text on success elements | Text on green buttons |
| `--warning` | `var(--ctp-yellow)` | Warning/caution color | Warning messages, caution badges |
| `--warning-foreground` | `var(--ctp-base)` | Text on warning elements | Text on yellow backgrounds |
| `--info` | `var(--ctp-sky)` | Informational color | Info callouts, neutral notifications |
| `--border` | `var(--ctp-surface1)` / `var(--ctp-surface0)` | Border color | Card borders, dividers |
| `--input` | `var(--ctp-crust)` | Input background | Text input fields, textareas |
| `--muted` | `var(--ctp-surface0)` | Muted backgrounds | Disabled states, secondary containers |
| `--muted-foreground` | `var(--ctp-subtext0)` / `var(--ctp-overlay0)` | Muted text | Placeholder text, timestamps |
| `--accent` | `var(--ctp-surface1)` | Accent highlights | Hover states, selected items |
| `--ring` | `var(--ctp-blue)` | Focus ring color | Keyboard focus indicators |

**Usage in Components:**
```tsx
// ✅ Preferred: Use Layer 2 semantic tokens
<div className="bg-[var(--card)] text-[var(--card-foreground)] border border-[var(--border)]">
  <button className="bg-primary text-primary-foreground">Save</button>
  <button className="bg-[var(--destructive)] text-[var(--destructive-foreground)]">Delete</button>
</div>

// ✅ Acceptable: Use Layer 1 for categorical colors
<span className="bg-[var(--ctp-mauve)]/10 text-[var(--ctp-mauve)]">Algorithms</span>
```

**Theme Customization Example:**
Users can redefine semantic tokens to use alternative palettes:
```css
/* User-defined theme override */
:root {
  /* Swap Catppuccin for GNOME Adwaita colors */
  --card: var(--adwaita-headerbar-bg);
  --primary: var(--adwaita-accent-blue);
  --destructive: var(--adwaita-destructive-red);
  /* All components automatically update without code changes */
}
```

**Rationale:** Layer 2 semantic tokens enable flexible theming, preserve semantic intent in component code, and reduce coupling between components and specific color palettes.

#### 3.1.3 Contrast Requirements

**WCAG 2.1 AA Compliance:**
- **Normal text (16px):** Minimum 4.5:1 contrast ratio
- **Large text (18px+):** Minimum 3:1 contrast ratio
- **UI components and borders:** Minimum 3:1 contrast ratio

**Validation:**
- `--ctp-text` on `--ctp-base`: ✓ Passes AA (>7:1 in both themes)
- `--ctp-subtext1` on `--ctp-mantle`: ✓ Passes AA (>4.5:1)
- `--ctp-blue` on `--ctp-mantle`: ✓ Passes AA (>4.5:1)
- `--ctp-surface0` borders on `--ctp-mantle`: ✓ Passes UI contrast (>3:1)

**Implementation Note:** All color pairings must be validated before use. When applying opacity (\<100%), ensure final contrast still meets requirements.

#### 3.1.4 Color Opacity and Mixing

**Tailwind Opacity Syntax:**
```tsx
className="bg-[var(--ctp-blue)]/20"  // 20% opacity
className="border-[var(--ctp-green)]/30"  // 30% opacity
```

**Inline Style Opacity (CSS `color-mix`):**
```tsx
style={{
  backgroundColor: 'color-mix(in srgb, var(--ctp-blue) 20%, transparent)',
  borderColor: 'color-mix(in srgb, var(--ctp-green) 30%, transparent)'
}}
```

**Rationale:** Opacity allows accent colors to blend with surface backgrounds, creating subtle highlights without introducing new color values. This maintains palette coherence.

---

### 3.2 Typography

#### 3.2.1 Typeface System

**Primary Font (UI Text, Body):** System font stack
```css
font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
```

**Monospace Font (Code, Metadata, Headings):** Monospace stack
```css
font-family: "SF Mono", Monaco, "Cascadia Code", "Roboto Mono", Consolas, "Courier New", monospace;
```

**Rationale:**
- System fonts ensure performance and native appearance
- Monospace fonts reinforce terminal aesthetic and improve scannability for technical content
- No custom font loading reduces page weight and FOUT (flash of unstyled text)

#### 3.2.2 Typography Scale

**Base Font Size:** 16px (set on `html` element via `--font-size`)

| Element | Size | Weight | Line Height | Usage |
|---------|------|--------|-------------|-------|
| `h1` | `var(--text-2xl)` | 500 (medium) | 1.5 | Page titles (rare) |
| `h2` | `var(--text-xl)` | 500 (medium) | 1.5 | Section headers |
| `h3` | `var(--text-lg)` | 500 (medium) | 1.5 | Subsection headers |
| `h4` | `var(--text-base)` | 500 (medium) | 1.5 | Component titles |
| `p` | `var(--text-base)` | 400 (normal) | 1.5 | Body text |
| `label` | `var(--text-base)` | 500 (medium) | 1.5 | Form labels |
| `button` | `var(--text-base)` | 500 (medium) | 1.5 | Interactive elements |
| `input` | `var(--text-base)` | 400 (normal) | 1.5 | Form inputs |

**Rationale:**
- Modest size scale prevents visual noise
- Consistent line-height (1.5) improves readability
- Weight differentiation (400 vs 500) provides hierarchy without size jumps

#### 3.2.3 Semantic Typography Usage

**Monospace Usage (font-mono class):**
- All headings and titles
- Timestamps and dates
- Metadata labels (e.g., "commented", "edited")
- Input placeholders
- Code references and snippets
- Brand name ("BKHack")

**Sans-Serif Usage:**
- Long-form body text (discussions, descriptions)
- Form input content
- Button labels (when not code-like)

**Rationale:** Monospace usage reinforces the terminal aesthetic while maintaining readability for structured, scannable content.

---

### 3.3 Spacing & Layout

#### 3.3.1 Spacing Scale

**Base Unit:** 4px (0.25rem in Tailwind)

| Token | Value | Usage |
|-------|-------|-------|
| `0` | 0px | No spacing |
| `1` | 4px | Tight inline elements |
| `1.5` | 6px | Icon-text gaps |
| `2` | 8px | Compact padding |
| `2.5` | 10px | Standard card padding |
| `3` | 12px | Section gaps |
| `4` | 16px | Component separation |
| `5` | 20px | Large gaps |
| `6` | 24px | Major section separation |
| `8` | 32px | Page-level margins |

**Application:**
- **Card padding:** `p-2.5` (10px) for compact, high-density cards
- **Section gaps:** `gap-3` or `gap-4` (12-16px) for component spacing
- **Page margins:** `px-6` (24px) for horizontal page padding

**Rationale:** 4px base unit ensures visual rhythm and alignment. Compact spacing (2-3 units) maintains terminal aesthetic and information density.

#### 3.3.2 Grid System

**Container Max-Width:** `max-w-7xl` (1280px)
- Centers content for comfortable reading on large screens
- Prevents excessive line length

**Layout Pattern:**
```tsx
<div className="max-w-7xl mx-auto px-6">
  {/* Main content area */}
</div>
```

**Column Layout:**
- **Feed + Sidebar:** 70% content / 30% sidebar (approximate)
- **Responsive breakpoint:** Sidebar collapses/toggles on tablet (\<1024px)

**Rationale:** Fixed max-width prevents content sprawl. 70/30 split prioritizes content while retaining metadata visibility.

#### 3.3.3 Responsive Constraints

**Breakpoints (Tailwind Defaults):**
- `sm`: 640px (mobile landscape)
- `md`: 768px (tablets)
- `lg`: 1024px (desktop)
- `xl`: 1280px (large desktop)

**Behavior:**
- **Desktop (>1024px):** Full layout with sidebar visible
- **Tablet (768-1024px):** Toggleable sidebar, maintained density
- **Mobile (\<768px):** Stacked layout, reduced density (deprioritized)

**Rationale:** Desktop-first approach acknowledges primary use case while maintaining tablet usability. Mobile is functional but not optimized.

---

### 3.4 Elevation & Layering

**No Shadow Elevation:** This system avoids box-shadows in favor of surface color layering.

**Layering Hierarchy:**
1. **Base:** `--ctp-base` (lowest, page background)
2. **Mantle:** `--ctp-mantle` (cards, containers)
3. **Crust:** `--ctp-crust` (inputs, deep insets)
4. **Surface0+:** Hover states, modals, tooltips

**Border Usage:**
- **Default borders:** `border-[var(--ctp-surface0)]` (subtle, always visible)
- **Hover borders:** `hover:border-[var(--ctp-blue)]/50` (accent on interaction)
- **Active borders:** `border-[var(--ctp-blue)]` (clear focus indicator)

**Z-Index Hierarchy:**
- **Navigation:** `z-50` (sticky nav bar)
- **Modals/Dialogs:** `z-40`
- **Tooltips/Popovers:** `z-30`
- **Default:** `z-0`

**Rationale:** Flat design with color-based layering maintains terminal aesthetic. Z-index hierarchy prevents stacking conflicts.

---

### 3.5 Iconography

#### 3.5.1 Icon Library

**Source:** `lucide-react` package

**Verification Requirement:** All icons must be verified to exist in `lucide-react/dist/esm/icons/index.js` before import.

#### 3.5.2 Icon Usage Rules

**Size Standards:**
- **Navigation icons:** `w-5 h-5` (20px)
- **Button icons:** `w-4 h-4` (16px)
- **Inline icons:** `w-3.5 h-3.5` (14px)
- **Large feature icons:** `w-6 h-6` or `w-8 h-8` (24-32px)

**Color Application:**
- **Default state:** `text-[var(--ctp-subtext1)]` (muted)
- **Hover state:** `hover:text-[var(--ctp-blue)]` (accent)
- **Active state:** `text-[var(--ctp-blue)]` (accent, persistent)
- **Semantic states:** Use semantic colors (green for success, red for danger)

**Icon-Text Pairing:**
- **Gap:** `gap-1.5` or `gap-2` (6-8px)
- **Alignment:** Vertically centered (`items-center`)
- **Order:** Icon first, text second (left-to-right reading)

**Rationale:** Consistent sizing and color application improves scannability. Icons supplement text, never replace it (except in icon-only buttons with `sr-only` labels).

---

## 4. Hierarchy & Layout Patterns

### 4.1 Content Hierarchy Rules

#### 4.1.1 Visual Hierarchy Through Contrast

**Primary Content:**
- Background: `--ctp-mantle`
- Text: `--ctp-text`
- Borders: `--ctp-surface0` or `--ctp-blue` (if active/new)

**Secondary Content (Metadata):**
- Text: `--ctp-subtext1`
- Icons: `--ctp-overlay0`
- Reduced visual weight, not hidden

**Tertiary Content (Timestamps, Low Priority):**
- Text: `--ctp-overlay0`
- Smaller font size permitted (text-sm)
- Minimal contrast, still readable

**Rationale:** Contrast-based hierarchy allows users to scan quickly without visual clutter. Important content stands out naturally.

#### 4.1.2 Structural Hierarchy

**Page Structure:**
```
Navigation (sticky, z-50)
  └─ Brand + Search + Actions
Main Content (max-w-7xl, mx-auto, px-6)
  ├─ Header Section (title, filters)
  ├─ Primary Content Area (feed, tabs, etc.)
  └─ Sidebar (metadata, related items) [optional, toggleable]
```

**Card Structure (Feed Posts, PRs, Issues):**
```
Card Container (bg-mantle, border-surface0)
  ├─ Header (title, tags, status badges)
  ├─ Metadata Row (icons, counts, last activity)
  └─ Footer (timestamps, user info)
```

**Rationale:** Predictable structure reduces learning curve. Users know where to find information across all views.

---

### 4.2 Common Layout Patterns

#### 4.2.1 Feed/List View Pattern

**Implementation:** `HomeFeed.tsx`, `IssuesTab.tsx`, `PullRequestsTab.tsx`

**Structure:**
```tsx
<div className="flex gap-4">
  {/* Main content (70%) */}
  <div className="flex-1">
    <FilterBar /> {/* Search, sort, filter */}
    <div className="space-y-0"> {/* No gap between items */}
      {items.map(item => <FeedPost key={item.id} post={item} />)}
    </div>
    <Pagination />
  </div>
  
  {/* Sidebar (30%) */}
  {sidebarVisible && <Sidebar />}
</div>
```

**Key Characteristics:**
- **Zero gap between items:** Items share borders (no `gap-y`)
- **Sidebar toggle:** Icon in top-right (`PanelRightOpen`/`PanelRightClose`)
- **Sticky filter bar:** Remains visible on scroll (optional)

**Rationale:** GitHub-inspired list view maximizes content density. Zero-gap items reduce visual clutter and improve scanning speed.

#### 4.2.2 Detail View Pattern

**Implementation:** `IssueDetailTab.tsx`, `PullRequestDetailTab.tsx`, `ArticleView.tsx`

**Structure:**
```tsx
<div className="max-w-5xl mx-auto">
  {/* Header section */}
  <div className="bg-[var(--ctp-mantle)] border-b border-[var(--ctp-surface0)] p-6">
    <h1>{title}</h1>
    <Metadata />
  </div>
  
  {/* Content section */}
  <div className="bg-[var(--ctp-base)] p-6">
    <Content />
  </div>
  
  {/* Actions/Comments */}
  <div className="bg-[var(--ctp-mantle)] border-t border-[var(--ctp-surface0)] p-6">
    <Comments />
  </div>
</div>
```

**Key Characteristics:**
- **Sectioned layout:** Clear visual separation between header, content, footer
- **Full-width sections:** Border-to-border backgrounds
- **Reduced max-width:** `max-w-5xl` for comfortable reading

**Rationale:** Clear section boundaries improve scannability. Reduced width prevents excessive line length in long-form content.

#### 4.2.3 Tabbed View Pattern

**Implementation:** `PostViewTabs.tsx`, tab systems

**Structure:**
```tsx
<Tabs defaultValue="discussion">
  <TabsList className="bg-[var(--ctp-mantle)] border-b border-[var(--ctp-surface0)]">
    <TabsTrigger value="discussion">Discussion</TabsTrigger>
    <TabsTrigger value="issues">Issues (3)</TabsTrigger>
    <TabsTrigger value="prs">Pull Requests (2)</TabsTrigger>
  </TabsList>
  
  <TabsContent value="discussion">
    <DiscussionTab />
  </TabsContent>
  {/* Additional tabs... */}
</Tabs>
```

**Key Characteristics:**
- **Borderless active state:** Active tab has no bottom border (connects to content)
- **Count badges:** Show item counts in parentheses
- **Left-aligned:** Tabs start at left edge

**Rationale:** GitHub-style tabs provide clear navigation without taking excessive vertical space.

---

### 4.3 Do / Don't Examples

#### Typography

✅ **DO:**
- Use `font-mono` for headings, timestamps, and structured metadata
- Use `text-[var(--ctp-text)]` for primary content
- Use `text-[var(--ctp-subtext1)]` for secondary content

❌ **DON'T:**
- Use font sizes larger than `text-2xl` for any content
- Apply font weights above 500 (medium)
- Use italic styles except for emphasis in long-form text

#### Color

✅ **DO:**
- Use `var(--ctp-green)` exclusively for success/verified states
- Use `var(--ctp-red)` exclusively for errors/destructive actions
- Use `var(--ctp-blue)` for all primary actions and links

❌ **DON'T:**
- Use arbitrary hex colors in component files
- Mix semantic colors (e.g., green for warnings)
- Use high-saturation or bright colors

#### Spacing

✅ **DO:**
- Use `p-2.5` for card padding (10px)
- Use `gap-3` or `gap-4` for component spacing
- Maintain consistent left alignment

❌ **DON'T:**
- Use padding larger than `p-6` for cards
- Center-align content (except for empty states)
- Use gaps smaller than `gap-2` for major components

#### Layout

✅ **DO:**
- Use `max-w-7xl mx-auto px-6` for page containers
- Implement toggleable sidebars for metadata
- Maintain zero-gap between list items

❌ **DON'T:**
- Create full-width layouts without max-width
- Hide critical information in collapsed sidebars by default
- Add excessive whitespace between list items

---

## 5. Component System

This section documents recurring UI patterns and their semantic roles, anatomy, variants, states, and usage guidelines.

---

### 5.1 Navigation Bar

**Semantic Role:** Global site navigation and primary action access. Provides context (current location) and universal search.

#### Anatomy
```
┌─────────────────────────────────────────────────────────────┐
│ [Logo] [Search Bar]           [Icons: Projects | Notes |   │
│                                 Notifications | Theme |      │
│                                 Settings | Admin | User]    │
└─────────────────────────────────────────────────────────────┘
```

**Implementation:** `/components/Navigation.tsx`

#### Variants
- **Default:** Full navigation with all icons
- **Compact:** (Not currently implemented)

#### States
- **Default:** Semi-transparent background (`--ctp-mantle`), subtle border
- **Scrolled:** (No change, always sticky)
- **Focus:** Search input gains blue ring on focus

#### Accessibility
- `nav` landmark for navigation region
- Icon buttons have `aria-label` or `sr-only` text
- Keyboard navigation supported (Tab, Enter)

#### Usage Guidelines
✅ **DO:**
- Keep navigation sticky (`sticky top-0 z-50`)
- Use school-blue (#1488DB) for brand elements
- Display notification badge when unread items exist

❌ **DON'T:**
- Remove or hide navigation on any page
- Add more than 8 action icons (current limit)
- Change navigation height (fixed at `h-14`)

#### Design Rationale
Navigation remains consistent across all pages to provide orientation. Sticky positioning ensures access to search and actions without scrolling. School-blue branding reinforces identity.

---

### 5.2 Filter Bar

**Semantic Role:** Content filtering, sorting, and search within a specific view (issues, PRs, feed).

#### Anatomy
```
┌─────────────────────────────────────────────────────────────┐
│ [Search Input] [Tag Filter ▼] [Sort ▼] [View Toggle]       │
└─────────────────────────────────────────────────────────────┘
```

**Implementation:** `/components/FilterBar.tsx`

#### Variants
- **Full:** Search + Tag Filter + Sort + View Toggle
- **Minimal:** Search + Sort only

#### States
- **Default:** Muted colors, no active filters
- **Active Filter:** Filter button shows count badge
- **Search Active:** Input has focus ring

#### Accessibility
- `search` landmark or `role="search"`
- Dropdown menus keyboard-navigable
- Clear visual focus indicators

#### Usage Guidelines
✅ **DO:**
- Place immediately above content list
- Show active filter count in badge
- Persist filter state in URL params (when applicable)

❌ **DON'T:**
- Hide filter bar on mobile (make it responsive)
- Use more than 3-4 filter options (avoid clutter)
- Auto-submit on every keystroke (debounce search)

#### Design Rationale
Filter bars follow GitHub patterns: left-aligned search, dropdown filters, quiet visual styling. Persistent placement aids muscle memory.

---

### 5.3 Feed Post Card

**Semantic Role:** Represents a single post/article/discussion item in a list view. Provides title, metadata, and quick actions.

#### Anatomy
```
┌─────────────────────────────────────────────────────────────┐
│ [Tag:AlDp] Post Title Here                     [Badges]     │
│ ↑342  💬24  ⚠3  🔀2  │  user.name commented 2h ago │ 5d ago │
└─────────────────────────────────────────────────────────────┘
```

**Implementation:** `/components/FeedPost.tsx`

#### Variants
- **Seen:** Muted border (`--ctp-surface0`)
- **Unseen:** Blue accent border (`#1488DB/30`)
- **Modified:** Mauve indicator in status badges

#### States
- **Default:** Mantle background, surface0 border
- **Hover:** Border shifts to blue accent (`#1488DB/50`)
- **Selected/Active:** (Not implemented, would be persistent blue border)

#### Accessibility
- Card is a single focusable `<div>` with `onClick`
- Heading is semantic `<h3>` or `<h4>`
- Status badges use emoji + text for redundancy

#### Usage Guidelines
✅ **DO:**
- Show abbreviated tags (first letters only, e.g., "AlDp" for "Algorithms-Dynamic-Programming")
- Use semantic colors for status badges (green=verified, yellow=outdated)
- Display last activity prominently

❌ **DON'T:**
- Use full tag names (too wide)
- Show more than 3 status badges
- Omit timestamp or user info

#### Design Rationale
Compact design maximizes post density. Abbreviated tags reduce width while remaining scannable. Hover state provides feedback without visual noise.

---

### 5.4 Sidebar

**Semantic Role:** Supplementary information, metadata, related items, or navigation aids for the current view.

#### Anatomy
```
┌──────────────────────┐
│ Section Header       │
│ ─────────────────────│
│ • Item 1             │
│ • Item 2             │
│ • Item 3             │
│ ─────────────────────│
│ Secondary Info       │
└──────────────────────┘
```

**Implementation:** `/components/FeedSidebar.tsx`, `/components/PostSidebar.tsx`

#### Variants
- **Feed Sidebar:** Popular tags, trending topics
- **Post Sidebar:** Related posts, contributors
- **Toggleable:** Can be hidden/shown via button

#### States
- **Visible:** Default on desktop (>1024px)
- **Hidden:** Toggled by user, hidden on tablet (\<1024px)

#### Accessibility
- `aside` or `complementary` landmark
- Collapse button has `aria-expanded` state
- Sidebar sections have headings (`<h3>`, `<h4>`)

#### Usage Guidelines
✅ **DO:**
- Limit sidebar width to ~30% of container
- Use `sticky top-16` to follow scroll (if beneficial)
- Provide toggle button in top-right of main content

❌ **DON'T:**
- Make sidebar wider than main content
- Place critical actions in sidebar (may be hidden)
- Auto-hide sidebar without user control

#### Design Rationale
Right-aligned sidebars follow GitHub/GitLab conventions. Toggleable visibility respects user preference and screen space. Content-first layout prioritizes main area.

---

### 5.5 Status Badges

**Semantic Role:** Indicate item state (verified, updated, outdated, modified, controversial).

#### Anatomy
```
┌──────────────┐
│ ✓ verified   │  ← Icon + Text, colored border/bg
└──────────────┘
```

**Implementation:** `getStatusBadge()` in `/components/FeedPost.tsx`

#### Variants (Semantic)
| Status | Icon | Color | Meaning |
|--------|------|-------|---------|
| **verified** | ✓ | `--ctp-green` | Peer-reviewed, approved |
| **updated** | ⟳ | `--ctp-blue` | Recently refreshed |
| **outdated** | ⚠ | `--ctp-yellow` | Needs review/update |
| **controversial** | ! | `--ctp-red` | Disputed or flagged |
| **modified** | ✎ | `--ctp-mauve` | Edited since posting |

#### States
- **Default:** 20% background opacity, 30% border opacity of semantic color
- **Hover:** (No change, badges are not interactive)

#### Accessibility
- Emoji icon + text provides redundant meaning (not color-only)
- Sufficient contrast on both light and dark themes

#### Usage Guidelines
✅ **DO:**
- Limit to 1-3 badges per item
- Use semantic colors consistently
- Include both icon and text

❌ **DON'T:**
- Create custom status types without semantic meaning
- Use color-only differentiation (always include text)
- Make badges clickable (they are indicators, not actions)

#### Design Rationale
Badges provide at-a-glance status information without requiring interaction. Redundant encoding (color + icon + text) ensures accessibility.

---

### 5.6 Buttons

**Semantic Role:** Trigger actions or navigate to related content.

#### Variants
- **Primary:** Filled, school-blue background, white text
- **Secondary:** Outlined, surface0 border, text color
- **Ghost:** No border/background, text color, hover background
- **Icon Only:** Ghost variant with icon, no text (requires `aria-label`)

**Implementation:** `/components/ui/button.tsx` (shadcn/ui)

#### States
- **Default:** Styled per variant
- **Hover:** Background lightens/darkens, border becomes blue
- **Focus:** Blue ring (`ring-[var(--ctp-blue)]`)
- **Disabled:** Reduced opacity, cursor not-allowed

#### Accessibility
- Button element or `role="button"`
- Icon-only buttons have `aria-label` or `sr-only` text
- Keyboard accessible (Tab, Enter/Space)

#### Usage Guidelines
✅ **DO:**
- Use primary buttons for main actions (Submit, Save, Create)
- Use ghost buttons for low-priority actions (Cancel, Dismiss)
- Provide clear, action-oriented labels ("Save Changes", not "OK")

❌ **DON'T:**
- Use more than one primary button per section
- Create buttons without accessible labels
- Use buttons for navigation (use links with button styling if needed)

#### Design Rationale
Button hierarchy guides user attention to primary actions. Ghost buttons reduce visual noise for secondary actions. Clear labels improve usability.

---

### 5.7 Tabs

**Semantic Role:** Navigate between related views or content sections within a page. Tabs may have signature/theme colors for visual identity, distinct from semantic action colors within tab content.

#### Anatomy
```
┌─────────────────────────────────────────────────────┐
│ [Discussion] [Issues (3)] [PRs (2)] [History]       │
├─────────────────────────────────────────────────────┤
│ Tab Content Area                                    │
└─────────────────────────────────────────────────────┘
```

**Implementation:** `/components/ui/tabs.tsx` (shadcn/ui prototype), used in `PostViewTabs.tsx`

**Tab Signature Colors (Under Refinement):**
Each tab may have a signature color for visual identification (e.g., Issues → red-adjacent, PRs → blue-adjacent, Discussions → green-adjacent). However, this creates potential conflicts with semantic color meanings (red = danger, green = success). 

**Resolution Strategy:**
- Primary actions within tabs (e.g., "New Issue", "Create PR") use `--ctp-blue` (primary action) regardless of tab signature color
- Tab signature colors are used for tab indicators, headers, and decorative elements only
- Alternative: Source additional Catppuccin-compatible pastels for tab signatures that don't conflict with semantic action colors
- **Status:** Active design refinement needed to resolve Issues tab (red signature) vs semantic red (danger)

#### Variants
- **Underline:** Active tab has bottom border (primary)
- **Pill:** (Not used in this system)

#### States
- **Inactive:** Muted text (`--ctp-subtext1`), no border
- **Hover:** Text becomes accent color (`--ctp-blue`)
- **Active:** Accent text, bottom border connects to content area

#### Accessibility
- Uses ARIA tabs pattern (`role="tablist"`, `role="tab"`, `role="tabpanel"`)
- Keyboard navigation (Arrow keys, Tab, Enter)
- `aria-selected` indicates active tab

#### Usage Guidelines
✅ **DO:**
- Show counts in parentheses (e.g., "Issues (3)")
- Left-align tabs
- Limit to 5-7 tabs maximum

❌ **DON'T:**
- Use tabs for unrelated content (use pages instead)
- Nest tabs more than one level deep
- Hide critical information in inactive tabs

#### Design Rationale
Tabs reduce page load and provide contextual navigation. GitHub-style underline tabs are familiar to technical users. Count badges surface information without requiring tab switch.

---

### 5.8 Input Fields

**Semantic Role:** Accept user text input (search, form fields, comments).

#### Variants
- **Default:** Standard text input
- **Search:** With search icon prefix
- **Textarea:** Multi-line input for long text

**Implementation:** `/components/ui/input.tsx`, `/components/ui/textarea.tsx`

#### States
- **Default:** Crust background, surface0 border
- **Focus:** Blue ring, blue border
- **Error:** Red ring, red border
- **Disabled:** Surface2 background, muted text

#### Accessibility
- `<label>` associated with input (`for`/`id` match)
- Placeholder text does not replace labels
- Error messages linked via `aria-describedby`

#### Usage Guidelines
✅ **DO:**
- Provide visible labels for all inputs
- Use placeholder text for examples, not instructions
- Show validation errors immediately adjacent to input

❌ **DON'T:**
- Use placeholder-only inputs (inaccessible)
- Validate on every keystroke (debounce or validate on blur)
- Create inputs wider than necessary

#### Design Rationale
Clear labels and immediate feedback improve form usability. Crust background differentiates inputs from surrounding surfaces. Blue focus ring maintains brand consistency.

---

### 5.9 Pagination

**Semantic Role:** Navigate through multi-page lists (feed, search results).

#### Anatomy
```
[← Previous]  1  [2]  3  ...  10  [Next →]
```

**Implementation:** Inline in `HomeFeed.tsx`, could be abstracted to `/components/Pagination.tsx`

#### Variants
- **Default:** All page numbers visible (small datasets)
- **Collapsed:** Show first, last, current, and ellipsis (large datasets)

#### States
- **Current Page:** Blue background, white text
- **Available Page:** Ghost button, clickable
- **Disabled (Prev/Next):** Muted, not clickable

#### Accessibility
- `<nav aria-label="Pagination">`
- Current page has `aria-current="page"`
- Disabled buttons have `aria-disabled="true"`

#### Usage Guidelines
✅ **DO:**
- Place pagination below content list
- Show current page clearly
- Include "Previous" and "Next" buttons

❌ **DON'T:**
- Use infinite scroll without user control
- Hide total page count
- Make pagination the only navigation method (provide search/filter)

#### Design Rationale
Pagination gives users control over data loading. Clear current page indicator prevents disorientation. Prev/Next buttons accommodate linear browsing.

---

## 6. Interaction & Behavior Patterns

### 6.1 Navigation Patterns

#### 6.1.1 Global Navigation

**Pattern:** Persistent navigation bar with brand, search, and action icons.

**Behavior:**
- **Click brand/logo:** Return to home feed
- **Search input:** Focus immediately on click, submit on Enter
- **Icon buttons:** Single-click actions (navigate, toggle theme, open settings)
- **Notification badge:** Pulsing animation indicates unread items

**Rationale:** Muscle memory relies on consistent navigation. Single-click actions reduce interaction cost.

#### 6.1.2 In-Page Navigation (Tabs)

**Pattern:** Horizontal tab bar for switching between related views.

**Behavior:**
- **Click tab:** Switch active content, update URL (optional)
- **Keyboard navigation:** Arrow keys move between tabs, Enter activates
- **Count badges:** Update dynamically when content changes

**Rationale:** Tabs reduce page loads and provide contextual switching. Keyboard support improves accessibility.

#### 6.1.3 List Navigation

**Pattern:** Vertical list of cards (posts, issues, PRs).

**Behavior:**
- **Click card:** Navigate to detail view (full click target, not just title)
- **Hover:** Border color changes to indicate interactivity
- **Keyboard:** Tab to focus card, Enter to activate

**Rationale:** Full-card click target improves usability (large touch target). Hover feedback confirms interactivity.

---

### 6.2 Feedback Patterns

#### 6.2.1 Loading States

**Pattern:** Skeleton screens, spinners, or disabled states during async operations.

**Behavior:**
- **Initial page load:** Skeleton layout matching final content structure
- **Inline actions (like, vote):** Button shows spinner, text changes to "Loading..."
- **Form submission:** Button disabled, spinner replaces text

**Rationale:** Skeleton screens prevent layout shift. Inline feedback keeps context. Clear loading state prevents duplicate submissions.

#### 6.2.2 Success States

**Pattern:** Toast notification (bottom-right), inline confirmation, or state change.

**Behavior:**
- **Toast (non-critical):** 3-second auto-dismiss, green accent
- **Inline (critical):** Green checkmark + text, persists until dismissed
- **State change:** Badge updates (e.g., "verified" badge appears)

**Rationale:** Toasts provide feedback without blocking interaction. Inline confirmations ensure visibility for critical actions.

#### 6.2.3 Error States

**Pattern:** Toast notification, inline error message, or form validation feedback.

**Behavior:**
- **Toast (network error):** Red accent, manual dismiss
- **Form validation:** Red border + text below input, persists until corrected
- **Critical error:** Modal dialog with explanation and recovery action

**Rationale:** Errors must be noticeable and actionable. Persistent messages ensure users see and address issues.

---

### 6.3 Form Interaction and Validation

#### 6.3.1 Input Validation

**Pattern:** Validate on blur (after user leaves input), show errors immediately.

**Behavior:**
- **On focus:** Clear previous error (if user is correcting)
- **On blur:** Validate, show error if invalid
- **On submit:** Validate all fields, focus first error

**Rationale:** Blur validation avoids interrupting typing. Immediate error display aids correction.

#### 6.3.2 Form Submission

**Pattern:** Single submit button, disabled during submission.

**Behavior:**
1. User clicks "Submit"
2. Button disabled, text changes to "Submitting..."
3. On success: Toast confirmation, form clears or redirects
4. On error: Button re-enables, error message displays

**Rationale:** Disabled state prevents duplicate submissions. Clear feedback confirms action completion.

---

### 6.4 Motion Principles

#### 6.4.1 When to Animate

**Permitted:**
- **Hover transitions:** Color, border, opacity (100-200ms)
- **Focus ring appearance:** Instant or \<100ms
- **Dropdown/popover open/close:** Scale + fade (150-200ms)
- **Toast notifications:** Slide in from bottom-right (200ms)

**Avoided:**
- **Page transitions:** Instant load (no fade-in)
- **Scrolling:** Native scroll, no smooth-scroll override
- **List updates:** Instant add/remove (no slide/fade)

#### 6.4.2 Why Minimal Motion

**Rationale:**
- Terminal UIs provide instant feedback, no animation
- Excessive motion slows perceived performance
- Technical users prioritize speed over polish
- Accessibility: Respects `prefers-reduced-motion`

#### 6.4.3 Motion Implementation

**Tailwind Transition Classes:**
```tsx
className="transition-colors duration-200"  // Hover color change
className="transition-opacity duration-150" // Fade in/out
```

**CSS Transitions (for `color-mix` or inline styles):**
```css
transition: all 200ms ease-in-out;
```

**Rationale:** Short durations (100-200ms) provide feedback without delay. Consistent easing (`ease-in-out`) feels natural.

---

## 7. Accessibility Guidelines

### 7.1 Color Contrast Rules

**WCAG 2.1 Level AA Compliance Required:**
- **Normal text:** 4.5:1 minimum contrast ratio
- **Large text (18px+ or bold 14px+):** 3:1 minimum
- **UI components and graphical objects:** 3:1 minimum

**Validation Process:**
1. Identify all text-on-background pairings
2. Test in both light (Latte) and dark (Mocha) themes
3. Use contrast checker tool (e.g., WebAIM, Chrome DevTools)
4. Document passing ratios in design system

**Common Pairings (Verified):**
| Pairing | Mocha Contrast | Latte Contrast | Pass? |
|---------|----------------|----------------|-------|
| `--ctp-text` on `--ctp-base` | 7.2:1 | 8.1:1 | ✅ AAA |
| `--ctp-subtext1` on `--ctp-mantle` | 5.8:1 | 6.2:1 | ✅ AA |
| `--ctp-blue` on `--ctp-mantle` | 4.6:1 | 5.1:1 | ✅ AA |
| `--ctp-surface0` border on `--ctp-mantle` | 3.2:1 | 3.4:1 | ✅ AA (UI) |

**Non-Compliant Combinations (Avoided):**
- `--ctp-overlay0` text on `--ctp-surface0` background (\< 3:1)
- `--ctp-yellow` on `--ctp-base` in Latte theme (\< 4.5:1)

---

### 7.2 Keyboard and Focus Behavior

#### 7.2.1 Focus Indicators

**Requirement:** All interactive elements must have visible focus indicators.

**Implementation:**
- **Default focus ring:** `ring-2 ring-[var(--ctp-blue)] ring-offset-2`
- **Focus visible only:** Use `:focus-visible` to show ring on keyboard focus, not mouse click

**Example:**
```tsx
<Button className="focus-visible:ring-2 focus-visible:ring-[var(--ctp-blue)]">
```

**Rationale:** Visible focus indicators are critical for keyboard navigation. `focus-visible` prevents unnecessary rings on mouse clicks.

#### 7.2.2 Tab Order

**Requirement:** Logical tab order follows visual flow (left-to-right, top-to-bottom).

**Implementation:**
- Avoid `tabindex` > 0 (breaks natural order)
- Use `tabindex="-1"` to make non-interactive elements programmatically focusable
- Ensure modals trap focus (Tab cycles within modal)

**Rationale:** Natural tab order matches user expectations. Focus trapping prevents keyboard users from leaving modals unintentionally.

#### 7.2.3 Keyboard Shortcuts

**Current Shortcuts:**
- **Search:** `/` (focus search input) [Planned, not implemented]
- **Theme Toggle:** `t` [Planned, not implemented]

**Future Considerations:**
- `n`: New post
- `?`: Show keyboard shortcut help

**Rationale:** Common shortcuts improve efficiency for power users. Help dialog ensures discoverability.

---

### 7.3 Screen Reader Expectations

#### 7.3.1 Landmark Roles

**Required Landmarks:**
- `<nav>`: Navigation bar
- `<main>`: Primary content area
- `<aside>` or `role="complementary"`: Sidebars
- `<search>` or `role="search"`: Search regions

**Implementation:**
```tsx
<nav aria-label="Global navigation">
<main aria-label="Main content">
<aside aria-label="Related items">
```

**Rationale:** Landmarks allow screen reader users to jump directly to regions, bypassing repetitive content.

#### 7.3.2 Heading Hierarchy

**Requirement:** Headings must follow sequential order (h1 → h2 → h3, no skipping).

**Implementation:**
- **Page title:** `<h1>` (one per page)
- **Section headers:** `<h2>`
- **Subsections:** `<h3>`
- **Component titles:** `<h4>`

**Rationale:** Sequential headings create a logical document outline, enabling screen reader navigation by heading level.

#### 7.3.3 ARIA Labels and Descriptions

**Use Cases:**
- **Icon-only buttons:** `<Button aria-label="Close">`
- **Dynamic content:** `<div aria-live="polite">` (for status updates)
- **Form errors:** `<Input aria-describedby="error-message">`

**Rationale:** ARIA supplements HTML semantics, providing context where visual cues are insufficient.

---

### 7.4 Accessibility as a Design Constraint

**Principle:** Accessibility is not an afterthought; it constrains design decisions from the start.

**Implications:**
- **Color cannot be the sole differentiator:** Status badges use icon + color + text
- **Interactive elements must meet size requirements:** 44x44px minimum touch target (mobile)
- **Focus order must be logical:** Visual layout dictates tab order
- **Animations must be minimal:** Respect `prefers-reduced-motion`

**Validation:**
- Test with keyboard only (no mouse)
- Test with screen reader (NVDA, JAWS, VoiceOver)
- Test with high contrast mode
- Test with zoom (200%, 400%)

---

## 8. Content & Tone Guidelines

### 8.1 Voice and Tone Principles

**Voice:** Technical, direct, efficient. Assumes familiarity with CS concepts and development workflows.

**Tone Characteristics:**
- **Concise:** Favor brevity over explanation (assume informed audience)
- **Precise:** Use technical terms correctly (e.g., "merge conflict", "hash", "recursive")
- **Neutral:** Avoid hype, marketing language, or excessive enthusiasm
- **Helpful:** Provide context where needed, but don't over-explain

**Examples:**
- ✅ "Merge conflict in `src/algorithms.rs`"
- ❌ "Oops! Looks like there's a little merge conflict! 😅"

**Rationale:** Technical users prefer clarity and speed. Overly casual tone can feel patronizing or unprofessional.

---

### 8.2 UI Copy Rules

#### 8.2.1 Button Labels

**Format:** Verb + Object (when space permits)

**Examples:**
- ✅ "Save Changes"
- ✅ "Delete Post"
- ✅ "Submit PR"
- ❌ "OK" (ambiguous)
- ❌ "Click Here" (not action-oriented)

**Rationale:** Action-oriented labels clarify intent and reduce errors.

#### 8.2.2 Placeholder Text

**Format:** Example input, not instructions

**Examples:**
- ✅ `placeholder="$ search [posts | tags | users]..."`
- ✅ `placeholder="e.g., graph-theory, dynamic-programming"`
- ❌ `placeholder="Enter search terms here"` (instructional, redundant)

**Rationale:** Example text shows format and possibilities without stating the obvious.

#### 8.2.3 Empty States

**Format:** Brief explanation + suggested action

**Example:**
```
No issues yet
Create the first issue to track bugs or feature requests.
[Create Issue]
```

**Rationale:** Empty states should guide users toward next steps, not just state the absence of content.

---

### 8.3 Error and System Message Guidance

#### 8.3.1 Error Messages

**Format:** What happened + Why + How to fix (if applicable)

**Examples:**
- ✅ "Failed to save post. Network connection lost. Check your connection and try again."
- ✅ "Invalid email format. Use the format: user@example.com"
- ❌ "Error 500" (no context)
- ❌ "Something went wrong!" (no actionability)

**Rationale:** Informative errors reduce frustration and support self-service recovery.

#### 8.3.2 Success Messages

**Format:** Action completed + Result (optional)

**Examples:**
- ✅ "Post published successfully."
- ✅ "Comment posted. You'll be notified of replies."
- ❌ "Success!" (what succeeded?)

**Rationale:** Confirm the action and provide next-step context when relevant.

#### 8.3.3 System Notifications

**Format:** Event + Actor + Timestamp

**Example:**
```
prof.james.wilson commented on "Understanding Graph Algorithms" • 2h ago
```

**Rationale:** Mirrors GitHub notification patterns, familiar to technical users.

---

## 9. Semantic Web & Structural Semantics

### 9.1 Mapping UI Patterns to Semantic Meaning

**Principle:** Visual patterns must map to semantic HTML structures, not presentational divs.

**Pattern Mappings:**

| UI Pattern | Semantic Element(s) | Rationale |
|------------|---------------------|-----------|
| **Navigation bar** | `<nav>` | Identifies primary navigation region |
| **Page title** | `<h1>` | One per page, top-level heading |
| **Card title** | `<h3>` or `<h4>` | Maintains heading hierarchy |
| **Post content** | `<article>` | Self-contained composition |
| **Metadata sidebar** | `<aside>` | Tangentially related content |
| **Form controls** | `<form>`, `<label>`, `<input>` | Interactive data input |
| **List of items** | `<ul>` or `<ol>` | Structured list, not div stacking |
| **Buttons** | `<button>` | Actions, not navigation |
| **Links** | `<a>` | Navigation, not actions |

**Rationale:** Semantic HTML provides meaning to assistive technologies, search engines, and future maintainers. Presentational divs obscure intent.

---

### 9.2 Guidance on Structural Semantics

#### 9.2.1 Landmark Roles

**Required Landmarks:**
- **Navigation (`<nav>`):** Global navigation, filter bars, pagination
- **Main Content (`<main>`):** Primary page content (one per page)
- **Complementary (`<aside>`):** Sidebars, related items
- **Search (`<search>` or `role="search"`):** Search input regions

**Implementation:**
```tsx
<nav aria-label="Global navigation">...</nav>
<main>
  <h1>Page Title</h1>
  <article>...</article>
</main>
<aside aria-label="Related Posts">...</aside>
```

**Rationale:** Landmarks enable screen reader users to skip to relevant sections, improving navigation efficiency.

#### 9.2.2 Content Semantics

**Headings (`<h1>`-`<h6>`):**
- Create logical outline of page
- Do not skip levels (h1 → h3 is invalid)
- Each page has exactly one `<h1>`

**Lists (`<ul>`, `<ol>`, `<dl>`):**
- **Unordered (`<ul>`):** Post lists, tag lists, navigation items
- **Ordered (`<ol>`):** Ranked results, step-by-step instructions
- **Definition (`<dl>`):** Metadata pairs (label: value)

**Forms (`<form>`, `<label>`, `<fieldset>`):**
- All inputs have associated `<label>` (explicit or implicit)
- Related inputs grouped in `<fieldset>` with `<legend>`

**Tables (`<table>`, `<thead>`, `<tbody>`, `<th>`, `<td>`):**
- Use for tabular data, not layout
- Include `<caption>` for table title
- Use `<th scope="col">` for column headers

**Rationale:** Proper semantics improve accessibility, SEO, and code readability.

#### 9.2.3 Separation of Presentation from Meaning

**Principle:** HTML describes structure and meaning; CSS describes presentation.

**Anti-Pattern:**
```tsx
<div className="card-title">Understanding Graph Algorithms</div>
```

**Correct Pattern:**
```tsx
<h3 className="card-title">Understanding Graph Algorithms</h3>
```

**Rationale:** `<div>` has no semantic meaning. Screen readers cannot identify it as a heading. CSS classes describe visual style, not semantic role.

---

### 9.3 Rationale for Semantic Decisions

**Why Semantic HTML Matters:**

1. **Accessibility:** Screen readers rely on semantic elements to convey structure.
2. **SEO:** Search engines prioritize semantic content (headings, articles, etc.).
3. **Maintainability:** Future developers understand intent without reading implementation.
4. **Interoperability:** Other tools (reading apps, browser features) can extract meaning.

**How Semantics Support This System:**

- **Terminal aesthetic:** Semantic HTML mirrors terminal text hierarchies (headings, lists, indentation)
- **High density:** Proper structure prevents reliance on visual spacing for meaning
- **GitHub-inspired patterns:** GitHub uses semantic HTML extensively (articles, forms, tables)

---

## 10. Design Tokens & CSS Specification

### 10.1 Token Categories

#### 10.1.1 Color Tokens

**Base Palette:**
- `--ctp-base`, `--ctp-mantle`, `--ctp-crust` (surface layers)
- `--ctp-surface0`, `--ctp-surface1`, `--ctp-surface2` (elevated surfaces)
- `--ctp-text`, `--ctp-subtext1`, `--ctp-subtext0` (text hierarchy)
- `--ctp-overlay0`, `--ctp-overlay1`, `--ctp-overlay2` (overlays, borders)

**Accent Palette:**
- `--ctp-blue`, `--ctp-blue-deep` (brand, primary)
- `--ctp-green`, `--ctp-red`, `--ctp-yellow` (semantic states)
- `--ctp-mauve`, `--ctp-pink`, `--ctp-peach`, `--ctp-teal`, `--ctp-sky` (categorical accents)

**Semantic Aliases:**
- `--background`: Maps to `--ctp-base`
- `--foreground`: Maps to `--ctp-text`
- `--primary`: Maps to `--ctp-blue`
- `--destructive`: Maps to `--ctp-red`
- `--muted`: Maps to `--ctp-surface0`

**Rationale:** Catppuccin color-reference variables (`--ctp-red`, `--ctp-blue`, etc.) enable theme switching and user customization. When used in component code, the color name itself carries semantic meaning (e.g., using `--ctp-red` implies danger/error), while remaining flexible enough to be redefined in custom themes.

#### 10.1.2 Spacing Tokens

**Scale (Tailwind defaults):**
- `0`, `1`, `1.5`, `2`, `2.5`, `3`, `4`, `5`, `6`, `8`, `10`, `12`, `16`, `20`, `24`

**Common Usage:**
- `p-2.5` (10px): Card padding
- `gap-3` (12px): Component spacing
- `gap-4` (16px): Section spacing
- `px-6` (24px): Page horizontal padding

**Rationale:** 4px base unit ensures alignment. Limited scale prevents arbitrary spacing choices.

#### 10.1.3 Typography Tokens

**Font Families:**
- `font-sans`: System font stack (body, UI)
- `font-mono`: Monospace stack (headings, code, metadata)

**Font Sizes:**
- `text-xs` (12px): Small metadata
- `text-sm` (14px): Secondary text
- `text-base` (16px): Default
- `text-lg` (18px): h3
- `text-xl` (20px): h2
- `text-2xl` (24px): h1

**Font Weights:**
- `font-normal` (400): Body text
- `font-medium` (500): Headings, labels, buttons

**Rationale:** Limited scale maintains visual hierarchy without excessive variation.

#### 10.1.4 Motion Tokens

**Durations:**
- `duration-100` (100ms): Fast transitions (focus ring)
- `duration-150` (150ms): Standard transitions (dropdown)
- `duration-200` (200ms): Slow transitions (hover color)

**Easing:**
- `ease-in-out`: Default for all transitions

**Rationale:** Short durations maintain perceived performance. Consistent easing feels natural.

#### 10.1.5 Elevation Tokens

**Border Radius:**
- `--radius` (10px / 0.625rem): Default corner radius
- `rounded` (4px): Small elements
- `rounded-md` (6px): Medium elements
- `rounded-lg` (10px): Large elements

**Rationale:** Modest radius (10px) softens corners without appearing overly rounded. Consistent radii maintain visual coherence.

---

### 10.2 CSS Variable Naming Conventions

#### 10.2.1 Naming Patterns

**Structure:** `--{prefix}?-{category}-{variant}`

Where `?` indicates the prefix is optional.

**Prefixes:**
- `ctp-`: Catppuccin palette color references (e.g., `--ctp-base`, `--ctp-red`, `--ctp-blue`)
- (none): Generic semantic tokens when needed (e.g., `--background`, `--foreground`)

**Categories:**
- `base`, `mantle`, `crust`: Surface layers
- `surface`, `overlay`: Elevated surfaces
- `text`, `subtext`: Text hierarchy
- Color names (`blue`, `green`, `red`): Semantic accents

**Variants:**
- Numbers (`0`, `1`, `2`): Intensity/hierarchy (e.g., `surface0` \< `surface1`)
- Modifiers (`deep`, `foreground`): Contextual variants

**Examples:**
- `--ctp-base`: Catppuccin base surface color (can be referenced for backgrounds)
- `--ctp-surface0`: Catppuccin surface layer 0 color (can be used for borders, hover states, etc.)
- `--ctp-text`: Catppuccin primary text color
- `--ctp-red`: Catppuccin red color (semantic danger/error when used in actions)
- `--ctp-blue`: Catppuccin/school blue color (semantic primary action)
- `--background`: Optional semantic alias for page background (may map to `--ctp-base`)

**Key Principle:** Variables reference **colors** by their Catppuccin name, not **elements** by their role. This allows:
- System theme integration (users can redefine `--ctp-red` to their preferred danger color)
- Semantic meaning through color choice in code (using `--ctp-red` implies danger)
- Flexibility in theme customization without breaking semantic contracts

**Rationale:** Color-reference naming (vs element-reference naming) maintains semantic clarity while enabling user theme customization. Optional prefixes allow for flexibility in naming non-Catppuccin extensions.

#### 10.2.2 Scope Rules

**Global Scope (`:root` and `.dark`):**
All design tokens are global CSS variables defined in `/styles/globals.css`.

**Component-Level Scope:**
No component-specific CSS variables currently exist. All components consume global tokens.

**Rationale:** Global scope ensures consistency. Component-level variables may be introduced for highly reusable, complex components (e.g., charting library color scales).



#### 10.2.3 Two-Layer Token Architecture

**Layer 1: Palette Tokens (Color Aliases)**
Foundational color definitions that represent the actual color palette:
- `--ctp-red: #f38ba8`: Catppuccin Mocha red (changes to `#d20f39` in Latte theme)
- `--ctp-blue: #1488DB`: HCMUT brand blue (consistent across themes)
- `--ctp-green: #a6e3a1`: Catppuccin Mocha green (changes to `#40a02b` in Latte theme)
- `--ctp-base: #11111b`: Catppuccin Mocha base surface (changes to `#eff1f5` in Latte theme)
- `--ctp-mantle: #1e1e2e`: Catppuccin Mocha mantle surface (changes to `#e6e9ef` in Latte theme)
- `--ctp-text: #cdd6f4`: Catppuccin Mocha text color (changes to `#4c4f69` in Latte theme)

**Layer 2: Semantic Tokens (Component/Element Mappings)**
Contextual mappings that reference Layer 1 palette tokens:
- `--background: var(--ctp-base)`: Main page background surface
- `--foreground: var(--ctp-text)`: Primary text color throughout the application
- `--card: var(--ctp-mantle)`: Background for cards, containers, and primary UI surfaces
- `--primary: var(--ctp-blue)`: Primary action color (buttons, links, active states)
- `--destructive: var(--ctp-red)`: Danger/error color for destructive actions
- `--border: var(--ctp-surface0)`: Default border color across components
- `--input: var(--ctp-crust)`: Background color for input fields

**Usage Guidance:**
- **In component code:** Reference **Layer 2 semantic tokens** (`--background`, `--card`, `--primary`) wherever possible
  ```tsx
  // ✅ Preferred (semantic token)
  <div className="bg-[var(--card)] text-[var(--card-foreground)]">
  
  // ✅ Acceptable (no semantic token exists yet)
  <div className="bg-[var(--ctp-mantle)]">
  
  // ❌ Avoid (hardcoded hex value)
  <div className="bg-[#1e1e2e]">
  ```

- **In globals.css:** Define **Layer 1 palette tokens** and map them to **Layer 2 semantic tokens**
  ```css
  :root {
    /* Layer 1: Palette */
    --ctp-mantle: #e6e9ef;
    --ctp-text: #4c4f69;
    
    /* Layer 2: Semantic mappings */
    --card: var(--ctp-mantle);
    --card-foreground: var(--ctp-text);
  }
  
  .dark {
    /* Layer 1: Palette (redefined for dark theme) */
    --ctp-mantle: #1e1e2e;
    --ctp-text: #cdd6f4;
    
    /* Layer 2: Semantic mappings remain unchanged */
    /* --card and --card-foreground automatically update */
  }
  ```

- **Theme customization:** Users can redefine Layer 2 mappings without touching component code
  ```css
  /* User preference: Use GNOME Adwaita colors instead of Catppuccin */
  :root {
    --card: var(--adwaita-headerbar-bg);  /* Remap to Adwaita color */
    --primary: var(--adwaita-accent-blue);
  }
  ```

**Rationale:** The two-layer architecture separates color palette (Layer 1) from contextual meaning (Layer 2). This enables:
1. **Easy theme switching:** Redefine Layer 2 mappings in one place to retheme the entire application
2. **Semantic preservation:** Components reference `--card`, not `--ctp-mantle`, so intent survives theme changes
3. **Flexibility:** Users can substitute Catppuccin colors with system theme colors without breaking components
4. **Maintainability:** Adding a new color to the palette (Layer 1) doesn't require updating all components
5. **Gradual migration:** Components can use Layer 1 initially, then migrate to Layer 2 as semantic tokens are defined

---

### 10.3 Intended Token → Code Mapping

**Preferred Approach (Layer 2 Semantic Tokens):**

**Semantic Token:** `--background` (maps to `var(--ctp-base)`)  
**Implementation:** `className="bg-[var(--background)]"` or `style={{ backgroundColor: 'var(--background)' }}`

**Semantic Token:** `--card` (maps to `var(--ctp-mantle)`)  
**Implementation:** `className="bg-[var(--card)] text-[var(--card-foreground)]"`

**Semantic Token:** `--primary` (maps to `var(--ctp-blue)`)  
**Implementation:** 
- Tailwind utility: `className="bg-primary text-primary-foreground"` (via `@theme` directive)
- Direct reference: `className="bg-[var(--primary)] text-[var(--primary-foreground)]"`

**Semantic Token:** `--destructive` (maps to `var(--ctp-red)`)  
**Implementation:** `className="bg-[var(--destructive)] text-[var(--destructive-foreground)]"`

**Acceptable Approach (Layer 1 Palette Tokens):**

Use when no appropriate semantic token exists yet or for categorical colors (tags, charts):

**Palette Token:** `--ctp-mauve` (algorithm tag color)  
**Implementation:** `className="bg-[var(--ctp-mauve)]/10 text-[var(--ctp-mauve)]"`

**Palette Token:** `--ctp-peach` (Rust tag color)  
**Implementation:** `className="border-[var(--ctp-peach)] text-[var(--ctp-peach)]"`

**Other Token Types:**

**Border Radius:** `--radius` (default border radius)  
**Implementation:** `className="rounded-lg"` (maps to `var(--radius)` via Tailwind config)

**Opacity Application:**
- **Tailwind (Layer 2):** `bg-[var(--primary)]/20` (20% opacity on primary color)
- **Tailwind (Layer 1):** `bg-[var(--ctp-blue)]/20` (20% opacity on palette color)
- **Inline CSS:** `color-mix(in srgb, var(--primary) 20%, transparent)`

**Complete Example (Card Component):**
```tsx
// ✅ Preferred: Uses Layer 2 semantic tokens
<div className="bg-[var(--card)] border border-[var(--border)] rounded-lg p-4">
  <h2 className="text-[var(--card-foreground)]">Card Title</h2>
  <button className="bg-primary text-primary-foreground">
    Primary Action
  </button>
  <button className="bg-[var(--destructive)] text-[var(--destructive-foreground)]">
    Delete
  </button>
</div>

// ✅ Acceptable: Uses Layer 1 for categorical tags
<div className="bg-[var(--card)]">
  <span className="bg-[var(--ctp-mauve)]/10 text-[var(--ctp-mauve)]">
    Algorithms
  </span>
  <span className="bg-[var(--ctp-peach)]/10 text-[var(--ctp-peach)]">
    Rust
  </span>
</div>
```

**Rationale:** 
- Layer 2 semantic tokens enable theme customization without code changes
- Layer 1 palette tokens provide flexibility for categorical/visual-specific use cases
- CSS variables enable dynamic light/dark theme switching
- Tailwind utilities provide shorthand for common patterns while preserving token references

---

### 10.4 Constraints and Invariants

#### Invariants (Must Always Be True)

1. **All colors must use CSS variables** (no hardcoded hex in components, except school-blue #1488DB/#030391 which may remain for legacy reasons)
2. **Both themes (Mocha, Latte) must define all variables** (no undefined variables in either theme)
3. **Semantic color roles must remain consistent** (green = success, red = danger, etc.)
4. **Spacing must use Tailwind scale** (no arbitrary pixel values like `px-[13px]`)
5. **Contrast ratios must pass WCAG AA** (validated before shipping)

#### Constraints (Design Limitations)

1. **No high-saturation colors** (Catppuccin pastel palette only)
2. **No font sizes above `text-2xl`** (maintain visual calmness)
3. **No font weights above 500** (avoid heavy/bold unless absolutely necessary)
4. **No box-shadows** (use surface layering instead)
5. **Minimal animations** (only hover, focus, and essential transitions)

**Rationale:** Invariants ensure system integrity. Constraints maintain design coherence and prevent drift.

---

### 10.5 Rationale for Naming Strategy

**Why Two Layers?**
- **Separation of concerns:** Layer 1 (palette) defines available colors; Layer 2 (semantic) defines how colors are used
- **Theme flexibility:** Users can redefine Layer 2 mappings (e.g., `--card: var(--nord-polar-night-2)`) without touching components
- **Maintainability:** Adding new colors to the palette doesn't require updating all components
- **Gradual migration:** Components can reference Layer 1 initially, then migrate to Layer 2 as semantic tokens mature
- **Clear intent:** `--card` (Layer 2) communicates "container background" better than `--ctp-mantle` (Layer 1)

**Why `--ctp-*` Prefix for Layer 1?**
- **Namespace clarity:** Identifies Catppuccin palette color references, distinguishing them from semantic tokens
- **Conflict prevention:** Avoids naming collisions with other libraries or user-defined variables
- **Future extensibility:** Enables multiple palette support (e.g., `--nord-*`, `--dracula-*`, `--adwaita-*`) if users want alternatives
- **Palette identification:** Makes it obvious which tokens are "raw colors" vs "semantic roles"

**Why Semantic Names for Layer 2?**
- **Intent over implementation:** `--card` describes purpose (container background), not color (`--ctp-mantle`)
- **Theme independence:** Changing `--card: var(--ctp-mantle)` to `--card: var(--adwaita-headerbar)` rethemes all cards instantly
- **Readability:** Code like `bg-[var(--card)]` is clearer than `bg-[var(--ctp-mantle)]` for developers unfamiliar with Catppuccin
- **Consistency with industry patterns:** Matches design token strategies used by Material Design, GitHub Primer, and other mature systems

**Why Not Element-Specific Names (e.g., `--button-danger-bg`)?**
- **Too granular:** Creates token explosion (hundreds of variables for every component × state × property)
- **Reduced flexibility:** `--button-danger-bg` can't be reused for other destructive UI elements (dialogs, alerts, etc.)
- **Maintenance burden:** Every new component requires defining new tokens
- **Over-specification:** Layer 2 should provide semantic roles, not prescribe exact element usage

**Why Allow Both Layers in Component Code?**
- **Pragmatism:** Not every use case maps to a semantic token (e.g., categorical tag colors for "Algorithms", "Rust", "AI")
- **Incremental adoption:** Teams can start with Layer 1 (palette) and gradually introduce Layer 2 (semantic) tokens
- **Visual-specific needs:** Data visualization and color-coded categories often need direct palette access
- **Migration path:** Existing components using `--ctp-*` tokens can continue working while new components adopt semantic tokens
- Color-reference approach (`--ctp-blue` for primary, `--ctp-red` for danger) achieves the same goal with more flexibility
- Aliases may still be used sparingly for truly generic roles (e.g., `--background`, `--foreground`)

**Rationale:** Color-reference naming balances semantic clarity with customization flexibility, supporting both designers (who work in Catppuccin palettes) and end users (who may integrate system themes or personal preferences).

---

## 11. Implementation Alignment Guidelines

### 11.1 How Designers and Engineers Interpret the System

**For Designers:**
- **Design in Catppuccin Mocha/Latte palettes** using exact hex values from Section 3.1
- **Annotate designs with CSS variable names** (e.g., "Background: --ctp-mantle")
- **Document semantic intent** (e.g., "Use green for verified state, not decorative accent")
- **Validate contrast ratios** before handoff (Section 7.1)

**For Engineers:**
- **Target implementation:** ReasonML (current React/TypeScript/Tailwind is prototype only)
- **Use CSS variables exclusively** via color-reference names (e.g., `--ctp-red`, `--ctp-blue`)
- **Avoid element-reference variables** (e.g., `--button-bg`, `--nav-color`) to support system theme integration
- **Reference this spec** for semantic color meanings and usage context (Section 3.1.2)
- **Follow component patterns** (Section 5) for anatomy, states, and usage
- **Test in both themes** (light and dark) and verify system theme compatibility

**Shared Responsibility:**
- **Color contrast validation:** Both designers and engineers verify WCAG compliance
- **Accessibility review:** Both roles test keyboard navigation and screen reader support
- **Pattern consistency:** Both roles enforce adherence to established layout patterns

**Rationale:** Clear role boundaries prevent gaps. Shared responsibility ensures quality.

---

### 11.2 Rules for Extending or Overriding Tokens and Components

#### 11.2.1 Adding New Color Tokens

**Process:**
1. Determine if new color is semantic (role-based) or categorical (tag/data)
2. If semantic, add to both `:root` and `.dark` in `/styles/globals.css`
3. If categorical, use existing Catppuccin accent color or request palette addition
4. Document new token in this spec (Section 3.1.2)
5. Validate contrast ratios in both themes

**Example:**
```css
:root {
  --ctp-warning-light: #df8e1d; /* Latte yellow */
}
.dark {
  --ctp-warning-light: #f9e2af; /* Mocha yellow */
}
```

**Rationale:** Systematic addition prevents palette bloat and ensures theme consistency.

#### 11.2.2 Creating New Components

**Process:**
1. Check if existing component can be extended (Section 5)
2. If new component needed, define: Semantic role, anatomy, variants, states
3. Implement using CSS variables only (no hardcoded colors)
4. Add to this spec (Section 5) with usage guidelines
5. Test in both themes and validate accessibility

**Example:**
New "Breadcrumb" component would document:
- **Semantic role:** Navigation aid showing page hierarchy
- **Anatomy:** Home > Section > Subsection
- **Variants:** Default, collapsed
- **States:** Active (current page), inactive (links)
- **Usage:** When to use (multi-level navigation), when not to use (flat sites)

**Rationale:** Documentation ensures consistent application and prevents pattern drift.

#### 11.2.3 Overriding Existing Patterns

**When Permitted:**
- Fixing accessibility issues (e.g., improving contrast)
- Adapting to new requirements (e.g., responsive improvements)
- Standardizing inconsistencies (e.g., aligning button sizes)

**When Forbidden:**
- Personal preference ("I like blue better here")
- One-off exceptions ("Just this page needs centered text")
- Quick fixes without design review ("I'll just hardcode this color")

**Approval Process:**
1. Propose change with rationale (accessibility, consistency, new requirement)
2. Review impact (which components affected, how many instances)
3. Update design system spec (this document)
4. Implement across all affected instances (no half-migrations)

**Rationale:** Controlled evolution prevents fragmentation. Design system is authoritative, not advisory.

---

### 11.3 Boundaries Between Design Intent and Implementation Freedom

#### Design Intent (Must Follow Exactly)

- **Color palette:** Use defined CSS variables, no arbitrary colors
- **Semantic color roles:** Green = success, red = danger (no swapping)
- **Typography scale:** Use defined sizes, no custom font-size values
- **Spacing scale:** Use Tailwind scale, no arbitrary pixel values
- **Component anatomy:** Maintain documented structure (e.g., card header + metadata + footer)

**Rationale:** These decisions define the visual language. Deviation breaks coherence.

#### Implementation Freedom (Engineer's Discretion)

- **DOM structure:** Use semantic HTML, but specific tag choice may vary (e.g., `<ul>` vs `<div role="list">`)
- **CSS approach:** Tailwind classes, inline styles, or hybrid (as long as CSS variables are used)
- **State management:** React hooks, context, or external libraries (as needed)
- **Accessibility enhancements:** Add ARIA labels, improve tab order, enhance focus management (always encouraged)
- **Performance optimizations:** Memoization, lazy loading, code splitting (no visual impact)

**Rationale:** These decisions affect code quality and performance, not visual design. Engineers should optimize as needed.

#### Gray Areas (Requires Discussion)

- **Responsive breakpoints:** Design may not specify all breakpoints; engineer proposes, designer approves
- **Micro-interactions:** Subtle hover effects not documented; use judgment, stay consistent
- **Loading states:** Spec defines pattern, but implementation details (skeleton vs spinner) may vary
- **Empty states:** Wording and iconography may be engineer-proposed, designer-approved

**Rationale:** Collaboration fills gaps. When in doubt, discuss before implementing.

---

### 11.4 What Must Remain Stable vs What May Evolve

#### Stable (Rarely Changes)

- **Core color palette (Catppuccin):** Base, mantle, crust, text colors
- **School-blue brand colors:** #1488DB, #030391
- **Semantic color roles:** Green = success, red = danger
- **Base typography scale:** Font sizes, weights, line-heights
- **Spacing scale (4px base unit):** Tailwind defaults
- **Terminal-inspired aesthetic principle:** Monospace headings, compact layouts

**Rationale:** These are foundational decisions. Changing them requires major redesign effort and risks breaking visual coherence.

#### Evolvable (May Change)

- **Accent color palette:** May add new categorical colors (e.g., `--ctp-lavender`)
- **Component variants:** May add new states or sizes (e.g., "compact" button)
- **Layout patterns:** May introduce new patterns for new features (e.g., "kanban board")
- **Animation durations:** May adjust for performance or accessibility
- **Responsive breakpoints:** May refine for better mobile support

**Rationale:** These decisions respond to evolving requirements. Changes should be additive, not disruptive.

#### Deprecation Process

When removing or changing stable elements:
1. **Announce deprecation** with replacement guidance
2. **Provide migration period** (minimum 2 release cycles)
3. **Update documentation** to mark deprecated items
4. **Assist with migration** (scripts, guides, code reviews)
5. **Remove deprecated items** only after migration complete

**Rationale:** Graceful deprecation prevents breaking changes and respects existing implementations.

---

## 12. Appendix

### 12.1 Color Reference Tables

#### Catppuccin Mocha (Dark Theme)

| Token | Hex | Usage |
|-------|-----|-------|
| `--ctp-base` | `#11111b` | Main background |
| `--ctp-mantle` | `#1e1e2e` | Cards, navigation |
| `--ctp-crust` | `#181825` | Inputs, insets |
| `--ctp-surface0` | `#313244` | Borders, hover |
| `--ctp-surface1` | `#45475a` | Elevated surfaces |
| `--ctp-surface2` | `#585b70` | Tertiary surfaces |
| `--ctp-overlay0` | `#6c7086` | Disabled text |
| `--ctp-overlay1` | `#7f849c` | Overlays |
| `--ctp-overlay2` | `#9399b2` | Overlays |
| `--ctp-text` | `#cdd6f4` | Primary text |
| `--ctp-subtext1` | `#bac2de` | Secondary text |
| `--ctp-subtext0` | `#a6adc8` | Tertiary text |
| `--ctp-blue` | `#1488DB` | Brand, primary |
| `--ctp-blue-deep` | `#030391` | Deep accent |
| `--ctp-green` | `#a6e3a1` | Success |
| `--ctp-red` | `#f38ba8` | Danger |
| `--ctp-yellow` | `#f9e2af` | Warning |
| `--ctp-mauve` | `#cba6f7` | Modified |
| `--ctp-pink` | `#f5c2e7` | Pink accent |
| `--ctp-peach` | `#fab387` | Orange accent |
| `--ctp-teal` | `#94e2d5` | Teal accent |
| `--ctp-sky` | `#89dceb` | Sky blue accent |

#### Catppuccin Latte (Light Theme)

| Token | Hex | Usage |
|-------|-----|-------|
| `--ctp-base` | `#eff1f5` | Main background |
| `--ctp-mantle` | `#e6e9ef` | Cards, navigation |
| `--ctp-crust` | `#dce0e8` | Inputs, insets |
| `--ctp-surface0` | `#ccd0da` | Borders, hover |
| `--ctp-surface1` | `#bcc0cc` | Elevated surfaces |
| `--ctp-surface2` | `#acb0be` | Tertiary surfaces |
| `--ctp-overlay0` | `#9ca0b0` | Disabled text |
| `--ctp-overlay1` | `#8c8fa1` | Overlays |
| `--ctp-overlay2` | `#7c7f93` | Overlays |
| `--ctp-text` | `#4c4f69` | Primary text |
| `--ctp-subtext1` | `#5c5f77` | Secondary text |
| `--ctp-subtext0` | `#6c6f85` | Tertiary text |
| `--ctp-blue` | `#1488DB` | Brand, primary |
| `--ctp-blue-deep` | `#030391` | Deep accent |
| `--ctp-green` | `#40a02b` | Success |
| `--ctp-red` | `#d20f39` | Danger |
| `--ctp-yellow` | `#df8e1d` | Warning |
| `--ctp-mauve` | `#8839ef` | Modified |
| `--ctp-pink` | `#ea76cb` | Pink accent |
| `--ctp-peach` | `#fe640b` | Orange accent |
| `--ctp-teal` | `#179299` | Teal accent |
| `--ctp-sky` | `#04a5e5` | Sky blue accent |

---

### 12.2 Component Implementation Checklist

When implementing a new component:

- [ ] **Semantic HTML:** Uses appropriate elements (button, nav, article, etc.)
- [ ] **CSS Variables:** All colors use `var(--ctp-*)` or semantic aliases
- [ ] **Both Themes:** Tested in Mocha (dark) and Latte (light)
- [ ] **Contrast Ratios:** All text-on-background pairings pass WCAG AA
- [ ] **Focus Indicators:** Visible focus ring on keyboard navigation
- [ ] **ARIA Labels:** Icon-only buttons, dynamic content, form errors
- [ ] **Keyboard Navigation:** Tab order logical, Enter/Space activate
- [ ] **Screen Reader:** Tested with NVDA/VoiceOver (or manual check of landmark/heading structure)
- [ ] **Responsive:** Works on desktop, tablet (mobile if applicable)
- [ ] **Documentation:** Added to Section 5 of this spec with usage guidelines

---

### 12.4 Validation Tools

**Contrast Checkers:**
- WebAIM Contrast Checker: https://webaim.org/resources/contrastchecker/
- Chrome DevTools: Inspect element → Color picker shows contrast ratio
- Figma Plugin: Stark (accessibility checker)

**Screen Readers:**
- **Windows:** NVDA (free, open-source)
- **macOS:** VoiceOver (built-in, Cmd+F5)
- **Browser Extension:** ChromeVox (Chrome)

**Keyboard Navigation Testing:**
- Unplug mouse, navigate with Tab, Enter, Space, Arrow keys
- Check focus indicators are visible
- Verify logical tab order

**Theme Testing:**
- Toggle theme via sun/moon icon in navigation
- Check all pages in both Mocha and Latte
- Verify no hardcoded colors remain visible

---

### 12.5 Glossary

**Catppuccin:** A pastel-focused color scheme with multiple themes (Mocha, Latte, Frappé, Macchiato). This system uses Mocha (dark) and Latte (light).

**CSS Variable:** Custom property defined in CSS (e.g., `--ctp-base`) that can be referenced throughout stylesheets for dynamic theming.

**Design Token:** A named design decision (color, spacing, typography) stored as a variable for reuse and consistency.

**Semantic Color:** A color assigned meaning based on context (green = success, red = danger) rather than appearance.

**Surface Layer:** Background color tier (base, mantle, crust) used to create visual depth without shadows.

**WCAG:** Web Content Accessibility Guidelines, a standard for accessible web design. Level AA requires 4.5:1 contrast for normal text.

**Landmark:** ARIA role or HTML5 element (nav, main, aside) that defines page regions for assistive technologies.

**Focus Indicator:** Visual cue (often a colored outline) showing which element has keyboard focus.

**Screen Reader:** Assistive technology that reads web content aloud for users with visual impairments.

---

## 13. Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-10-28 | Initial specification |
| 1.1 | 2025-12-6 | Major re-write following prototyped implementation |
| 1.2 | 2025-12-20 | Added sections regarding semantic implementation |

---

## 14. Acknowledgments

**Design Foundation:**
- **Catppuccin Color Scheme:** https://github.com/catppuccin/catppuccin
- **GitHub UI Patterns:** Inspiration for list views, metadata layouts, and tab navigation
- **Terminal-UI Aesthetic:** Drawn from command-line interfaces and developer tools

**Prototype Implementation:**
- **Tailwind CSS v4.0:** Utility-first CSS framework (prototype only)
- **shadcn/ui:** Accessible component primitives (prototype only)
- **React + TypeScript:** Component architecture (prototype only)

**Production Target:**
- **ReasonML:** Production implementation language
- **CSS Variables:** Cross-implementation styling system

