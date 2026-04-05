---
name: typography-color-tokens
description: "Use when designing, extending, auditing, or documenting the visual identity system — covering color palette decisions, semantic token naming, type scale, font weight assignments, line height, letter spacing, and spacing conventions. Do NOT use for Tailwind CSS v4 config mechanics, component markup changes, or layout pattern work."
argument-hint: "design area (color/typography/spacing/interactive-states), specific token or violation to address"
user-invocable: true
---

# Skill: Typography & Color Token System Design

## Purpose

Design, document, and extend the Garnebo visual identity system — covering color palette decisions, token naming conventions, type scale, font weight usage, and spacing — so every UI element is visually consistent and on-brand.

## Context

**Config location:** `src/app/globals.css` — the `@theme {}` block is the single source of truth.
**Font:** Inter (loaded via `next/font/google` in `src/app/layout.tsx`), exposed as `--font-inter` CSS variable, mapped to `--font-sans` in `@theme {}`.
**Current palette:** Muted, earthy, professional — not vibrant. The brand reads "precision craftwork" not "budget renovation".

## Current Design Token Inventory

### Color Tokens

```
Background tier:
  bg-primary    #EBE0DD  Warm off-white — default page background
  bg-white      #FFFFFF  Pure white — contrast sections (alternating)
  bg-dark       #4C6170  Deep slate — footer, dark CTA sections

Brand tier:
  brand-primary   #4C6170  Deep slate — H1/H2/H3 text, nav, icon fills
  brand-secondary #65695B  Olive-grey — body paragraphs, supporting copy

Accent tier:
  accent-blue   #8A9EAB  Muted steel blue — links, hover states, micro-copy
  accent-sage   #9CA38E  Earthy sage green — bullets, dividers, eyebrows, tags
```

### Color Relationship Map

```
Light backgrounds:  bg-primary, bg-white
Dark background:    bg-dark
Primary text on light: brand-primary (#4C6170 on #EBE0DD → 4.6:1 ✅)
Body text on light:    brand-secondary (#65695B on #EBE0DD → 4.6:1 ✅)
Primary text on white: brand-primary (#4C6170 on #FFFFFF → 6.1:1 ✅)
White text on dark bg: white on bg-dark (#4C6170 → 5.1:1 ✅)
Accent on light:    accent-blue (#8A9EAB on #EBE0DD → 2.9:1 ⚠️ use only for decorative/large text)
```

**Note:** `accent-blue` and `accent-sage` fail WCAG AA for small body text — they are only suitable for 18px+ decorative text, icons, and large-format labels.

## When To Use

- Adding a new brand colour and needing to verify contrast ratios and determine the correct semantic token name
- Auditing components for typography violations (wrong font weight for heading level, hardcoded hex, missing responsive scale)
- Documenting a proposed palette extension or type scale change in the design system inventory
- Determining the correct text colour token for a dark background section
- Identifying whether `accent-blue` or `accent-sage` are safe to use at a given font size

**Do NOT use for:** Tailwind CSS v4 `@theme {}` mechanics (use `tailwind-v4-theming`), component markup authoring, layout pattern decisions, or z-index/sticky UI work.

## Inputs To Collect First

1. Specific design area to address (colour, typography scale, font weight, spacing, or interactive states)
2. Proposed new token name and hex value if adding a colour
3. Background tier(s) the colour will appear on (`bg-primary`, `bg-white`, or `bg-dark`)
4. Whether WCAG contrast ratio verification is needed before adopting the token

## Procedure

### Step 1 — Extend the Color Palette

When adding a new brand color, follow this process:

1. **Name it semantically** (by role, not by hue): `accent-terracotta`, not `color-orange`
2. **Test contrast** against all background tiers before adding
3. **Add to `@theme {}`** in `globals.css`
4. **Document it** in this skill file under the inventory

**Proposed palette extensions (not yet implemented):**

```css
@theme {
  /* Warm accent for CTAs — more energetic than current muted blue */
  --color-accent-terracotta: #C4704A;
  /* Use for: primary CTA hover, highlight lines, active states */
  /* Contrast: #C4704A on #FFFFFF → 3.5:1 (use only at 18px+ or bold) */

  /* Error / form validation */
  --color-error: #B91C1C;
  /* Success / form confirmed */
  --color-success: #15803D;
  /* Neutral for borders */
  --color-border-subtle: #D4C8C4;
}
```

