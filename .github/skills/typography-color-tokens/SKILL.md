---
name: typography-color-tokens
description: "Use when designing, extending, auditing, or documenting a visual identity system, including color palette decisions, semantic token naming, type scale, font weights, line height, letter spacing, and spacing conventions. Use when user asks to 'define color palette', 'create type scale', 'name design tokens', 'audit brand colors', or 'set font weights'. Covers semantic token hierarchies, WCAG contrast ratios, typographic rhythm, and spacing scale design. Do NOT use for Tailwind CSS v4 config mechanics, CSS utility class authoring, component markup changes, or layout implementation work."
argument-hint: "design area, specific token or violation to address"
user-invocable: true
---

# Typography and Color Token System Design
Design, document, and extend the Garnebo visual identity system — covering color palette decisions, token naming conventions, type scale, font weight usage, and spacing — so every UI element is visually consistent and on-brand.

**Config location:** `src/app/globals.css` — `@theme {}` block is the single source of truth. **Font:** Inter via `next/font/google`, mapped to `--font-sans`. **Current palette:** Muted, earthy, professional — "precision craftwork", not "budget renovation".

## When To Use

- Adding a new brand colour and needing to verify contrast ratios and determine the correct semantic token name
- Auditing components for typography violations (wrong font weight for heading level, hardcoded hex, missing responsive scale)
- Documenting a proposed palette extension or type scale change in the design system inventory
- Determining the correct text colour token for a dark background section
- Identifying whether `accent-blue` or `accent-sage` are safe to use at a given font size

**Do NOT use for:** Tailwind CSS v4 `@theme {}` mechanics (use `tailwind-v4-theming`), component markup authoring, layout decisions, or z-index work.

## Inputs To Collect First

1. Specific design area (colour, typography scale, font weight, spacing, or interactive states)
2. Proposed new token name and hex value if adding a colour
3. Background tier(s) the colour will appear on (`bg-primary`, `bg-white`, or `bg-dark`)
4. Whether WCAG contrast ratio verification is needed

## Procedure

### Step 1 — Current Design Token Inventory

**Color tokens:**
```
Background tier:
  bg-primary    #EBE0DD  Warm off-white — default page background
  bg-white      #FFFFFF  Pure white — contrast sections
  bg-dark       #4C6170  Deep slate — footer, dark CTA sections

Brand tier:
  brand-primary   #4C6170  H1/H2/H3 text, nav, icon fills
  brand-secondary #65695B  Body paragraphs, supporting copy

Accent tier:
  accent-blue   #8A9EAB  Links, hover states, micro-copy
  accent-sage   #9CA38E  Bullets, dividers, eyebrows, tags
```

**Contrast ratios:**
- `#4C6170` on `#EBE0DD` → 4.6:1 ✅
- `#65695B` on `#EBE0DD` → 4.6:1 ✅
- `#4C6170` on `#FFFFFF` → 6.1:1 ✅
- White on `#4C6170` → 5.1:1 ✅
- `#8A9EAB` on `#EBE0DD` → 2.9:1 ⚠️ use only for decorative/large text

> `accent-blue` and `accent-sage` fail WCAG AA for small body text — only suitable for 18px+ decorative text, icons, and large labels.

### Step 2 — Extending the Color Palette

1. **Name semantically** (by role, not hue): `accent-terracotta`, not `color-orange`
2. **Test contrast** against all background tiers before adding
3. **Add to `@theme {}`** in `globals.css`
4. **Document it** in the inventory above

**Proposed palette extensions (not yet implemented):**
```css
--color-accent-terracotta: #C4704A;  /* Warm CTA accent — 3.5:1 on white (18px+ only) */
--color-error: #B91C1C;
--color-success: #15803D;
--color-border-subtle: #D4C8C4;
```

### Step 3 — Typography Scale Design

```
13px  font-light/font-normal
      Use: micro-copy, badges, eyebrows, labels, legal text
      Always uppercase + tracking-wider for eyebrows

16px  font-normal/font-semibold
      Use: body text (mobile), nav links, button labels
      The baseline size — most text at this size on mobile

17px  font-normal (always as md:text-[17px])
      Use: body text at md: breakpoint only

20px  font-semibold
      Use: H3 (mobile), card titles, step labels

24px  font-semibold (always as md:text-[24px])
      Use: H3 at md: breakpoint

26px  font-semibold
      Use: H2 (mobile), section headings

36px  font-semibold/font-bold
      Use: H2 at md:, H1 (mobile), hero subheadings

52px  font-bold
      Use: H1 at md:, hero headings only
```