### Step 2 — Typography Scale Design

The project uses explicit pixel sizes (not Tailwind fluid defaults). Here's the rationale and use cases:

```
13px  → font-light/font-normal
       Use: micro-copy, badges, eyebrows, form labels, legal text, tooltips
       Always uppercase + tracking-wider for eyebrows

16px  → font-normal/font-semibold
       Use: body text (mobile), nav links, button labels, list items
       The baseline size — most text reads at this size on mobile

17px  → font-normal (always paired as md:text-[17px])
       Use: body text at md: breakpoint only — slight optical bump

20px  → font-semibold
       Use: H3 (mobile), card titles, step labels, feature headings

24px  → font-semibold (always paired as md:text-[24px])
       Use: H3 at md: breakpoint

26px  → font-semibold
       Use: H2 (mobile), section headings

36px  → font-semibold/font-bold
       Use: H2 at md:, H1 (mobile), hero subheadings

52px  → font-bold
       Use: H1 at md:, hero headings only
```

### Step 3 — Font Weight System

```
font-extralight (200) → Decorative taglines only (e.g., "Renovations Simplified" under wordmark)
font-light (300)      → Micro-copy, captions, secondary labels, legal text
font-normal (400)     → All body text (paragraphs, list items, nav secondary)
font-semibold (600)   → All headings H2-H3, CTA button text, nav primary links
font-bold (700)       → H1 only, wordmark "GARNEBO", numerical stats
```

**Never use:**
- `font-medium` (500) — not part of the system, creates visual ambiguity
- `font-black` (900) — too aggressive for this brand's tone

### Step 4 — Spacing System

The project doesn't define custom spacing tokens — it uses Tailwind's built-in scale. Conventions:

```
Section vertical:    py-16 md:py-24         (64px / 96px)
Card inner:          p-6 md:p-8            (24px / 32px)
Content gap:         gap-8                  (32px)
Small element gap:   gap-4 or gap-6        (16px / 24px)
Inline element gap:  gap-2                  (8px)
Container max-width: max-w-3xl / max-w-5xl / max-w-7xl
Horizontal padding:  px-4 sm:px-6 lg:px-8 (16px / 24px / 32px)
```

### Step 5 — Line Height & Letter Spacing

```tsx
// Body text: always use leading-relaxed (1.625)
className="leading-relaxed"

// Headlines: use leading-tight (1.25) for large text
className="leading-tight"

// Single-line labels: use leading-none (1)
className="leading-none"

// Eyebrow labels: tracking-wider (0.05em)
className="text-[13px] font-semibold uppercase tracking-wider text-accent-sage"

// Wordmark: tracking-wider on the brand name
className="text-xl font-bold uppercase tracking-wider"
```

### Step 6 — Heading Hierarchy Template

Every page must follow this heading structure:

```tsx
{/* Page-level H1 — one per page */}
<h1 className="text-[36px] font-bold leading-tight text-brand-primary md:text-[52px]">
  {t('heading')}
</h1>

{/* Section H2 */}
<h2 className="text-[26px] font-semibold text-brand-primary md:text-[36px]">
  {t('sectionHeading')}
</h2>

{/* Sub-section H3 */}
<h3 className="text-[20px] font-semibold text-brand-primary md:text-[24px]">
  {t('cardTitle')}
</h3>

{/* Body text */}
<p className="text-[16px] font-normal leading-relaxed text-brand-secondary md:text-[17px]">
  {t('body')}
</p>

{/* Eyebrow label — always before H1/H2 */}
<p className="text-[13px] font-semibold uppercase tracking-wider text-accent-sage">
  {t('eyebrow')}
</p>

{/* Micro-copy — footnotes, reassurance text */}
<p className="text-[13px] font-light text-accent-blue">
  {t('micro')}
</p>
```

### Step 7 — Dark Section Typography