### Step 4 — Font Weight System

```
font-extralight (200) → Decorative taglines only
font-light (300)      → Micro-copy, captions, legal text
font-normal (400)     → All body text
font-semibold (600)   → H2-H3, CTA buttons, nav links
font-bold (700)       → H1 only, wordmark "GARNEBO", numerical stats
```

**Never use:** `font-medium` (500) — not part of the system. `font-black` (900) — too aggressive.

### Step 5 — Spacing Conventions

```
Section vertical:    py-16 md:py-24
Card inner:          p-6 md:p-8
Content gap:         gap-8
Inline element gap:  gap-2
Container max-width: max-w-3xl / max-w-5xl / max-w-7xl
Horizontal padding:  px-4 sm:px-6 lg:px-8
```

### Step 6 — Heading Hierarchy Template

```tsx
<h1 className="text-[36px] font-bold leading-tight text-brand-primary md:text-[52px]">
<h2 className="text-[26px] font-semibold text-brand-primary md:text-[36px]">
<h3 className="text-[20px] font-semibold text-brand-primary md:text-[24px]">
<p  className="text-[16px] font-normal leading-relaxed text-brand-secondary md:text-[17px]">
{/* Eyebrow — always before H1/H2 */}
<p className="text-[13px] font-semibold uppercase tracking-wider text-accent-sage">
{/* Micro-copy */}
<p className="text-[13px] font-light text-accent-blue">
```

### Step 7 — Dark Section Typography

```tsx
<section className="bg-bg-dark">
  <h2 className="text-[26px] font-semibold text-white md:text-[36px]">
  <p  className="text-[16px] font-normal leading-relaxed text-white/80 md:text-[17px]">
  <span className="text-[13px] font-light text-white/60">
</section>
```

### Step 8 — Interactive State Colors

```tsx
// Links
className="text-brand-primary transition-colors hover:text-accent-blue"
// Primary buttons
className="bg-brand-primary text-white transition-colors hover:bg-accent-blue"
// Inverted buttons (on dark bg)
className="bg-white text-brand-primary transition-colors hover:bg-bg-primary"
// Focus rings
className="focus:outline-none focus-visible:ring-2 focus-visible:ring-accent-blue focus-visible:ring-offset-2"
```

### Step 9 — Anti-Pattern Detection

```tsx
// ❌ Arbitrary color
className="text-gray-600 bg-blue-500"

// ❌ Hardcoded hex
className="text-[#4C6170]"  // should be: text-brand-primary

// ❌ Wrong weight for heading
<h1 className="font-normal">  // H1 must be font-bold

// ❌ Missing responsive scale
<h2 className="text-[26px]">  // must have md:text-[36px]

// ❌ accent-blue on small body text (fails contrast)
<p className="text-[14px] text-accent-blue">

// ✅ Correct
<p className="text-[16px] font-normal leading-relaxed text-brand-secondary md:text-[17px]">
```

> **Constraints:** Do NOT use `text-sm`, `text-base`, `text-lg`. Do NOT use `font-medium`. Do NOT use `accent-blue` or `accent-sage` for small (≤14px) body text. Do NOT add colour tokens without a clear semantic role. ALWAYS test new tokens in both `it` and `en` locales.

## Completion Checks

- [ ] New colour token is semantically named by role, not hue
- [ ] Contrast ratio verified for every background tier combination
- [ ] `accent-blue` and `accent-sage` not applied to body text smaller than 18 px
- [ ] H1 uses `font-bold`, H2 and H3 use `font-semibold`
- [ ] Responsive type scale applied consistently (e.g. `text-[26px] md:text-[36px]`)
- [ ] No `font-medium` or `font-black` present in any changed files
- [ ] No `text-sm`, `text-base`, or `text-lg` — all sizes use explicit pixel notation
- [ ] New token documented in the Current Design Token Inventory section

## References

- [Tailwind CSS v4 — Documentation](https://tailwindcss.com/docs)
- [MDN — font-size](https://developer.mozilla.org/en-US/docs/Web/CSS/font-size)
- [MDN — CSS Custom Properties](https://developer.mozilla.org/en-US/docs/Web/CSS/Using_CSS_custom_properties)
- [Material Design — Type scale](https://m3.material.io/styles/typography/type-scale-tokens)