When on `bg-bg-dark` backgrounds (#4C6170):

```tsx
<section className="bg-bg-dark">
  <h2 className="text-[26px] font-semibold text-white md:text-[36px]">
  <p  className="text-[16px] font-normal leading-relaxed text-white/80 md:text-[17px]">
  <span className="text-[13px] font-light text-white/60">  {/* micro-copy */}
```

### Step 8 — Interactive State Colors

Consistent hover/focus/active states across all interactive elements:

```tsx
// Links and text CTAs
className="text-brand-primary transition-colors hover:text-accent-blue"

// Primary buttons
className="bg-brand-primary text-white transition-colors hover:bg-accent-blue"

// Inverted buttons (on dark bg)
className="bg-white text-brand-primary transition-colors hover:bg-bg-primary"

// Ghost buttons / text links
className="text-brand-primary underline underline-offset-4 transition-colors hover:text-accent-blue"

// Focus rings (keyboard nav)
className="focus:outline-none focus-visible:ring-2 focus-visible:ring-accent-blue focus-visible:ring-offset-2"
```

### Step 9 — Color Usage Anti-Pattern Detection

When auditing, flag these as violations:

```tsx
// ❌ Arbitrary color not from token system
className="text-gray-600 bg-blue-500"

// ❌ Hardcoded hex in className (except gradient overlays)
className="text-[#4C6170]"  // should be: text-brand-primary

// ❌ Wrong weight for heading level
<h1 className="font-normal">  // H1 must be font-bold

// ❌ Missing responsive text scale
<h2 className="text-[26px]">  // must have md:text-[36px]

// ❌ accent-blue used for small body text (fails contrast)
<p className="text-[14px] text-accent-blue">  // contrast 2.9:1, too low

// ✅ Correct usage
<p className="text-[16px] font-normal leading-relaxed text-brand-secondary md:text-[17px]">
```

## Brand Identity Rationale

| Design choice | Reason |
|--------------|--------|
| Muted, earthy palette | Signals stability and craftsmanship — not "flashy startup" |
| Deep slate as primary | Authoritative, trust-building, reads as institutional |
| Sage/stone accents | Natural, material, connects to renovation/architecture |
| Heavy negative space | Premium quality signal — cheap services feel cramped |
| Inter typeface | Software-like legibility — "tech-enabled" positioning |
| All-caps eyebrows | Creates visual hierarchy without extra colours |

## Proposed Accent Color Upgrade (Optional)

The current `accent-blue` (#8A9EAB) is too muted for primary CTAs. If conversion testing shows suboptimal CTA performance, consider:

**Option A: Terracotta accent** `#C4704A` — warm, contrasts strongly with slate, feels artisanal
**Option B: Electric blue** `#2563EB` — high energy, strong CTA visibility, modern tech aesthetic

Test approach: A/B test the CTA button colour only. Change `bg-brand-primary` on CTAs to the new accent, keep `brand-primary` for text.

## Constraints & Anti-Patterns

- **DO NOT** use `text-sm`, `text-base`, `text-lg` — use explicit pixel sizes only
- **DO NOT** use `font-medium` — not part of the weight system
- **DO NOT** use `accent-blue` or `accent-sage` for small (≤14px) body text — fails WCAG AA
- **DO NOT** add colour tokens without a clear semantic role
- **DO NOT** create visually similar tokens (e.g., two shades of slate) without distinct semantic purposes
- **ALWAYS** test new tokens in both `it` and `en` locales — Italian text is typically longer

## Invocation Examples

- "What font weight should I use for a card title?"
- "Is accent-blue safe to use for body text?"
- "Add a terracotta accent colour to the design system"
- "Show me the correct typography classes for an H2 section heading"
- "Audit the typography across all components for consistency"
- "What's the correct text colour for body text on the dark CTA banner?"

## Completion Checks

- [ ] New colour token is semantically named by role, not by hue (e.g. `accent-terracotta`, not `color-orange`)
- [ ] Contrast ratio verified for every background tier combination the token will be used on
- [ ] `accent-blue` and `accent-sage` are not applied to body text smaller than 18 px (contrast 2.9:1 — fails WCAG AA)
- [ ] H1 uses `font-bold`, H2 and H3 use `font-semibold` — no other weights for headings
- [ ] Responsive type scale applied consistently (e.g. `text-[26px] md:text-[36px]` for H2, `text-[36px] md:text-[52px]` for H1)
- [ ] No `font-medium` or `font-black` weight classes present in any changed files
- [ ] No `text-sm`, `text-base`, or `text-lg` Tailwind defaults — all sizes use explicit pixel notation
- [ ] New token documented in the Current Design Token Inventory section of this skill

## References

No external references required.
